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
		var url : String = "http://mt1.google.com/mt?n=404&v=w2.38" + getZoomString( coord );		
		return url; 
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
		var zoomString : String = "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + ( 17 - coord.zoom );
		return zoomString; 
	}	
}