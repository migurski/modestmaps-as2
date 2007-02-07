import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.microsoft.AbstractMicrosoftMapProvider 
extends AbstractImageBasedMapProvider 
{
	public static var BASE_URL : String;
	public static var ASSET_EXTENSION : String;
	
	function AbstractMicrosoftMapProvider() 
	{
		super();

	    // see: http://track.stamen.com/modestmap/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
		// convert row + col to zoom string
		var rowBinaryString : String = BinaryUtil.convertToBinary( coord.row );		
		rowBinaryString = rowBinaryString.substring( rowBinaryString.length - coord.zoom );
		
		var colBinaryString : String = BinaryUtil.convertToBinary( coord.column );
		colBinaryString = colBinaryString.substring( colBinaryString.length - coord.zoom );

		// generate zoom string by combining strings
		var zoomString : String = "";
		for ( var i : Number = 0; i < coord.zoom; i++ ) 
		{
			zoomString += BinaryUtil.convertToDecimal( rowBinaryString.charAt( i ) + colBinaryString.charAt( i ) ).toString();
		}
		
		return zoomString; 
	}
	
	/*
	 * Given a URL, returns the coordinates that the URL refers to.
	 */
	private function getCoordinateFromURL( url : String ) : Coordinate
	{
		var row, col, zoom : Number;
		
		// first locate the meaty bits (i.e. the zoomString).
		var zoomString : String = url.substring( baseUrl.length );
		zoomString = zoomString.substring( 0, zoomString.indexOf( assetExtension ) );

		// now work backwards to determine row and col
		zoom = zoomString.length;
	
		var rowStr : String = "";
		var colStr : String = "";
		var tempStr : String = "";
		
		for ( var i : Number = 0; i < zoom; i++ )
		{
			tempStr = BinaryUtil.convertToBinary( parseInt( zoomString.charAt( i ) ) );
			colStr += tempStr.charAt( tempStr.length-1 );
			rowStr += tempStr.charAt( tempStr.length-2 );
		}
				
		row = BinaryUtil.convertToDecimal( rowStr );
		col = BinaryUtil.convertToDecimal( colStr );
		
		var coord : Coordinate = new Coordinate( row, col, zoom );
		return coord;
	}
}
