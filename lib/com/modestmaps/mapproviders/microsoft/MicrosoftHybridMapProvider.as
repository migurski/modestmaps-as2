import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;

/**
 * @author darren
 */

class com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, DispatchableInterface
{
	public function toString() : String
	{
		return "MICROSOFT_HYBRID";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
        return "http://h" + Math.floor(Math.random() * 4) + ".ortho.tiles.virtualearth.net/tiles/h" + getZoomString( coord ) + ".jpeg?g=45";
	}
}
