import com.modestmaps.events.IDispatchable;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;
import com.modestmaps.core.Coordinate;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooHybridMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, IDispatchable 
{
	public function toString() : String
	{
		return "YahooHybridMapProvider[]";
	}
}