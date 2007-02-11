import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;
import com.modestmaps.events.IDispatchable;

/**
 * @author darren
 */

class com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, IDispatchable
{
	public function toString() : String
	{
		return "MicrosoftAerialMapProvider[]";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
        return "http://a" + Math.floor(Math.random() * 4) + ".ortho.tiles.virtualearth.net/tiles/a" + getZoomString( coord ) + ".jpeg?g=45";
	}
}