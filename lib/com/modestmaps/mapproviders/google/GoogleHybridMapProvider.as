import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.events.IDispatchable;
import com.modestmaps.io.MapProviderPaintThrottledRequest;
import mx.utils.Delegate;
import com.modestmaps.mapproviders.google.GoogleAerialMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleHybridMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, IDispatchable 
{
	private var __gamp : GoogleAerialMapProvider;
	
	public function GoogleHybridMapProvider()
	{
		super();
		__gamp = new GoogleAerialMapProvider();
	}
	
	public function toString() : String
	{
		return "GoogleHybridMapProvider[]";
	}

	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		clip.createEmptyMovieClip( "bg", clip.getNextHighestDepth() );
		clip.createEmptyMovieClip( "overlay", clip.getNextHighestDepth() );
		
		var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip.bg, getBGTileUrl( coord ), coord );
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, Delegate.create( this, this.onRequestError ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, Delegate.create( this, this.onResponseComplete ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, Delegate.create( this, this.onResponseError ));
		request.send();

		request = new MapProviderPaintThrottledRequest( clip.overlay, getOverlayTileUrl( coord ), coord );
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, Delegate.create( this, this.onRequestError ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, Delegate.create( this, this.onResponseComplete ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, Delegate.create( this, this.onResponseError ));
		request.send();
		
		//createLabel( clip, coord.toString() );
	}	

	private function getBGTileUrl( coord : Coordinate ) : String
	{		
		return __gamp.getTileUrl( coord );
	}

	private function getOverlayTileUrl(coord:Coordinate):String
	{		
        var sourceCoord:Coordinate = sourceCoordinate(coord);
        var zoomString:String = "&x=" + sourceCoord.column + "&y=" + sourceCoord.row + "&zoom=" + (17 - sourceCoord.zoom);
		return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=w2t.39" + zoomString;
	}

	// Event Handlers
	
	private function onResponseComplete( eventObj : Object ) : Void
	{
		if ( eventObj.clip.bg._loaded && eventObj.clip.overlay._loaded )
			raisePaintComplete( eventObj.clip._parent, eventObj.coord );
	}
}