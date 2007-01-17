/**
 * @author darren
 */
 
import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMapProvider;
import com.modestmaps.core.Tile;

class com.modestmaps.core.mapproviders.VanillaMapProvider 
extends AbstractMapProvider
implements IMapProvider 
{
	public function paintTile( tile : Tile ) : Void 
	{
		super.paintTile( tile );

		with ( tile.displayClip )
		{
			clear();
		    moveTo(0, 0);
		    lineStyle(0, 0x0099FF, 100);
		    beginFill(0x000000, 20);
		    lineTo(0, tile.height);
		    lineTo(tile.width, tile.height);
		    lineTo(tile.width, 0);
		    lineTo(0, 0);
		    endFill();
		}

	    labelTile( tile, ( tile.origin ? "! " : "" ) + tile.toString() );

		// TODO: Fire even when paint is done.
	}
}