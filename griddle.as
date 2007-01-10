import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Tile;

class griddle
{
    public static function main(clip:MovieClip):Void
    {
        var grid:TileGrid = TileGrid(clip.attachMovie(TileGrid.symbolName, 'tile', clip.getNextHighestDepth(),
                                                      {_x: 128, _y: 128, width: Stage.width - 256, height: Stage.height - 256}));

        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(grid);
        
        Reactor.run(clip, null, 50);
    }
}