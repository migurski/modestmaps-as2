/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author migurski
 * @author darren
 * $Id$
 *
 * com.modestmaps.Map is the base class and interface for Modest Maps.
 *
 * @description Map is the base class and interface for Modest Maps.
 * 				Correctly attaching an instance of this MovieClip subclass 
 * 				should result in a pannable map. Controls and event 
 * 				handlers must be added separately.
 *
 * @usage <code>
 *          import com.modestmaps.Map;
 *          import com.modestmaps.geo.Location;
 *          import com.modestmaps.mapproviders.BlueMarbleMapProvider;
 *          import com.stamen.twisted.Reactor;
 *          ...
 *          Reactor.run(clip, null, 50);
 *          var map:Map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth()));
 *          map.init(640, 480, true, new BlueMarbleMapProvider());
 *        </code>
 */

import com.bigspaceship.utils.Delegate;
import org.casaframework.movieclip.DispatchableMovieClip;
import flash.geom.Point;

import com.modestmaps.core.MapExtent;
import com.modestmaps.core.MapPosition;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.MarkerClip;
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
    
    public var backgroundColor:Number = 0x666666;

    // pending animation steps, array of {type:'pan'/'zoom', amount:Point/Number, redraw:Boolean}
    private var __animSteps:/*Object*/Array;

    // associated animation call
    private var __animTask:DelayedCall;

    // frames-per-2x-zoom
    public var zoomFrames:Number = 6;
    
    // frames-per-full-pan
    public var panFrames:Number = 12;
    
    private var __startingPosition:Point;
    private var __currentPosition:Point;
    private var __startingZoom:Number;
    private var __currentZoom:Number;

    // das grid
    public var grid:TileGrid;

    // markers are attached here
    private var __markers:MarkerClip;
    private var __mask:MovieClip;

    // Who do we get our Map graphics from?
    private var __mapProvider:IMapProvider;

    // Events thrown
    public static var EVENT_MARKER_ENTERS:String = 'Marker enters';
    public static var EVENT_MARKER_LEAVES:String = 'Marker leaves';
    public static var EVENT_START_ZOOMING:String = 'Start zooming';
    public static var EVENT_STOP_ZOOMING:String = 'Stop zooming';
    public static var EVENT_ZOOMED_BY:String = 'Zoomed by...';
    public static var EVENT_START_PANNING:String = 'Start panning';
    public static var EVENT_STOP_PANNING:String = 'Stop panning';
    public static var EVENT_PANNED_BY:String = 'Panned by...';
    public static var EVENT_RESIZED_TO:String = 'Resized to...';
    public static var EVENT_EXTENT_CHANGED:String = 'Extent changed';

    public static var symbolName:String = '__Packages.com.modestmaps.Map';
    public static var symbolOwner:Function = Map;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
   /*
    * Initialize the map: set properties, add a tile grid, draw it.
    * This method must be called before the map can be used!
    * Default extent covers the entire globe, (+/-85, +/-180).
    *
    * @param    Width of map, in pixels.
    * @param    Height of map, in pixels.
    * @param    Whether the map can be dragged or not.
    * @param    Desired map provider, e.g. Blue Marble.
    *
    * @see com.modestmaps.core.TileGrid
    */
    public function init(width:Number, height:Number, draggable:Boolean, provider:IMapProvider):Void
    {
        if(!Reactor.running())
        {
            // throw new Error('com.modestmaps.Map.init(): com.stamen.Twisted.Reactor ought to be running at this point.');
            Reactor.run(this, 50);
        }

        __animSteps = [];

        setSize(width, height);
        setMapProvider(provider);
        __draggable = draggable;
    
        grid = TileGrid(attachMovie(TileGrid.symbolName, 'grid', getNextHighestDepth()));
        grid.init(width, height, draggable, provider, this);

        __markers = MarkerClip(attachMovie(MarkerClip.symbolName, '__markers', getNextHighestDepth(), {_x: __width/2, _y: __height/2}));
        __mask = createEmptyMovieClip('__mask', getNextHighestDepth());
        __markers.setMask(__mask);
        __markers.setMap(this);
        
        redraw();
    }

   /*
    * Based on a MapExtent, determine appropriate map
    * bounds using extentPosition(), and inform the grid of
    * tile coordinate and point by calling grid.resetTiles().
    * Resulting map extent will ensure that all passed locations
    * are visible.
    *
    * @param    MapExtent.
    *
    * @see com.modestmaps.Map#extentPosition
    * @see com.modestmaps.core.TileGrid#resetTiles
    */
    public function setExtent(extent:MapExtent):Void
    {
        // what to do if a bad extent is passed?
        var position:MapPosition = extentPosition(extent);
    
        // tell grid what the rock is cooking
        grid.resetTiles(position.coord, position.point);
        onExtentChanged(getExtent());
        Reactor.callNextFrame(Delegate.create(this, this.callCopyright));
        Reactor.callNextFrame(Delegate.create(this, this.callCopyright));
    }
    
   /*
    * Based on a location and zoom level, determine appropriate initial
    * tile coordinate and point using coordinatePosition(), and inform
    * the grid of tile coordinate and point by calling grid.resetTiles().
    *
    * @param    Location of center.
    * @param    Desired zoom level.
    *
    * @see com.modestmaps.Map#extentPosition
    * @see com.modestmaps.core.TileGrid#resetTiles
    */
    public function setCenterZoom(location:Location, zoom:Number):Void
    {
        var center:MapPosition = coordinatePosition(__mapProvider.locationCoordinate(location).zoomTo(zoom));
        
        // tell grid what the rock is cooking
        grid.resetTiles(center.coord, center.point);
        onExtentChanged(getExtent());
        Reactor.callNextFrame(Delegate.create(this, this.callCopyright));
        Reactor.callNextFrame(Delegate.create(this, this.callCopyright));
    }
    
   /*
    * Based on a coordinate, determine appropriate starting tile and position,
    * and return a MapPosition.
    */
    private function coordinatePosition(centerCoord:Coordinate):MapPosition
    {
        // initial tile coordinate
        var initTileCoord:Coordinate = new Coordinate(Math.floor(centerCoord.row), Math.floor(centerCoord.column), Math.floor(centerCoord.zoom));

        // initial tile position, assuming centered tile well in grid
        var initX:Number = (initTileCoord.column - centerCoord.column) * TileGrid.TILE_WIDTH;
        var initY:Number = (initTileCoord.row - centerCoord.row) * TileGrid.TILE_HEIGHT;
        var initPoint:Point = new Point(Math.round(initX), Math.round(initY));
        
        return new MapPosition(initTileCoord, initPoint);
    }
    
   /*
    * Based on an array of locations, determine appropriate map bounds
    * in terms of tile grid, and return a MapPosition from coordinatePosition().
    */
    private function locationsPosition(locations:/*Location*/Array):MapPosition
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
        var hFactor:Number = (BR.column - TL.column) / (__width / TileGrid.TILE_WIDTH);
        
        // multiplication factor expressed as base-2 logarithm, for zoom difference
        var hZoomDiff:Number = Math.log(hFactor) / Math.log(2);
        
        // possible horizontal zoom to fit geographical extent in map width
        var hPossibleZoom:Number = TL.zoom - Math.ceil(hZoomDiff);
        
        // multiplication factor between vertical span and map height
        var vFactor:Number = (BR.row - TL.row) / (__height / TileGrid.TILE_HEIGHT);
        
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
        
        return coordinatePosition(centerCoord);
    }

   /*
    * Based on a MapExtent, determine appropriate map bounds
    * in terms of tile grid, and return a MapPosition from calculateMapCenter().
    */
    private function extentPosition(extent:MapExtent):MapPosition
    {
        var locations:/*Location*/Array = [extent.northWest, extent.southEast];
        return locationsPosition(locations);
    }
    
   /*
    * Return the current coverage area of the map, as MapExtent.
    *
    * @return   MapExtent.
    */
    public function getExtent():MapExtent
    {
        if(!__mapProvider)
            return new MapExtent();

        var coordTL:Coordinate = grid.topLeftCoordinate();
        var coordBR:Coordinate = grid.bottomRightCoordinate();
        var coordTR:Coordinate = new Coordinate(coordTL.row, coordBR.column, coordTL.zoom);
        var coordBL:Coordinate = new Coordinate(coordBR.row, coordTL.column, coordBR.zoom);
        
        var TL:Location = __mapProvider.coordinateLocation(coordTL);
        var BR:Location = __mapProvider.coordinateLocation(coordBR);
        var TR:Location = __mapProvider.coordinateLocation(coordTR);
        var BL:Location = __mapProvider.coordinateLocation(coordBL);
        
        return new MapExtent(Math.max(Math.max(TL.lat, TR.lat), Math.max(BL.lat, BR.lat)),
                             Math.min(Math.min(TL.lat, TR.lat), Math.min(BL.lat, BR.lat)),
                             Math.max(Math.max(TL.lon, TR.lon), Math.max(BL.lon, BR.lon)),
                             Math.min(Math.min(TL.lon, TR.lon), Math.min(BL.lon, BR.lon)));
    }

   /*
    * Return the current center location and zoom of the map.
    *
    * @return   Array of center and zoom: [center location, zoom number].
    */
    public function getCenterZoom():Array
    {
        return [__mapProvider.coordinateLocation(grid.centerCoordinate()), grid.zoomLevel];
    }

   /**
    * Set new map size, call onResized().
    *
    * @param    New map width.
    * @param    New map height.
    *
    * @see com.modestmaps.Map#onResized
    */
    public function setSize(width:Number, height:Number):Void
    {
        __width = width;
        __height = height;
        redraw();

        grid.resizeTo(new Point(__width, __height));
        onResized();
    }

   /**
    * Get map size.
    *
    * @return   Array of [width, height].
    */
    public function getSize():/*Number*/Array
    {
        var size:/*Number*/Array = [__width, __height];
        return size;
    }

   /**
    * Get a reference to the current map provider.
    *
    * @return   Map provider.
    *
    * @see com.modestmaps.mapproviders.IMapProvider
    */
    public function getMapProvider():IMapProvider
    {
        return __mapProvider;
    }

   /**
    * Set a new map provider, repainting tiles and changing bounding box if necessary.
    *
    * @param   Map provider.
    *
    * @see com.modestmaps.mapproviders.IMapProvider
    */
    public function setMapProvider(newProvider:IMapProvider):Void
    {
        var previousGeometry:String = __mapProvider.geometry();
    	var extent:MapExtent = getExtent();
    	
        __mapProvider = newProvider;
        grid.setMapProvider(__mapProvider);
        
        if(__mapProvider.geometry() == previousGeometry) {
        	grid.repaintTiles();
        	
        } else {
        	setExtent(extent);
        	
        }

        Reactor.callLater(1000, Delegate.create(this, this.callCopyright));
    }
    
   /**
    * Get a point (x, y) for a location (lat, lon) in the context of a given clip.
    *
    * @param    Location to match.
    * @param    Movie clip context in which returned point should make sense.
    *
    * @return   Matching point.
    */
    public function locationPoint(location:Location, context:MovieClip):Point
    {
        var coord:Coordinate = __mapProvider.locationCoordinate(location);
        return grid.coordinatePoint(coord, context);
    }
    
   /**
    * Get a location (lat, lon) for a point (x, y) in the context of a given clip.
    *
    * @param    Point to match.
    * @param    Movie clip context in which passed point should make sense.
    *
    * @return   Matching location.
    */
    public function pointLocation(point:Point, context:MovieClip):Location
    {
        var coord:Coordinate = grid.pointCoordinate(point, context);
        return __mapProvider.coordinateLocation(coord);
    }
    
   /**
    * Pan up by 2/3 of the map height.
    * @see com.modestmaps.Map#panMap
    */
    public function panUp():Void
    {
        var distance:Number = -2*__height / 3;
        panMap(new Point(0, Math.round(distance/panFrames)));
    }      

   /**
    * Pan down by 2/3 of the map height.
    * @see com.modestmaps.Map#panMap
    */
    public function panDown():Void
    {
        var distance:Number = 2*__height / 3;
        panMap(new Point(0, Math.round(distance/panFrames)));
    }
    
   /**
    * Pan to the left by 2/3 of the map width.
    * @see com.modestmaps.Map#panMap
    */
    public function panLeft():Void
    {
        var distance:Number = -2*__width / 3;
        panMap(new Point(Math.round(distance/panFrames, 0)));
    }      

   /**
    * Pan to the right by 2/3 of the map width.
    * @see com.modestmaps.Map#panMap
    */
    public function panRight():Void
    {
        var distance:Number = 2*__width / 3;
        panMap(new Point(Math.round(distance/panFrames, 0)));
    }
    
    private function panMap(perFrame:Point):Void
    {
        for(var i = 1; i <= panFrames; i += 1)
            __animSteps.push({type: 'pan', amount: perFrame});
            
        if(!__animTask) {
            __startingPosition = new Point(grid._x, grid._y);
            __currentPosition = new Point(grid._x, grid._y);

            onStartPan();
            animationProcess();
        }
    }
    
   /**
    * Zoom in by 200% over the course of several frames.
    * @see com.modestmaps.Map#zoomFrames
    */
    public function zoomIn():Void
    {
        for(var i = 1; i <= zoomFrames; i += 1)
            __animSteps.push({type: 'zoom', amount: 1/zoomFrames, redraw: Boolean(i == zoomFrames)});
            
        if(!__animTask) {
            __startingZoom = grid.zoomLevel;
            __currentZoom = grid.zoomLevel;

            onStartZoom();
            animationProcess();
        }
    }
    
   /**
    * Zoom out by 50% over the course of several frames.
    * @see com.modestmaps.Map#zoomFrames
    */
    public function zoomOut():Void
    {
        for(var i = 1; i <= zoomFrames; i += 1)
            __animSteps.push({type: 'zoom', amount: -1/zoomFrames, redraw: Boolean(i == zoomFrames)});
            
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
    *
    * @param    ID of marker, opaque string.
    * @param    Location of marker.
    * @param    Optional symbol name if a clip is to be attached.
    * @return   Optional attached movie clip, if a valid symbol was provided.
    */
    public function putMarker(id:String, location:Location, symbol:String):MovieClip
    {
        //trace('Marker '+id+': '+location.toString());
        grid.putMarker(id, __mapProvider.locationCoordinate(location), location);
        
        if(symbol)
            return __markers.attachMarker(id, location, symbol);
            
        return undefined;
    }

   /**
    * Get a marker clip with the given id if one was created.
    *
    * @param    ID of marker, opaque string.
    * @return   Optional attached movie clip, if a valid symbol was provided.
    */
    public function getMarker(id:String):MovieClip
    {
        return __markers.getMarker(id);
    }

   /**
    * Remove a marker with the given id.
    *
    * @param    ID of marker, opaque string.
    */
    public function removeMarker(id:String):Void
    {
        grid.removeMarker(id);
        __markers.removeMarker(id);
    }
    
   /**
    * Call javascript:modestMaps.copyright() with details about current view.
    * See js/copyright.js.
    */
    private function callCopyright():Void
    {
        var cenP:Point = new Point(__width/2, __height/2);
        var minP:Point = new Point(__width/5, __height/5);
        var maxP:Point = new Point(__width*4/5, __height*4/5);
        
        var cenC:Coordinate = grid.pointCoordinate(cenP, this);
        var minC:Coordinate = grid.pointCoordinate(minP, this);
        var maxC:Coordinate = grid.pointCoordinate(maxP, this);
        
        var cenL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(cenC));
        var minL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(minC));
        var maxL:Location = __mapProvider.coordinateLocation(__mapProvider.sourceCoordinate(maxC));
    
        var minLat:Number = Math.min(minL.lat, maxL.lat);
        var minLon:Number = Math.min(minL.lon, maxL.lon);
        var maxLat:Number = Math.max(minL.lat, maxL.lat);
        var maxLon:Number = Math.max(minL.lon, maxL.lon);
        
        getURL('javascript:try{modestMaps.copyright("'+__mapProvider.toString()+'", '+cenL.lat+', '+cenL.lon+', '+minLat+', '+minLon+', '+maxLat+', '+maxLon+', '+grid.zoomLevel+');}catch(e){void(0);};void(0);');
    }
    
   /**
    * Dispatches EVENT_MARKER_ENTERS when a given marker enters the tile coverage area.
    * Event object includes id:String and location:Location.
    *
    * @param    ID of marker.
    * @param    Location of marker.
    *
    * @see com.modestmaps.Map#EVENT_MARKER_ENTERS
    */
    public function onMarkerEnters(id:String, location:Location):Void
    {
        //trace('+ '+marker.toString());
        dispatchEvent( EVENT_MARKER_ENTERS, id, location );
    }
    
   /**
    * Dispatches EVENT_MARKER_LEAVES when a given marker leaves the tile coverage area.
    * Event object includes id:String and location:Location.
    *
    * @param    ID of marker.
    * @param    Location of marker.
    *
    * @see com.modestmaps.Map#EVENT_MARKER_LEAVES
    */
    public function onMarkerLeaves(id:String, location:Location):Void
    {
        //trace('- '+marker.toString());
        dispatchEvent( EVENT_MARKER_LEAVES, id, location );
    }
    
   /**
    * Dispatches EVENT_START_ZOOMING when the map starts zooming.
    * Event object includes level:Number.
    *
    * @see com.modestmaps.Map#EVENT_START_ZOOMING
    */
    public function onStartZoom():Void
    {
        //trace('Leaving zoom level '+grid.zoomLevel+'...');
        dispatchEvent( EVENT_START_ZOOMING, grid.zoomLevel );
    }
    
   /**
    * Dispatches EVENT_STOP_ZOOMING when the map stops zooming.
    * Callback arguments includes level:Number.
    *
    * @see com.modestmaps.Map#EVENT_STOP_ZOOMING
    */
    public function onStopZoom():Void
    {
        //trace('...Entering zoom level '+grid.zoomLevel);
        dispatchEvent( EVENT_STOP_ZOOMING, grid.zoomLevel );
        callCopyright();
    }
    
   /**
    * Dispatches EVENT_ZOOMED_BY when the map is zooomed.
    * Callback arguments includes delta:Number, difference in levels from zoom start.
    *
    * @param    Change in level since beginning of zoom.
    *
    * @see com.modestmaps.Map#EVENT_ZOOMED_BY
    */
    public function onZoomed(delta:Number):Void
    {
        //trace('Current well offset from start: '+delta.toString());
        dispatchEvent( EVENT_ZOOMED_BY, delta );
    }
    
   /**
    * Dispatches EVENT_START_PANNING when the map starts to be panned.
    *
    * @see com.modestmaps.Map#EVENT_START_PANNING
    */
    public function onStartPan():Void
    {
        //trace('Starting pan...');
        dispatchEvent( EVENT_START_PANNING );
    }
    
   /**
    * Dispatches EVENT_STOP_PANNING when the map stops being panned.
    *
    * @see com.modestmaps.Map#EVENT_STOP_PANNING
    */
    public function onStopPan():Void
    {
        //trace('...Stopping pan');
        dispatchEvent( EVENT_STOP_PANNING );
        callCopyright();
    }
    
   /**
    * Dispatches EVENT_PANNED_BY when the map is panned.
    * Callback arguments includes delta:Point, difference in pixels from pan start.
    *
    * @param    Change in position since beginning of pan.
    *
    * @see com.modestmaps.Map#EVENT_PANNED_BY
    */
    public function onPanned(delta:Point):Void
    {
        //trace('Current well offset from start: '+delta.toString());
        dispatchEvent( EVENT_PANNED_BY, delta );
    }
    
   /**
    * Dispatches EVENT_RESIZED_TO when the map is resized.
    * Callback arguments include width:Number and height:Number.
    *
    * @see com.modestmaps.Map#EVENT_RESIZED_TO
    */
    public function onResized():Void
    {
        dispatchEvent( EVENT_RESIZED_TO, __width, __height );
    }
    
   /**
    * Dispatches EVENT_EXTENT_CHANGED when the map extent changes.
    * Callback arguments include extent:MapExtent.
    *
    * @see com.modestmaps.Map#EVENT_EXTENT_CHANGED
    */
    public function onExtentChanged(extent:MapExtent):Void
    {
        dispatchEvent( EVENT_RESIZED_TO, extent );
    }
    
    private function redraw()
    {
        clear();

        __mask.clear();
        __mask.moveTo(0, 0);
        __mask.lineStyle();
        __mask.beginFill(0xFF00FF, 0);
        __mask.lineTo(0, __height);
        __mask.lineTo(__width, __height);
        __mask.lineTo(__width, 0);
        __mask.lineTo(0, 0);
        __mask.endFill();
    }
}
