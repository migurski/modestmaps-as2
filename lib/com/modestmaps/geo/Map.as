import mx.utils.Delegate;
import com.stamen.twisted.Reactor;

import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.MapProviderFactory;
import com.modestmaps.core.mapproviders.MapProviders;

class com.modestmaps.geo.Map extends MovieClip
{
    private var width:Number;
    private var height:Number;

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
        setMapProvider(mapProviderType);
    
        grid = TileGrid(attachMovie(TileGrid.symbolName, 'grid', getNextHighestDepth(),
                                    {mapProvider: mapProvider, _x: 0, _y: 0, width: width, height: height}));
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
        
        Reactor.callLater(5000, Delegate.create(this, this.nagAboutBoundsForever));
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
        grid.zoomIn(0.25);
    }
    
    public function zoomOut():Void
    {
        grid.zoomOut(0.25);
    }
}