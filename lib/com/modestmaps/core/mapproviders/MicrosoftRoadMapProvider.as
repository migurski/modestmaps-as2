import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.events.IDispatchable;


/**
 * @author darren
 */

class com.modestmaps.core.mapproviders.MicrosoftRoadMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, IDispatchable
{
	private static var BASE_URL : String = "http://r3.ortho.tiles.virtualearth.net/tiles/r";
	private static var ASSET_EXTENSION : String = ".png";
		
	public function toString() : String
	{
		return "MicrosoftRoadMapProvider[]";
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