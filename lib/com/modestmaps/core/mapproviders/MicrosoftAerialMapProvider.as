import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;

/**
 * @author darren
 */

class com.modestmaps.core.mapproviders.MicrosoftAerialMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider 
{
	private static var BASE_URL : String = "http://a0.ortho.tiles.virtualearth.net/tiles/a";
		
	public function toString() : String
	{
		return "MicrosoftAerialMapProvider[]";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = BASE_URL + getZoomString( coord ) + ".jpeg?g=45";
		
		//trace (this + ": Mapped " + coord.toString() + " to URL: " + url);
		
		return url; 
	}
}