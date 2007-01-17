import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;


/**
 * @author darren
 */

class com.modestmaps.core.mapproviders.MicrosoftRoadMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider 
{
	private static var BASE_URL : String = "http://r3.ortho.tiles.virtualearth.net/tiles/r";
		
	public function toString() : String
	{
		return "MicrosoftRoadMapProvider[]";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = BASE_URL + getZoomString( coord ) + ".png?g=45";
		
		//trace (this + ": Mapped " + tile.toString() + " to URL: " + url);
		
		return url; 
	}
}