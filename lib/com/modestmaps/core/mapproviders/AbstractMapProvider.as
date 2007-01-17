import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.io.RequestThrottler;
import com.modestmaps.core.Tile;

/**
 * @author darren
 */
class com.modestmaps.core.mapproviders.AbstractMapProvider  
{
	private var __requestThrottler : RequestThrottler;

	private function AbstractMapProvider()
	{
		__requestThrottler = RequestThrottler.getInstance();	
	}

	public function paintTile(tile : Tile) : Void 
	{
		trace ("called paintTile for " + tile._name );
		
		clearTile( tile );
		
		tile.displayClip = tile.createEmptyMovieClip( "display" + tile.getNextHighestDepth(), tile.getNextHighestDepth() );
		tile.displayClip.createEmptyMovieClip( "image", tile.displayClip.getNextHighestDepth() );
	}

	public function labelTile( tile : Tile, label : String ) : Void
	{
		tile.displayClip.createTextField('labelTF', 1, tile.width/4, tile.height/2, tile.width/1.33, tile.height/2);
	    var tf : TextField = tile.displayClip["labelTF"];
	    tf.selectable = false;
	    tf.textColor = 0xFF0000;
		tf.text = label;	
	}

	private function clearTile( tile : Tile ) : Void
	{
		tile.displayClip.removeMovieClip();
	}
}