import com.modestmaps.core.mapproviders.AbstractMapProvider;
import com.modestmaps.core.Tile;
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
	
	public function paintTile( tile : Tile ) : Void 
	{
		super.paintTile( tile );
		
		__requestThrottler.enqueue( tile.displayClip.image, getTileUrl( tile ) );
		
		labelTile( tile, ( tile.origin ? "! " : "" ) + tile.toString() );
	}
	
	/*
	 * Abstract method, implemented by concrete subclass.
	 */
	private function getTileUrl( tile : Tile ) : String
	{
		return null;
	}

	private function getZoomString( tile : Tile ) : String
	{		
		// convert row + col to zoom string
		var rowBinaryString : String = BinaryUtil.convertToBinary( tile.coord.row );		
		rowBinaryString = rowBinaryString.substring( rowBinaryString.length - tile.coord.zoom );
		
		var colBinaryString : String = BinaryUtil.convertToBinary( tile.coord.column );
		colBinaryString = colBinaryString.substring( colBinaryString.length - tile.coord.zoom );

		// generate zoom string by combining strings
		var zoomString : String = "";
		for ( var i : Number = 0; i < tile.coord.zoom; i++ ) 
		{
			zoomString += BinaryUtil.convertToDecimal( rowBinaryString.charAt( i ) + colBinaryString.charAt( i ) ).toString();
		}
		
		return zoomString; 
	}
}
