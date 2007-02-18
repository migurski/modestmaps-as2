import com.modestmaps.events.IDispatchable;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.io.MapProviderPaintThrottledRequest;
import mx.utils.Delegate;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooHybridMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, IDispatchable 
{
	public function toString() : String
	{
		return "YahooHybridMapProvider[]";
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

	private function getBGTileUrl(coord:Coordinate):String
	{		
		return "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200605101500" + getZoomString(sourceCoordinate(coord)) + "&v=1.5&t=a";
	}

	private function getOverlayTileUrl(coord:Coordinate):String
	{		
        return "http://us.maps3.yimg.com/aerial.maps.yimg.com/img?md=200608221700&v=2.0&t=h" + getZoomString(sourceCoordinate(coord));
	}
	
	
	private function getZoomString( coord : Coordinate ) : String
	{		
        var row : Number = ( Math.pow( 2, coord.zoom ) /2 ) - coord.row - 1;

		var zoomString : String = "&x=" + coord.column + 
			"&y=" + row + 
			"&z=" + ( 18 - coord.zoom );
		return zoomString; 
	}	

	// Event Handlers
	
	private function onResponseComplete( eventObj : Object ) : Void
	{
		if ( eventObj.clip.bg._loaded && eventObj.clip.overlay._loaded )
			raisePaintComplete( eventObj.clip._parent, eventObj.coord );
	}
}