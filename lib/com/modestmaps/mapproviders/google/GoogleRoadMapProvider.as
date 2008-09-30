import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
 * @author darren
 * $Id$
 */
class com.modestmaps.mapproviders.google.GoogleRoadMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, DispatchableInterface 
{
	public function toString() : String
	{
		return "GOOGLE_ROAD";
	}

	private function getTileUrl( coord : Coordinate ) : String
	{		
		// TODO: http://mt1.google.com/mt?v=w2.83&hl=en&x=10513&s=&y=25304&z=16&s=Gal
		return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __roadVersion + getZoomString(sourceCoordinate(coord));		
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{
        return "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + (17 - coord.zoom);
	}	
}
