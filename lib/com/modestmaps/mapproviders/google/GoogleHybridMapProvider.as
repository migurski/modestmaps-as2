import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.io.MapProviderPaintThrottledRequest;
import com.modestmaps.mapproviders.google.AbstractGoogleMapProvider;
import com.modestmaps.mapproviders.google.GoogleAerialMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.google.GoogleHybridMapProvider 
extends AbstractGoogleMapProvider 
implements IMapProvider, DispatchableInterface 
{
	private var __gamp : GoogleAerialMapProvider;
	
	public function GoogleHybridMapProvider()
	{
		super();
		__gamp = new GoogleAerialMapProvider();
	}
	
	public function toString() : String
	{
		return "GOOGLE_HYBRID";
	}

	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		checkVersionRequested();
		
		if ( __hybridVersion != undefined )
		{		
			clip.createEmptyMovieClip( "bg", clip.getNextHighestDepth() );
			clip.createEmptyMovieClip( "overlay", clip.getNextHighestDepth() );
			
			clip.bg._alpha = 0;
			
			var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip.bg, getBGTileUrl( coord ), coord );
			request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, "onRequestError" );
			request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, "onBackgroundComplete");
			request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, "onResponseError" );
			request.send();
		}
		else
		{
			enqueuePaintRequest( clip, coord );
		}
	}	

	private function getBGTileUrl( coord : Coordinate ) : String
	{		
		return __gamp.getTileUrl( coord );
	}

	private function getOverlayTileUrl(coord:Coordinate):String
	{		
        var sourceCoord:Coordinate = sourceCoordinate(coord);
        var zoomString:String = "&x=" + sourceCoord.column + "&y=" + sourceCoord.row + "&zoom=" + (17 - sourceCoord.zoom);
		return "http://mt" + Math.floor(Math.random() * 4) + ".google.com/mt?n=404&v=" + __hybridVersion + zoomString;
	}

	// Event Handlers
	
	private function onBackgroundComplete( clip : MovieClip, coord : Coordinate ) : Void
	{
	    fadeClipIn( clip );
	    clip._parent.overlay._alpha = 0;

        var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip._parent.overlay, getOverlayTileUrl( coord ), coord );
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, "onRequestError" );
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, "onResponseComplete");
        request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, "onResponseError" );
        request.send();
	}
	
	private function onResponseComplete( clip : MovieClip, coordinate : Coordinate ) : Void
	{
	    fadeClipIn( clip );

		if ( clip.bg._loaded && clip.overlay._loaded )
			raisePaintComplete( clip._parent, coordinate );
	}
}
