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
        return "http://us.maps1.yimg.com/us.tile.maps.yimg.com/tile?md=200608221700" + getZoomString(sourceCoordinate(coord));	
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
        var row : Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;

		var zoomString : String = "&col=" + coord.column + "&row=" + row + "&z=" + ( 18 - coord.zoom );
		return zoomString; 
	}	
}
