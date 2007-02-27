import mx.utils.Delegate;
import mx.events.EventDispatcher;
import com.stamen.twisted.Reactor;
import com.stamen.twisted.DelayedCall;

import com.modestmaps.geo.Location;
import com.modestmaps.core.Point;
import com.modestmaps.core.Marker;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;

class com.modestmaps.geo.Map extends MovieClip
{
    private var width:Number;
    private var height:Number;
    private var draggable:Boolean;
    
    // pending zoom steps, array of [amount:Number, redraw:Boolean] (see TileGrid.zoomBy)
    private var __zoomSteps:/*Array*/Array;

    // associated zooming call
    private var __zoomTask:DelayedCall;

    // frames-per-2x-zoom
    private static var __zoomFrames:Number = 6;

    // das grid
    public var grid:TileGrid;

    // Who do we get our Map graphics from?
    public var mapProvider:IMapProvider;

    // stubs for EventDispatcher
    public var dispatchEvent:Function;
    public var addEventListener:Function;
    public var removeEventListener:Function;

    public static var EVENT_MARKER_ENTERS:String = 'Marker enters';
    public static var EVENT_MARKER_LEAVES:String = 'Marker leaves';
    public static var EVENT_LEAVE_ZOOMLEVEL:String = 'Leave zoom level';
    public static var EVENT_ENTER_ZOOMLEVEL:String = 'Enter zoom level';
    public static var EVENT_START_PANNING:String = 'Start panning';
    public static var EVENT_STOP_PANNING:String = 'Stop panning';

    public static var symbolName:String = '__Packages.com.modestmaps.geo.Map';
    public static var symbolOwner:Function = Map;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
    public function Map()
    {
        EventDispatcher.initialize(this);

        __zoomSteps = [];

        setMapProvider(mapProvider);
    
    	var initObj : Object = 
    	{
    	    map: this,
    		mapProvider: mapProvider, 
    		_x: 0, 
    		_y: 0, 
    		width: width, 
    		height: height, 
    		draggable: draggable
    	};
    		
        grid = TileGrid(attachMovie(TileGrid.symbolName, 'grid', getNextHighestDepth(), initObj));

        var extent:/*Location*/Array = [new Location(80, -180),
                                        new Location(-80, 180)];
        
        setInitialExtent(extent);
        
        // spit out the current extent when the map has had a chance to load
        Reactor.callLater(1000, Delegate.create(this, this.getCurrentExtent));
    }

   /*
    * Based on an array of locations, determine appropriate map bounds
    * using calculateMapExtent(), and inform the grid of an initial tile
    * coordinate and point by calling grid.setInitialTile().
    */
    public function setInitialExtent(locations:/*Location*/Array):Void
    {
        var extent:Object = calculateMapExtent(locations);
    
        // tell grid what the rock is cooking
        grid.setInitialTile(Coordinate(extent['coord']), Point(extent['point']));
    }
    
   /*
    * Based on an array of locations, determine appropriate map bounds
    * using calculateMapExtent(), and forcefully move the grid to cover
    * those bounds using grid.resetTiles().
    */
    public function setNewExtent(locations:/*Location*/Array):Void
    {
        if(!locations)
            return;
    
        var extent:Object = calculateMapExtent(locations);
        grid.resetTiles(Coordinate(extent['coord']), Point(extent['point']));
    }
    
