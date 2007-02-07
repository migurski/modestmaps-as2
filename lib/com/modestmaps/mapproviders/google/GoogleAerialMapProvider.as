import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.events.IDispatchable;
import com.modestmaps.util.BinaryUtil;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleAerialMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, IDispatchable 
{
	public function toString() : String
	{
		return "GoogleAerialMapProvider[]";
	}

	private function getTileUrl( coord : Coordinate ) : String
	{
		return "http://kh0.google.com/kh?n=404&v=14&t=" + getZoomString(coord);		
	}
	
	private function getZoomString(coord:Coordinate):String
	{		
        var gCoord = new Coordinate((Math.pow(2, coord.zoom) - coord.row - 1),
                                    coord.column,
                                    coord.zoom + 1);

		// convert row + col to zoom string
		var rowBinaryString:String = BinaryUtil.convertToBinary(gCoord.row);
		rowBinaryString = rowBinaryString.substring(rowBinaryString.length - gCoord.zoom);
		
		var colBinaryString:String = BinaryUtil.convertToBinary(gCoord.column);
		colBinaryString = colBinaryString.substring(colBinaryString.length - gCoord.zoom);

		// generate zoom string by combining strings
		var urlChars:String = 'tsqr';
		var zoomString:String = "";

		for(var i:Number = 0; i < gCoord.zoom; i += 1)
		    zoomString += urlChars.charAt(BinaryUtil.convertToDecimal(rowBinaryString.charAt(i) + colBinaryString.charAt(i)));
                         
		return zoomString; 
	}
}