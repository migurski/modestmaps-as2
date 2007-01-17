import com.modestmaps.core.mapproviders.AbstractMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;

/**
 * @author darren
 */
class com.modestmaps.core.mapproviders.AbstractMicrosoftMapProvider 
extends AbstractMapProvider 
{
	public static var BASE_URL : String;
	
	function AbstractMicrosoftMapProvider() 
	{
		super();
	}
	
	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		super.paint( clip, coord );
		
		__requestThrottler.enqueue( clip.image, getTileUrl( coord ) );
		
		createLabel( clip, coord.toString() );
	}
	
	/*
	 * Abstract method, implemented by concrete subclass.
	 */
	private function getTileUrl( coord : Coordinate ) : String
	{
		return null;
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
}
