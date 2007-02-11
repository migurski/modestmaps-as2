import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.events.IDispatchable;


/**
 * @author darren
 */

class com.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider 
extends AbstractMicrosoftMapProvider
implements IMapProvider, IDispatchable
{
	public function toString() : String
	{
		return "MicrosoftRoadMapProvider[]";
	}
	
	private function getTileUrl( coord : Coordinate ) : String
	{		
        return "http://r" + Math.floor(Math.random() * 4) + ".ortho.tiles.virtualearth.net/tiles/r" + getZoomString( coord ) + ".png?g=45";
	}
}