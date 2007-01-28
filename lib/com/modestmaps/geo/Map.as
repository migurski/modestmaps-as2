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

        setInitialExtent(new Location(37.829853, -122.514725),
                         new Location(37.700121, -122.212601));
    }

   /*
    * Based on a north-west and south-east location pair, determine appropriate
    * map bounds in terms of tile grid, and inform the grid of an initial tile
    * coordinate and point by calling grid.setInitialTile().
    */
    private function setInitialExtent(northWest:Location, southEast:Location):Void
    {
        // get initial coordinates for geographical extent
        var NW:Coordinate = mapProvider.locationCoordinate(northWest);
        var SE:Coordinate = mapProvider.locationCoordinate(southEast);
        
        // get top left and bottom right coordinates for initial coordinates
        var TL:Coordinate = new Coordinate(Math.min(NW.row, SE.row), Math.min(NW.column, SE.column), Math.min(NW.zoom, SE.zoom));
        var BR:Coordinate = new Coordinate(Math.max(NW.row, SE.row), Math.max(NW.column, SE.column), Math.max(NW.zoom, SE.zoom));

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
        
        // tell grid what the rock is cooking
        grid.setInitialTile(initTileCoord, initPoint);
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
}