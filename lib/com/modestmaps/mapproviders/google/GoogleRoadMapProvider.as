import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.events.IDispatchable;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleRoadMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, IDispatchable 
{
	public function toString() : String
	{
		return "GoogleRoadMapProvider[]";
	}

	private function getTileUrl( coord : Coordinate ) : String
	{		
		return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=w2.43" + getZoomString(sourceCoordinate(coord));		
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{
        return "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + (17 - coord.zoom);
	}	
}