   /*
    * Based on an array of locations, determine appropriate map bounds
    * in terms of tile grid, and return a two-element object with a coord
    * and a point.
    */
    private function calculateMapExtent(locations:/*Location*/Array):Object
    {
        // my kingdom for a decent map() function in AS2
        var coordinates:/*Coordinate*/Array = [];
        
        while(locations.length)
            coordinates.push(mapProvider.locationCoordinate(Location(locations.pop())));
    
        // get outermost top left and bottom right coordinates to cover all locations
        var TL:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
        var BR:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
        
        while(coordinates.length) {
            TL = new Coordinate(Math.min(TL.row, coordinates[0].row), Math.min(TL.column, coordinates[0].column), Math.min(TL.zoom, coordinates[0].zoom));
            BR = new Coordinate(Math.max(BR.row, coordinates[0].row), Math.max(BR.column, coordinates[0].column), Math.max(BR.zoom, coordinates[0].zoom));
            coordinates.shift();
        }

        // multiplication factor between horizontal span and map width
        var hFactor:Number = (BR.column - TL.column) / (width / grid.tileWidth);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        var hZoomDiff:Number = Math.log(hFactor) / Math.log(2);
        
        // possible horizontal zoom to fit geographical extent in map width
        var hPossibleZoom:Number = TL.zoom - Math.ceil(hZoomDiff);
        
        // multiplication factor between vertical span and map height
        var vFactor:Number = (BR.row - TL.row) / (height / grid.tileHeight);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        var vZoomDiff:Number = Math.log(vFactor) / Math.log(2);
        
        // possible vertical zoom to fit geographical extent in map height
        var vPossibleZoom:Number = TL.zoom - Math.ceil(vZoomDiff);
        
        // initial zoom to fit extent vertically and horizontally
        // additionally, make sure it's not outside the boundaries set by provider limits
        var initZoom:Number = Math.min(hPossibleZoom, vPossibleZoom);
        initZoom = Math.min(initZoom, mapProvider.outerLimits()[1].zoom);
        initZoom = Math.max(initZoom, mapProvider.outerLimits()[0].zoom);

        // coordinate of extent center
        var centerRow:Number = (TL.row + BR.row) / 2;
        var centerColumn:Number = (TL.column + BR.column) / 2;
        var centerZoom:Number = (TL.zoom + BR.zoom) / 2;
        var centerCoord:Coordinate = (new Coordinate(centerRow, centerColumn, centerZoom)).zoomTo(initZoom);

        // initial tile coordinate
        var initTileCoord:Coordinate = new Coordinate(Math.floor(centerCoord.row), Math.floor(centerCoord.column), Math.floor(centerCoord.zoom));

        // initial tile position, assuming centered tile well in grid
        var initX:Number = (initTileCoord.column - centerCoord.column) * grid.tileWidth;
        var initY:Number = (initTileCoord.row - centerCoord.row) * grid.tileHeight;
        var initPoint:Point = new Point(Math.round(initX), Math.round(initY));
        
        return {coord: initTileCoord, point: initPoint};
    }
    
   /*
    * Return the current coverage area of the map, as four locations.
    */
    public function getCurrentExtent():/*Location*/Array
    {
        var corners:/*Location*/Array = [];
        
        if(!mapProvider)
            return corners;

        var TL:Coordinate = grid.topLeftCoordinate();
        var BR:Coordinate = grid.bottomRightCoordinate();
        var TR:Coordinate = new Coordinate(TL.row, BR.column, TL.zoom);
        var BL:Coordinate = new Coordinate(BR.row, TL.column, BR.zoom);

        corners.push(mapProvider.coordinateLocation(TL));
        corners.push(mapProvider.coordinateLocation(TR));
        corners.push(mapProvider.coordinateLocation(BL));
        corners.push(mapProvider.coordinateLocation(BR));
        
        /*
        grid.log('top left: '+corners[0].toString());
        grid.log('top right: '+corners[1].toString());
        grid.log('bottom left: '+corners[2].toString());
        grid.log('bottom right: '+corners[3].toString());
        */

        return corners;
    }

    public function setSize(width:Number, height:Number):Void
    {
        this.width = width;
        this.height = height;
        grid.resizeTo(new Point(width, height));
    }
    
    public function nagAboutBoundsForever():Void
    {
        grid.log('Top left: '+grid.topLeftCoordinate().toString()+', '+mapProvider.coordinateLocation(grid.topLeftCoordinate()).toString());
        grid.log('Bottom right: '+grid.bottomRightCoordinate().toString()+', '+mapProvider.coordinateLocation(grid.bottomRightCoordinate()).toString());
        
        //Reactor.callLater(5000, Delegate.create(this, this.nagAboutBoundsForever));
    }
    
    public function setMapProvider(newProvider:IMapProvider):Void
    {
        var previousGeometry:String = mapProvider.geometry();
    	var extent:/*Location*/Array = getCurrentExtent();
    	
        grid.mapProvider = newProvider;
        
        if(mapProvider.geometry() == previousGeometry) {
        	grid.repaintTiles();
        	
        } else {
        	setNewExtent(extent);
        	
        }
    }
    
