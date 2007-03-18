/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

import com.bigspaceship.utils.Delegate;

import org.casaframework.movieclip.DispatchableMovieClip;

import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;
import com.stamen.twisted.DelayedCall;
import com.stamen.twisted.Reactor;

class com.modestmaps.Map 
extends DispatchableMovieClip
{
    private var __width:Number = 320;
    private var __height:Number = 240;
    private var __draggable:Boolean = true;
    
    // pending animation steps, array of {type:'pan'/'zoom', amount:Point/Number, redraw:Boolean}
    private var __animSteps:/*Object*/Array;

    // associated animation call
    private var __animTask:DelayedCall;

    // frames-per-2x-zoom
    private static var __zoomFrames:Number = 6;
    
    // frames-per-full-pan
    private static var __panFrames:Number = 12;
    
    private var __startingPosition:Point;
    private var __currentPosition:Point;
    private var __startingZoom:Number;
    private var __currentZoom:Number;

    // das grid
    public var grid:TileGrid;

    // Who do we get our Map graphics from?
    private var __mapProvider:IMapProvider;

    // Events thrown
    public static var EVENT_MARKER_ENTERS:String = 'Marker enters';
    public static var EVENT_MARKER_LEAVES:String = 'Marker leaves';
    public static var EVENT_START_ZOOMING:String = 'Start zooming';
    public static var EVENT_STOP_ZOOMING:String = 'Stop Zooming';
    public static var EVENT_ZOOMED_BY:String = 'Zoomed by...';
    public static var EVENT_START_PANNING:String = 'Start panning';
    public static var EVENT_STOP_PANNING:String = 'Stop panning';
    public static var EVENT_PANNED_BY:String = 'Panned by...';
    public static var EVENT_RESIZED_TO:String = 'Resized to...';

    public static var symbolName:String = '__Packages.com.modestmaps.Map';
    public static var symbolOwner:Function = Map;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
   /*
    * Initialize the map: set properties, add a tile grid, draw it.
    */
    public function init(width:Number, height:Number, draggable:Boolean, provider:IMapProvider):Void
    {
        __animSteps = [];

        setSize(width, height);
        setMapProvider(provider);
        __draggable = draggable;
    
    	var initObj:Object = {
    	    map: this,
    		mapProvider: __mapProvider,
    		_x: 0, 
    		_y: 0, 
    		width: __width, 
    		height: __height, 
    		draggable: __draggable
    	};
    		
        grid = TileGrid(attachMovie(TileGrid.symbolName, 'grid', getNextHighestDepth(), initObj));

        var extent:/*Location*/Array = [new Location(85, -180),
                                        new Location(-85, 180)];
        
        setExtent(extent);
    }

   /*
    * Based on an array of locations, determine appropriate map
    * bounds using calculateMapExtent(), and inform the grid of
    * tile coordinate and point by calling grid.resetTiles().
    */
    public function setExtent(locations:/*Location*/Array):Void
    {
        var extent:Object = calculateMapExtent(locations);
    
        // tell grid what the rock is cooking
        grid.resetTiles(Coordinate(extent['coord']), Point(extent['point']));
    }
    
   /*
    * Based on a location and zoom level, determine appropriate initial
    * tile coordinate and point using calculateMapCenter(), and inform
    * the grid of tile coordinate and point by calling grid.resetTiles().
    */
    public function setCenterZoom(location:Location, zoom:Number):Void
    {
        var center:Object = calculateMapCenter(__mapProvider.locationCoordinate(location).zoomTo(zoom));
        
        // tell grid what the rock is cooking
        grid.resetTiles(Coordinate(center['coord']), Point(center['point']));
    }
    
   /*
    * Based on a coordinate, determine appropriate starting tile and position,
    * and return a two-element object with a coord and a point.
    */
    private function calculateMapCenter(centerCoord:Coordinate):Object
    {
        // initial tile coordinate
        var initTileCoord:Coordinate = new Coordinate(Math.floor(centerCoord.row), Math.floor(centerCoord.column), Math.floor(centerCoord.zoom));

        // initial tile position, assuming centered tile well in grid
        var initX:Number = (initTileCoord.column - centerCoord.column) * grid.tileWidth;
        var initY:Number = (initTileCoord.row - centerCoord.row) * grid.tileHeight;
        var initPoint:Point = new Point(Math.round(initX), Math.round(initY));
        
        return {coord: initTileCoord, point: initPoint};
    }
    
   /*
    * Based on an array of locations, determine appropriate map bounds
    * in terms of tile grid, and return a two-element object with a coord
    * and a point from calculateMapCenter().
    */
    private function calculateMapExtent(locations:/*Location*/Array):Object
    {
        // my kingdom for a decent map() function in AS2
        var coordinates:/*Coordinate*/Array = [];
        
        for(var i:Number = 0; i < locations.length; i += 1)
            coordinates.unshift(__mapProvider.locationCoordinate(locations[i]));
    
        // get outermost top left and bottom right coordinates to cover all locations
        var TL:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
        var BR:Coordinate = new Coordinate(coordinates[0].row, coordinates[0].column, coordinates[0].zoom);
        
        while(coordinates.length) {
            TL = new Coordinate(Math.min(TL.row, coordinates[0].row), Math.min(TL.column, coordinates[0].column), Math.min(TL.zoom, coordinates[0].zoom));
            BR = new Coordinate(Math.max(BR.row, coordinates[0].row), Math.max(BR.column, coordinates[0].column), Math.max(BR.zoom, coordinates[0].zoom));
            coordinates.shift();
        }

        // multiplication factor between horizontal span and map width
        var hFactor:Number = (BR.column - TL.column) / (__width / grid.tileWidth);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        var hZoomDiff:Number = Math.log(hFactor) / Math.log(2);
        
        // possible horizontal zoom to fit geographical extent in map width
        var hPossibleZoom:Number = TL.zoom - Math.ceil(hZoomDiff);
        
        // multiplication factor between vertical span and map height
        var vFactor:Number = (BR.row - TL.row) / (__height / grid.tileHeight);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        var vZoomDiff:Number = Math.log(vFactor) / Math.log(2);
        
        // possible vertical zoom to fit geographical extent in map height
        var vPossibleZoom:Number = TL.zoom - Math.ceil(vZoomDiff);
        
        // initial zoom to fit extent vertically and horizontally
        // additionally, make sure it's not outside the boundaries set by provider limits
        var initZoom:Number = Math.min(hPossibleZoom, vPossibleZoom);
        initZoom = Math.min(initZoom, __mapProvider.outerLimits()[1].zoom);
        initZoom = Math.max(initZoom, __mapProvider.outerLimits()[0].zoom);

        // coordinate of extent center
        var centerRow:Number = (TL.row + BR.row) / 2;
        var centerColumn:Number = (TL.column + BR.column) / 2;
        var centerZoom:Number = (TL.zoom + BR.zoom) / 2;
        var centerCoord:Coordinate = (new Coordinate(centerRow, centerColumn, centerZoom)).zoomTo(initZoom);
        
        return calculateMapCenter(centerCoord);
    }
    
   /*
    * Return the current coverage area of the map, as four locations.
    */
    public function getExtent():/*Location*/Array
    {
        var corners:/*Location*/Array = [];
        
        if(!__mapProvider)
            return corners;

        var TL:Coordinate = grid.topLeftCoordinate();
        var BR:Coordinate = grid.bottomRightCoordinate();
        var TR:Coordinate = new Coordinate(TL.row, BR.column, TL.zoom);
        var BL:Coordinate = new Coordinate(BR.row, TL.column, BR.zoom);

        corners.push(__mapProvider.coordinateLocation(TL));
        corners.push(__mapProvider.coordinateLocation(TR));
        corners.push(__mapProvider.coordinateLocation(BL));
        corners.push(__mapProvider.coordinateLocation(BR));
        
        /*
        grid.log('top left: '+corners[0].toString());
        grid.log('top right: '+corners[1].toString());
        grid.log('bottom left: '+corners[2].toString());
        grid.log('bottom right: '+corners[3].toString());
        */

        return corners;
    }

   /*
    * Return the current center location and zoom of the map, in a two-element array.
    */
    public function getCenterZoom():Array
    {
        return [__mapProvider.coordinateLocation(grid.centerCoordinate()), grid.zoomLevel];
    }

   /**
    * Set new map size.
    */
    public function setSize(width:Number, height:Number):Void
    {
        __width = width;
        __height = height;
        grid.resizeTo(new Point(__width, __height));
        onResized();
    }

   /**
    * Get map size, width:Number, height:Number.
    */
    public function getSize():/*Number*/Array
    {
        var size:/*Number*/Array = [__width, __height];
        return size;
    }

   /**
    * Get a reference to the current mapProvider.
    */
    public function getMapProvider():IMapProvider
    {
        return __mapProvider;
    }

   /**
    * Set a new mapProvider, repainting tiles and changing bounding box if necessary.
    */
    public function setMapProvider(newProvider:IMapProvider):Void
    {
        var previousGeometry:String = __mapProvider.geometry();
    	var extent:/*Location*/Array = getExtent();
    	
        __mapProvider = grid.mapProvider = newProvider;
        
        if(__mapProvider.geometry() == previousGeometry) {
        	grid.repaintTiles();
        	
        } else {
        	setExtent(extent);
        	
        }
    }
    
   /**
    * Get a point (x, y) for a location (lat, lon) in the context of a given clip.
    */
    public function locationPoint(location:Location, context:MovieClip):Point
    {
        var coord:Coordinate = __mapProvider.locationCoordinate(location);
        return grid.coordinatePoint(coord, context);
    }
    
   /**
    * Get a location (lat, lon) for a point (x, y) in the context of a given clip.
    */
    public function pointLocation(point:Point, context:MovieClip):Location
    {
        var coord:Coordinate = grid.pointCoordinate(point, context);
        return __mapProvider.coordinateLocation(coord);
    }
    
   /**
    * Pan up by 2/3 of the map height.
    */
    public function panUp():Void
    {
        var distance:Number = -2*__height / 3;
        panMap(new Point(0, Math.round(distance/__panFrames)));
    }      

   /**
    * Pan down by 2/3 of the map height.
    */
    public function panDown():Void
    {
        var distance:Number = 2*__height / 3;
        panMap(new Point(0, Math.round(distance/__panFrames)));
    }
    
   /**
    * Pan to the left by 2/3 of the map width.
    */
    public function panLeft():Void
    {
        var distance:Number = -2*__width / 3;
        panMap(new Point(Math.round(distance/__panFrames, 0)));
    }      

   /**
    * Pan to the right by 2/3 of the map width.
    */
    public function panRight():Void
    {
        var distance:Number = 2*__width / 3;
        panMap(new Point(Math.round(distance/__panFrames, 0)));
    }
    
    private function panMap(perFrame:Point):Void
    {
        for(var i = 1; i <= __panFrames; i += 1)
            __animSteps.push({type: 'pan', amount: perFrame});
            
        if(!__animTask) {
            __startingPosition = new Point(grid._x, grid._y);
            __currentPosition = new Point(grid._x, grid._y);

            onStartPan();
            animationProcess();
        }
    }
    
   /**
    * Zoom in by 200% over the course of __zoomFrames frames.
    */
    public function zoomIn():Void
    {
        for(var i = 1; i <= __zoomFrames; i += 1)
            __animSteps.push({type: 'zoom', amount: 1/__zoomFrames, redraw: Boolean(i == __zoomFrames)});
            
        if(!__animTask) {
            __startingZoom = grid.zoomLevel;
            __currentZoom = grid.zoomLevel;

            onStartZoom();
            animationProcess();
        }
    }
    
   /**
    * Zoom in by 200% over the course of __zoomFrames frames.
    */
    public function zoomOut():Void
    {
        for(var i = 1; i <= __zoomFrames; i += 1)
            __animSteps.push({type: 'zoom', amount: -1/__zoomFrames, redraw: Boolean(i == __zoomFrames)});
            
        if(!__animTask) {
            __startingZoom = grid.zoomLevel;
            __currentZoom = grid.zoomLevel;

            onStartZoom();
            animationProcess();
        }
    }
    
    private function animationProcess(lastType:String):Void
    {
        if(__animSteps.length) {
            var step:Object = __animSteps.shift();

            if(step.type == 'pan') {
                //grid.allowPainting(__animSteps.length <= 1);
                grid.panRight(step.amount.x);
                grid.panDown(step.amount.y);
    
                __currentPosition.x += step.amount.x;
                __currentPosition.y += step.amount.y;
                onPanned(new Point(__currentPosition.x-__startingPosition.x, __currentPosition.y-__startingPosition.y));

            } else if(step.type == 'zoom') {
                grid.allowPainting(__animSteps.length <= 1);
                grid.zoomBy(Number(step.amount), Boolean(step.redraw));
    
                __currentZoom += Number(step.amount);
                onZoomed(__currentZoom - __startingZoom);
            
            }

            __animTask = Reactor.callNextFrame(Delegate.create(this, this.animationProcess), step.type);
            
            if(lastType == 'pan' && step.type == 'zoom') {
                onStopPan();
                onStartZoom();

            } else if(lastType == 'zoom' && step.type == 'pan') {
                onStopZoom();
                onStartPan();

            }

        } else {
            grid.allowPainting(true);
            delete __animTask;

            if(lastType == 'pan')
                onStopPan();

            if(lastType == 'zoom')
                onStopZoom();
        }
    }

   /**
    * Add a marker with the given id and location (lat, lon).
    */
    public function putMarker(id:String, location:Location):Void
    {
        //grid.log('Marker '+id+': '+location.toString());
        grid.putMarker(id, __mapProvider.locationCoordinate(location), location);
    }

   /**
    * Remove a marker with the given id.
    */
    public function removeMarker(id:String):Void
    {
        grid.removeMarker(id);
    }
    
   /**
    * Dispatches EVENT_MARKER_ENTERS when a given marker enters the tile coverage area.
    * Event object includes id:String and location:Location.
    */
    public function onMarkerEnters(id:String, location:Location):Void
    {
        //grid.log('+ '+marker.toString());
        dispatchEvent( EVENT_MARKER_ENTERS, id, location );
    }
    
   /**
    * Dispatches EVENT_MARKER_LEAVES when a given marker leaves the tile coverage area.
    * Event object includes id:String and location:Location.
    */
    public function onMarkerLeaves(id:String, location:Location):Void
    {
        //grid.log('- '+marker.toString());
        dispatchEvent( EVENT_MARKER_LEAVES, id, location );
    }
    
   /**
    * Dispatches EVENT_START_ZOOMING when the map starts zooming.
    * Event object includes level:Number.
    */
    public function onStartZoom():Void
    {
        //grid.log('Leaving zoom level '+grid.zoomLevel+'...');
        dispatchEvent( EVENT_START_ZOOMING, grid.zoomLevel );
    }
    
   /**
    * Dispatches EVENT_STOP_ZOOMING when the map stops zooming.
    * Callback arguments includes level:Number.
    */
    public function onStopZoom():Void
    {
        //grid.log('...Entering zoom level '+grid.zoomLevel);
        dispatchEvent( EVENT_STOP_ZOOMING, grid.zoomLevel );
    }
    
   /**
    * Dispatches EVENT_ZOOMED_BY when the map is zooomed.
    * Callback arguments includes delta:Number, difference in levels from zoom start.
    */
    public function onZoomed(delta:Number):Void
    {
        //grid.log('Current well offset from start: '+delta.toString());
        dispatchEvent( EVENT_ZOOMED_BY, delta );
    }
    
   /**
    * Dispatches EVENT_START_PANNING when the map starts to be panned.
    */
    public function onStartPan():Void
    {
        //grid.log('Starting pan...');
        dispatchEvent( EVENT_START_PANNING );
    }
    
   /**
    * Dispatches EVENT_STOP_PANNING when the map stops being panned.
    */
    public function onStopPan():Void
    {
        //grid.log('...Stopping pan');
        dispatchEvent( EVENT_STOP_PANNING );
    }
    
   /**
    * Dispatches EVENT_PANNED_BY when the map is panned.
    * Callback arguments includes delta:Point, difference in pixels from pan start.
    */
    public function onPanned(delta:Point):Void
    {
        //grid.log('Current well offset from start: '+delta.toString());
        dispatchEvent( EVENT_PANNED_BY, delta );
    }
    
   /**
    * Dispatches EVENT_RESIZED_TO when the map is resized.
    * Callback arguments include width:Number and height:Number.
    */
    public function onResized():Void
    {
        dispatchEvent( EVENT_RESIZED_TO, __width, __height );
    }
}
