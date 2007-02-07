import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;
import com.modestmaps.events.IDispatchable;

/**
 * @author darren
 */

class com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, IDispatchable
{
	public function toString() : String
	{
		return "MicrosoftHybridMapProvider[]";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = "http://h1.ortho.tiles.virtualearth.net/tiles/h" + 
			getZoomString( coord ) + ".jpeg?g=45";		

		return url; 
	}
}