    public function locationPoint(location:Location, context:MovieClip):Point
    {
        var coord:Coordinate = mapProvider.locationCoordinate(location);
        return grid.coordinatePoint(coord, context);
    }
    
    public function pointLocation(point:Point, context:MovieClip):Location
    {
        var coord:Coordinate = grid.pointCoordinate(point, context);
        return mapProvider.coordinateLocation(coord);
    }
    
    public function panEast(pixels:Number):Void
    {
        grid.panRight(pixels);
    }
 
    public function panWest(pixels:Number):Void
    {
        grid.panLeft(pixels);
    } 
    
    public function panNorth(pixels:Number):Void
    {
        grid.panUp(pixels);
    }
 
    public function panSouth(pixels:Number):Void
    {
        grid.panDown(pixels);
    }      

    public function zoomIn():Void
    {
        for(var i = 1; i <= __zoomFrames; i += 1)
            __zoomSteps.push([1/__zoomFrames, Boolean(i == __zoomFrames)]);
            
        if(!__zoomTask) {
            onLeaveZoom(grid.zoomLevel);
            zoomProcess();
        }
    }
    
    public function zoomOut():Void
    {
        for(var i = 1; i <= __zoomFrames; i += 1)
            __zoomSteps.push([-1/__zoomFrames, Boolean(i == __zoomFrames)]);
            
        if(!__zoomTask) {
            onLeaveZoom(grid.zoomLevel);
            zoomProcess();
        }
    }
    
    private function zoomProcess():Void
    {
        if(__zoomSteps.length) {
            var step:Array = Array(__zoomSteps.shift());
            grid.allowPainting(__zoomSteps.length <= 1);
            grid.zoomBy(Number(step[0]), Boolean(step[1]));
            __zoomTask = Reactor.callNextFrame(Delegate.create(this, this.zoomProcess));

        } else {
            grid.allowPainting(true);
            delete __zoomTask;
            onEnterZoom(grid.zoomLevel);
        }
    }
    
    public function putMarker(name:String, location:Location):Void
    {
        //grid.log('Marker '+name+': '+location.toString());
        grid.putMarker(name, mapProvider.locationCoordinate(location), location);
    }
    
   /**
    * Dispatches EVENT_MARKER_ENTERS when a given marker enters the tile coverage area.
    */
    public function onMarkerEnters(marker:Marker):Void
    {
        //grid.log('+ '+marker.toString());
        dispatchEvent({target: this, type: EVENT_MARKER_ENTERS, marker: marker});
    }
    
   /**
    * Dispatches EVENT_MARKER_LEAVES when a given marker leaves the tile coverage area.
    */
    public function onMarkerLeaves(marker:Marker):Void
    {
        //grid.log('- '+marker.toString());
        dispatchEvent({target: this, type: EVENT_MARKER_LEAVES, marker: marker});
    }
    
   /**
    * Dispatches EVENT_LEAVE_ZOOMLEVEL when the map leaves the given zoom.
    */
    public function onLeaveZoom(zoomLevel:Number):Void
    {
        //grid.log('Leaving zoom level '+zoomLevel+'...');
        dispatchEvent({target: this, type: EVENT_LEAVE_ZOOMLEVEL, level: zoomLevel});
    }
    
   /**
    * Dispatches EVENT_ENTER_ZOOMLEVEL when the map enters the given zoom.
    */
    public function onEnterZoom(zoomLevel:Number):Void
    {
        //grid.log('...Entering zoom level '+zoomLevel);
        dispatchEvent({target: this, type: EVENT_ENTER_ZOOMLEVEL, level: zoomLevel});
    }
    
   /**
    * Dispatches EVENT_START_PANNING when the map starts to be panned.
    */
    public function onStartDrag():Void
    {
        //grid.log('Starting drag...');
        dispatchEvent({target: this, type: EVENT_START_PANNING});
    }
    
   /**
    * Dispatches EVENT_STOP_PANNING when the map stops being panned.
    */
    public function onStopDrag():Void
    {
        //grid.log('...Stopping drag');
        dispatchEvent({target: this, type: EVENT_STOP_PANNING});
    }
}