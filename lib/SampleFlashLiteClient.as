import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Tile;

class SampleFlashLiteClient 
{
	public static function main(clip:MovieClip):Void
    {
    	clip._focusRect = false;
    	
        var grid:TileGrid = TileGrid(clip.attachMovie(TileGrid.symbolName, 'tile', clip.getNextHighestDepth(),
                                                      {_x: 0, _y: 0, width: Stage.width, height: Stage.height} ));


   		// Set up key listeners. 
   		// TODO: Ghetto. Make this much cleaner.
    	
    	var myListener:Object = new Object();
    	myListener.grid = grid;
		myListener.onKeyDown = function() 
		{
			switch ( Key.getCode() )
			{
				case Key.RIGHT:
					grid.panEast( Stage.width );
					break;	
				
				case Key.LEFT:
					grid.panWest( Stage.width );
					break;

				case Key.UP:
					grid.panNorth( Stage.height );
					break;	
				
				case Key.DOWN:
					grid.panSouth( Stage.height );
					break;
			}
		};
		Key.addListener(myListener);


        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(grid);
        
        Reactor.run(clip, null, 50);
    }
}