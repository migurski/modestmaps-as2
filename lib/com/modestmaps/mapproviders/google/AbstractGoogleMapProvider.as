import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;
import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
import com.modestmaps.io.XmlThrottledRequest;

/**
 * @author darren
 * $Id$
 */
class com.modestmaps.mapproviders.google.AbstractGoogleMapProvider 
extends AbstractImageBasedMapProvider 
{
	private var __paintQueue : Array;

    // Google often updates its tiles and expires old sets.
    // This a way to determine the newest version numbers.
	private static var __versionSource:String = "google_version.xml";
	private static var __roadVersion:String;
	private static var __hybridVersion:String;
	private static var __aerialVersion:String;

	private static var __versionRequested:Boolean = false;
	
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
		
		if ( __roadVersion != undefined && __hybridVersion != undefined && __aerialVersion != undefined )
			super.paint( clip, coord );
		else
			enqueuePaintRequest( clip, coord );					
	}
	
	// Private Methods
	
	private function checkVersionRequested()
	{
		if ( !AbstractGoogleMapProvider.__versionRequested )
		{
			trace ("  checkVersionRequested(): " + AbstractGoogleMapProvider.__versionRequested );
			// we need to create a blocking request to load our version number
			AbstractGoogleMapProvider.__versionRequested = true;
		
			__paintQueue = new Array();

			var request : XmlThrottledRequest = new XmlThrottledRequest( __versionSource, true );
			request.addEventObserver( this, XmlThrottledRequest.EVENT_RESPONSE_COMPLETE, "onVersionResponseComplete" );
			request.addEventObserver( this, XmlThrottledRequest.EVENT_RESPONSE_COMPLETE, "onVersionResponseError" );
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

	// Event Handlers
	
	private function onVersionResponseComplete( xml : XML ) : Void
	{
        __roadVersion = xml.firstChild.attributes.road;
        __hybridVersion = xml.firstChild.attributes.hybrid;
        __aerialVersion = xml.firstChild.attributes.aerial;

		processQueue();
	}
	
	private function onVersionResponseError() : Void
	{
	    // now what?
	}		
	
}