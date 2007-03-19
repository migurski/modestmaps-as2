import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleRoadMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, DispatchableInterface 
{
	public function toString() : String
	{
		return "GoogleRoadMapProvider[]";
	}

	private function getTileUrl( coord : Coordinate ) : String
	{		
		return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + versionNum + getZoomString(sourceCoordinate(coord));		
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{
        return "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + (17 - coord.zoom);
	}	
	
	public function get versionNum() : String
	{
		return AbstractGoogleMapProvider.ROAD_VERSION_NUM;
	}		
}