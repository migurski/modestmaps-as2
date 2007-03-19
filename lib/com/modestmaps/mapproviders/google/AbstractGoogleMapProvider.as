import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;
import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
import com.modestmaps.io.XmlThrottledRequest;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.AbstractGoogleMapProvider 
extends AbstractImageBasedMapProvider 
{
	private var __paintQueue : Array;

	public static var AERIAL_VERSION_NUM : String;
	public static var HYBRID_VERSION_NUM : String;
	public static var ROAD_VERSION_NUM : String;

	private static var __VERSION_NUM_REQUESTED : Boolean = false;
	
	function AbstractGoogleMapProvider() 
	{
		super();

	    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
	}

    public function sourceCoordinate(coord:Coordinate):Coordinate
    {
	    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);

	    while(wrappedColumn < 0)
	        wrappedColumn += Math.pow(2, coord.zoom);
	        
        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
    }
    
    public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		checkVersionRequested();
		
		if ( versionNum != undefined )		
			super.paint( clip, coord );
		else
			enqueuePaintRequest( clip, coord );					
	}
	
	// Private Methods
	
	private function checkVersionRequested()
	{
		if ( !AbstractGoogleMapProvider.__VERSION_NUM_REQUESTED )
		{
			trace ("  checkVersionRequested(): " + AbstractGoogleMapProvider.__VERSION_NUM_REQUESTED );
			// we need to create a blocking request to load our version number
			AbstractGoogleMapProvider.__VERSION_NUM_REQUESTED = true;
		
			__paintQueue = new Array();

			var request : XmlThrottledRequest = new XmlThrottledRequest( "google_version.xml", true );
			request.addEventObserver( this, XmlThrottledRequest.EVENT_RESPONSE_COMPLETE, "onVersionNumResponseComplete" );
			request.addEventObserver( this, XmlThrottledRequest.EVENT_RESPONSE_COMPLETE, "onVersionNumResponseError" );
			request.send();
		}
	}
	
	private function enqueuePaintRequest( clip : MovieClip, coord : Coordinate )
	{
		__paintQueue.push( { clip : clip, coord : coord } );
	}
	
	private function processQueue() : Void
	{
		var paintRequest : Object;
		while ( __paintQueue.length )
		{
			paintRequest = __paintQueue.shift();
			paint( paintRequest.clip, paintRequest.coord ); 	
		}
	}
	
	public function get versionNum() : String
	{
		throw new Error( "Abstract method, not implemented" );
		return null;
	}
	
	// Event Handlers
	
	private function onVersionNumResponseComplete( xml : XML ) : Void
	{
		var atts : Object = xml.firstChild.attributes;

		AERIAL_VERSION_NUM = atts.aerialVersionNum;
		HYBRID_VERSION_NUM = atts.hybridVersionNum;
		ROAD_VERSION_NUM = atts.roadVersionNum;
		processQueue();
	}
	
	private function onVersionNumResponseError() : Void
	{
	    // now what?
	}		
	
}