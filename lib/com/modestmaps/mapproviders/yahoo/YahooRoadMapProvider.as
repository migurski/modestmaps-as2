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

	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = "http://us.maps1.yimg.com/us.tile.maps.yimg.com/tile?md=200608221700" 
			+ getZoomString( coord );	
			
		return url; 
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
        var row : Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;

		var zoomString : String = "&col=" + coord.column + "&row=" + row + "&z=" + ( 18 - coord.zoom );
		return zoomString; 
	}	
}