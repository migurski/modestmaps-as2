import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Tile;
import com.modestmaps.util.BinaryUtil;

/**
 * @author darren
 */

class com.modestmaps.core.mapproviders.MicrosoftDelayedAerialMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider 
{
	private static var BASE_URL : String = "http://modestmap.com/proxy/index.php/a";
		
	public function toString() : String
	{
		return "MicrosoftDelayedAerialMapProvider[]";
	}
	
	private function getTileUrl( tile : Tile ) : String
	{		
		var url : String = BASE_URL + getZoomString( tile ) + ".jpeg";
		
		//trace (this + ": Mapped " + tile.toString() + " to URL: " + url);
		
		return url; 
	}
}