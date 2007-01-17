import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
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
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = BASE_URL + getZoomString( coord ) + ".jpeg?g=45";
		
		//trace (this + ": Mapped " + tile.toString() + " to URL: " + url);
		
		return url; 
	}
}