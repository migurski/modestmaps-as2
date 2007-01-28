import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.stamen.twisted.DelayedCall;

import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;
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