import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.io.MapProviderPaintThrottledRequest;
import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.yahoo.YahooHybridMapProvider 
extends AbstractYahooMapProvider 
implements IMapProvider, DispatchableInterface 
{
	public function toString() : String
	{
		return "YAHOO_HYBRID";
	}
	
	/**
	 * Yahoo clips are 258x258 to deal with Flash pixel fudge, we mask and offset them by
	 * one pixel so they show up correctly.
	 */
	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		clip.createEmptyMovieClip( "bg", clip.getNextHighestDepth() );
		clip.createEmptyMovieClip( "overlay", clip.getNextHighestDepth() );
		
		var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip.bg, getBGTileUrl( coord ), coord );
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, "onRequestError" );
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, "onBackgroundComplete");
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, "onResponseError" );
		request.send();
		
		clip.bg._x = clip.bg._y = -.5;
		clip.overlay._x = clip.overlay._y = -.5;

		createMask( clip );		
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

	private function isClipLoaded( clip : MovieClip ) : Boolean
	{
		return ( clip.getBytesTotal() > 0 && clip.getBytesLoaded() == clip.getBytesTotal() );
	}

	// Event Handlers
	
	private function onBackgroundComplete( clip : MovieClip, coord : Coordinate ) : Void
	{
        var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip._parent.overlay, getOverlayTileUrl( coord ), coord );
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, "onRequestError" );
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, "onResponseComplete");
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, "onResponseError" );
        request.send();
	}
	
	private function onResponseComplete( clip : MovieClip, coordinate : Coordinate ) : Void
	{
		// HAKT
		var bgClip : MovieClip = clip._parent.bg;
		var overlayClip : MovieClip = clip._parent.overlay;
		
		if ( isClipLoaded( bgClip ) && isClipLoaded( overlayClip ) )
		{
			raisePaintComplete( clip._parent, coordinate );
		}
	}
}
