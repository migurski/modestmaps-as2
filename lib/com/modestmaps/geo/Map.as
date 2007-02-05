import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.stamen.twisted.DelayedCall;

import com.modestmaps.geo.Location;
import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.MapProviderFactory;
import com.modestmaps.mapproviders.MapProviders;

class com.modestmaps.geo.Map extends MovieClip
{
    private var width:Number;
    private var height:Number;
    
    // pending zoom steps, array of [amount:Number, redraw:Boolean] (see TileGrid.zoomBy)
    private var __zoomSteps:/*Array*/Array;

    // associated zooming call
    private var __zoomTask:DelayedCall;

    // frames-per-2x-zoom
    private static var __zoomFrames:Number = 6;

    // das grid
    public var grid:TileGrid;

    // Who do we get our Map graphics from?
    public var mapProviderType:Number;
    public var mapProvider:IMapProvider;

    public static var symbolName:String = '__Packages.com.modestmaps.geo.Map';
    public static var symbolOwner:Function = Map;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
    public function Map()
    {
        __zoomSteps = [];

        setMapProvider(mapProviderType);
    
        grid = TileGrid(attachMovie(TileGrid.symbolName, 'grid', getNextHighestDepth(),
                                    {mapProvider: mapProvider, _x: 0, _y: 0, width: width, height: height}));

        var extent:/*Location*/Array = [new Location(37.829853, -122.514725),
                                        new Location(37.700121, -122.212601)];
        
        setInitialExtent(extent);
        
        // spit out the current extent when the map has had a chance to load
        Reactor.callLater(1000, Delegate.create(this, this.getCurrentExtent));
        
        /*
        // after 10 seconds, zip over to new york
        Reactor.callLater(10000, Delegate.create(this, this.setNewExtent), [new Location(40.804454, -73.969574), new Location(40.716038, -74.029999), new Location(40.683762, -73.899536)]);
        Reactor.callLater(11000, Delegate.create(this, this.getCurrentExtent));
        
        // later, pay a visit to tokyo
        Reactor.callLater(20000, Delegate.create(this, this.setNewExtent), [new Location(35.804449, 139.597778), new Location(35.550105, 139.938354)]);
        Reactor.callLater(21000, Delegate.create(this, this.getCurrentExtent));
        */
        
        putMarker('Rochdale', new Location(37.865571, -122.259679));
        putMarker('Parker Ave.', new Location(37.780492, -122.453731));
        putMarker('Pepper Dr.', new Location(37.623443, -122.426577));
        putMarker('3rd St.', new Location(37.779297, -122.392877));
        putMarker('Divisadero St.', new Location(37.771919, -122.437413));
        putMarker('Market St.', new Location(37.812734, -122.280064));
        putMarker('17th St.', new Location(37.804274, -122.262940));
    }

   /*
    * Based on an array of locations, determine appropriate map bounds
    * using calculateMapExtent(), and inform the grid of an initial tile
    * coordinate and point by calling grid.setInitialTile().
    */
    private function setInitialExtent(locations:/*Location*/Array):Void
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
    private function setNewExtent(locations:/*Location*/Array):Void
    {
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
        var initZoom:Number = Math.min(hPossibleZoom, vPossibleZoom);

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
    private function getCurrentExtent():/*Location*/Array
    {
        var corners:/*Location*/Array = [];

        var TL:Coordinate = grid.topLeftCoordinate();
        var BR:Coordinate = grid.bottomRightCoordinate();
        var TR:Coordinate = new Coordinate(TL.row, BR.column, TL.zoom);
        var BL:Coordinate = new Coordinate(BR.row, TL.column, BR.zoom);

        corners.push(mapProvider.coordinateLocation(TL));
        corners.push(mapProvider.coordinateLocation(TR));
        corners.push(mapProvider.coordinateLocation(BL));
        corners.push(mapProvider.coordinateLocation(BR));
        
        grid.log('top left: '+corners[0].toString());
        grid.log('top right: '+corners[1].toString());
        grid.log('bottom left: '+corners[2].toString());
        grid.log('bottom right: '+corners[3].toString());

        return corners;
    }

   /*
    * TODO:
    * Size relative to stage is currently hard-coded, but shouldn't be.
    */
    public function onResize():Void
    {
        width = Stage.width - 2 * _x;
        height = Stage.height - 2 * _y;
        
        grid.resizeTo(new Point(width, height));
    }
    
    public function nagAboutBoundsForever():Void
    {
        grid.log('Top left: '+grid.topLeftCoordinate().toString()+', '+mapProvider.coordinateLocation(grid.topLeftCoordinate()).toString());
        grid.log('Bottom right: '+grid.bottomRightCoordinate().toString()+', '+mapProvider.coordinateLocation(grid.bottomRightCoordinate()).toString());
        
        //Reactor.callLater(5000, Delegate.create(this, this.nagAboutBoundsForever));
    }
    
    private function setMapProvider(mapProviderType:Number):Void
    {
        this.mapProviderType = mapProviderType;
        var mapProviderFactory:MapProviderFactory = MapProviderFactory.getInstance();
        mapProvider = MapProviderFactory.getInstance().getMapProvider(mapProviderType); 
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
            
        if(!__zoomTask)
            zoomProcess();
    }
    
    public function zoomOut():Void
    {
        for(var i = 1; i <= __zoomFrames; i += 1)
            __zoomSteps.push([-1/__zoomFrames, Boolean(i == __zoomFrames)]);
            
        if(!__zoomTask)
            zoomProcess();
    }
    
    private function zoomProcess():Void
    {
        if(__zoomSteps.length) {
            var step:Array = Array(__zoomSteps.shift());
            grid.zoomBy(Number(step[0]), Boolean(step[1]));
            __zoomTask = Reactor.callNextFrame(Delegate.create(this, this.zoomProcess));

        } else {
            delete __zoomTask;
            
        }
    }
    
    public function putMarker(name:String, location:Location):Void
    {
        grid.log('Marker '+name+': '+location.toString());
        grid.putMarker(name, mapProvider.locationCoordinate(location));
    }
}