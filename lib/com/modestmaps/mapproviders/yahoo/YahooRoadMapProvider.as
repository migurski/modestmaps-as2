import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooRoadMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, DispatchableInterface 
{	
	public function toString() : String
	{
		return "YAHOO_ROAD";
	}

	private function getTileUrl(coord:Coordinate):String
	{		
        return "http://us.maps2.yimg.com/us.png.maps.yimg.com/png?v=3.52&t=m" + getZoomString(sourceCoordinate(coord));
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
        var row : Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;
        return "&x=" + coord.column + "&y=" + row + "&z=" + (18 - coord.zoom);
	}	
}
