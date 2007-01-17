import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Tile;
import com.modestmaps.core.mapproviders.MapProviders;

class SampleClient
{
    public static function main(clip:MovieClip):Void
    {
        var grid:TileGrid = TileGrid(clip.attachMovie(TileGrid.symbolName, 'tile', clip.getNextHighestDepth(),
                                                      {mapProviderType: MapProviders.MICROSOFT_AERIAL, _x: 128, _y: 128, width: Stage.width - 256, height: Stage.height - 256}));

        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(grid);
        
        var plus:MovieClip = makeButton(clip, 'plus', 'zoom in', Delegate.create(grid, grid.startZoomIn));
        var minus:MovieClip = makeButton(clip, 'minus', 'zoom out', Delegate.create(grid, grid.startZoomOut));
        var clear:MovieClip = makeButton(clip, 'clear', 'clear log', Delegate.create(grid, grid.clearLog));

        plus._x = grid._x;
        plus._y = grid._y - plus['label']._height - 10;
        
        minus._x = plus._x + minus['label']._width + 4;
        minus._y = plus._y;
        
        clear._x = minus._x + clear['label']._width + 14;
        clear._y = minus._y;

        Reactor.run(clip, null, 50);
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
