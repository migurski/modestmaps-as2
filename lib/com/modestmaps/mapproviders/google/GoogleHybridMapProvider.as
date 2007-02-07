import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.events.IDispatchable;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleHybridMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, IDispatchable 
{
	private static var BASE_URL : String = "http://mt1.google.com/mt?n=404&v=w2t.38";
	private static var ASSET_EXTENSION : String = "";

	public function toString() : String
	{
		return "GoogleHybridMapProvider[]";
	}

	public function get baseUrl() : String
	{
		return BASE_URL;	
	}

	public function get assetExtension() : String
	{
		return ASSET_EXTENSION;	
	}
			
	private function getTileUrl( coord : Coordinate ) : String
	{		
		var url : String = BASE_URL + getZoomString( coord );
		
		_level0.map.grid.log(this + ": Mapped " + coord.toString() + " to URL: " + url);
		
		return url; 
	}
	
	private function getZoomString( coord : Coordinate ) : String
	{		
		var zoomString : String = "&x=" + coord.column + "&y=" + coord.row + "&zoom=" + coord.zoom;
		return zoomString; 
	}	

	
	/*
	 * Given a URL, returns the coordinates that the URL refers to.
	 */
	private function getCoordinateFromURL( url : String ) : Coordinate
	{
		var row, col, zoom : Number;
		
		var zoombits : Array = url.split( "&" );
		
		col = parseInt( zoombits[2].split( '=' )[1] ); 
		row = parseInt( zoombits[3].split( '=' )[1] ); 
		zoom = parseInt( zoombits[4].split( '=' )[1] ); 
			
		var coord : Coordinate = new Coordinate( row, col, zoom );
		return coord;
	}
}