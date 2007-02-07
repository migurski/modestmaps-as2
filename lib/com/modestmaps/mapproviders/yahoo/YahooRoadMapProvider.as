import com.modestmaps.core.Coordinate;
import com.modestmaps.events.IDispatchable;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooRoadMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, IDispatchable 
{	
	public function toString() : String
	{
		return "YahooRoadMapProvider[]";
	}

	
}