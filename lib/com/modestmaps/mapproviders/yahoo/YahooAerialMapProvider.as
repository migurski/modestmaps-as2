import com.modestmaps.events.IDispatchable;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;
import com.modestmaps.core.Coordinate;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooAerialMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, IDispatchable 
{
	public function toString() : String
	{
		return "YahooAerialMapProvider[]";
	}

	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200605101500" 
			+ getZoomString( coord );	
			
		return url; 
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
        var row : Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;

		var zoomString : String = "&x=" + coord.column + 
			"&y=" + row + 
			"&z=" + ( 18 - coord.zoom ) +
			"&v=1.5&t=a";
		return zoomString; 
	}	
}