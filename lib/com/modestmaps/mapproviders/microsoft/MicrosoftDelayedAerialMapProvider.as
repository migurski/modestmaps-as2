import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;
import com.modestmaps.events.IDispatchable;

/**
 * @author darren
 */

class com.modestmaps.mapproviders.microsoft.MicrosoftDelayedAerialMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, IDispatchable
{
	private static var BASE_URL : String = "http://modestmap.com/proxy/index.php/a";
	private static var ASSET_EXTENSION : String = ".jpeg";
		
	public function toString() : String
	{
		return "MicrosoftDelayedAerialMapProvider[]";
	}
	
	public function get baseUrl() : String
	{
		return BASE_URL;	
	}

	public function get assetExtension() : String
	{
		return ASSET_EXTENSION;	
	}
			
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = BASE_URL + getZoomString( coord ) + ASSET_EXTENSION + "?g=45";		
		
		//trace (this + ": Mapped " + tile.toString() + " to URL: " + url);
		
		return url; 
	}
}