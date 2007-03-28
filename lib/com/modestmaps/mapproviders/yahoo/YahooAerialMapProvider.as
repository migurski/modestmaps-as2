import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooAerialMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, DispatchableInterface 
{
	public function toString() : String
	{
		return "YAHOO_AERIAL";
	}

	private function getTileUrl(coord:Coordinate):String
	{		
        return "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200605101500" + getZoomString(sourceCoordinate(coord));	
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
