import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.geo.Map;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.mapproviders.MapProviders;

class SampleClient
{
    public static function main(clip:MovieClip):Void
    {
        var map:Map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(),
                                           {mapProviderType: MapProviders.MICROSOFT_HYBRID, _x: 128, _y: 128, width: Stage.width - 256, height: Stage.height - 256}))
        
        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(map); 
        
        var plus:MovieClip = makeButton(clip, 'plus', 'zoom in', Delegate.create(map, map.zoomIn));
        var minus:MovieClip = makeButton(clip, 'minus', 'zoom out', Delegate.create(map, map.zoomOut));
        var clear:MovieClip = makeButton(clip, 'clear', 'clear log', Delegate.create(map.grid, map.grid.clearLog));

        plus._x = map._x;
        plus._y = map._y - plus['label']._height - 10;
        
        minus._x = plus._x + minus['label']._width + 4;
        minus._y = plus._y;
        
        clear._x = minus._x + clear['label']._width + 14;
        clear._y = minus._y;

        Reactor.run(clip, null, 50);
        Reactor.callNextFrame(Delegate.create(map, map.nagAboutBoundsForever));
    }
    
    public static function makeButton(clip:MovieClip, name:String, label:String, action:Function):MovieClip
    {
        var button:MovieClip = clip.createEmptyMovieClip(name, clip.getNextHighestDepth());
        
        button.createTextField('label', button.getNextHighestDepth(), 0, 0, 100, 100);
        button['label'].selectable = false;
        button['label'].textColor = 0xFFFFFF;
        button['label'].text = label;
        button['label']._width = button['label'].textWidth + 4;
        button['label']._height = button['label'].textHeight + 2;
        
        button.moveTo(0, 0);
        button.beginFill(0x000000, 100);
        button.lineTo(0, button['label']._height);
        button.lineTo(button['label']._width, button['label']._height);
        button.lineTo(button['label']._width, 0);
        button.lineTo(0, 0);
        button.endFill(0, 0);
        
        button.onRelease = action;
        
        return button;
    }
    
    public static function output( str : String ) : Void
    {
    	trace( str );	
    }
    
}
