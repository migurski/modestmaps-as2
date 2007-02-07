import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.core.Coordinate;
import com.modestmaps.io.LoadMovieThrottledRequest;
import mx.utils.Delegate;
import com.modestmaps.util.BinaryUtil;
import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.AbstractGoogleMapProvider 
extends AbstractImageBasedMapProvider 
{
	public static var BASE_URL : String;
	public static var ASSET_EXTENSION : String;
	
	function AbstractGoogleMapProvider() 
	{
		super();

	    // see: http://track.stamen.com/modestmap/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
	}
}