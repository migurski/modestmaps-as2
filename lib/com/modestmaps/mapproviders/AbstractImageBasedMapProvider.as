/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author darren
 * @author migurski
 *
 * AbstractImageBasedMapProvider is the base class for all MapProviders
 * that use externally loaded images to paint Tiles.
 * 
 * @see com.modestmaps.mapproviders.AbstractMapProvider
 */
 
import com.stamen.twisted.Reactor;
import com.bigspaceship.utils.Delegate;
import com.modestmaps.core.Coordinate;
import com.modestmaps.io.MapProviderPaintThrottledRequest;
import com.modestmaps.mapproviders.AbstractMapProvider;

class com.modestmaps.mapproviders.AbstractImageBasedMapProvider 
extends AbstractMapProvider 
{
    public static var fadeSteps:Number = 3;

	/**
	 * Abstract constructor, should not be instantiated directly.
	 */
	function AbstractImageBasedMapProvider() 
	{
		super();
	}

	/**
	 * Generates a new MapProviderPaintThrottledRequest to load in an 
	 * external image.
	 * 
	 * @see com.modestmaps.mapproviders.AbstractMapProvider
 	 * @param clip The MovieClip to contain the graphics.
	 * @param coord The coordinate of the Tile that contains the clip.

	 */
	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		super.paint( clip, coord );
		
		clip.image._alpha = 0;
		
		var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip.image, getTileUrl( coord ), coord );
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, "onRequestError");
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, "onResponseComplete");
		request.addEventObserver( this, MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, "onResponseError");
		request.send();
		
		//createLabel( clip, coord.toString() );
	}

	/*
	 * Returns the url needed to get the tile image. 
	 */
	private function getTileUrl( coord : Coordinate ) : String
	{
		throw new Error( "Abstract method not implemented by subclass." );	
		return null;
	}

	// Event Handlers

	/**
	 * Event handler for MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR
	 */
	private function onRequestError( clip : MovieClip ) : Void
	{
	    paintFailure( clip );
	}
	
	private function fadeClipIn( clip : MovieClip) : Void
	{
	    if( clip._alpha + (100/fadeSteps) >= 100 )
	    {
	        clip._alpha = 100;
        }
        else
        {
            clip._alpha += (100/fadeSteps);
            Reactor.callNextFrame(Delegate.create(this, this.fadeClipIn), clip);
        }
	}
	
	/**
	 * Event handler for MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE
	 */
	private function onResponseComplete( clip : MovieClip, coordinate : Coordinate ) : Void
	{
	    fadeClipIn( clip );
		raisePaintComplete( clip, coordinate );
	}
	
	/**
	 * Event handler for MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR
	 */
	private function onResponseError( clip : MovieClip, errorCode : String, httpStatus : Number ) : Void
	{
	    fadeClipIn( clip );
	    paintFailure(clip);
	}		
	
	private function paintFailure(clip:MovieClip):Void
	{
	    // length of 'X' side, padding from edge, weight of 'X' symbol
	    var size:Number = 32;
	    var padding:Number = 4;
	    var weight:Number = 4;
	    
	    with(clip) {
	        clear();
	        
	        moveTo(0, 0);
	        beginFill(0x444444, 100);
	        lineTo(size, 0);
	        lineTo(size, size);
	        lineTo(0, size);
	        lineTo(0, 0);
	        endFill();
	        
	        moveTo(weight+padding, padding);
	        beginFill(0x888888, 100);
	        lineTo(padding, weight+padding);
	        lineTo(size-weight-padding, size-padding);
	        lineTo(size-padding, size-weight-padding);
	        lineTo(weight+padding, padding);
	        endFill();
	        
	        moveTo(size-weight-padding, padding);
	        beginFill(0x888888, 100);
	        lineTo(size-padding, weight+padding);
	        lineTo(weight+padding, size-padding);
	        lineTo(padding, size-weight-padding);
	        lineTo(size-weight-padding, padding);
	        endFill();
	    }
	}		
}