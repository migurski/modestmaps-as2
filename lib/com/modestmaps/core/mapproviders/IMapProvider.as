/**
 * @author darren
 */
import com.modestmaps.core.Tile; 
 
interface com.modestmaps.core.mapproviders.IMapProvider 
{
	public function paintTile( tile : Tile ) : Void;
}