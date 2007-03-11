import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.io.LoadMovieThrottledRequest;
import mx.utils.Delegate;
import com.modestmaps.io.MapProviderPaintThrottledRequest;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.AbstractImageBasedMapProvider 
extends AbstractMapProvider 
{
	
	function AbstractImageBasedMapProvider() {
		super();
	}

	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		super.paint( clip, coord );
		
		var request : MapProviderPaintThrottledRequest = new MapProviderPaintThrottledRequest( clip.image, getTileUrl( coord ), coord );
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_REQUEST_ERROR, Delegate.create( this, this.onRequestError ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_COMPLETE, Delegate.create( this, this.onResponseComplete ));
		request.addEventListener( MapProviderPaintThrottledRequest.EVENT_RESPONSE_ERROR, Delegate.create( this, this.onResponseError ));
		request.send();
		
		//createLabel( clip, coord.toString() );
	}

	/*
	 * Returns the value of BASE_URL for the class.
	 */
	public function get baseUrl() : String
	{
		throw new Error( "Abstract method not implemented by subclass." );	
		return null;
	}

	/*
	 * Returns the value of ASSET_EXTENSION for the class.
	 */
	public function get assetExtension() : String
	{
		throw new Error( "Abstract method not implemented by subclass." );	
		return null;	
	}

	
	/*
	 * Returns the url needed to get the tile image. 
	 */
	private function getTileUrl( coord : Coordinate ) : String
	{
		throw new Error( "Abstract method not implemented by subclass." );	
		return null;
	}

	/*
	 * Given a URL, returns the coordinates that the URL refers to.
	 */
	private function getCoordinateFromURL( url : String ) : Coordinate
	{
		throw new Error( "Abstract method not implemented by subclass." );	
		return null;
	}
	
	// Event Handlers

	private function onRequestError( eventObj : Object ) : Void
	{
	}
	
	private function onResponseComplete( eventObj : Object ) : Void
	{
		raisePaintComplete( eventObj.clip, eventObj.coord );
	}
	
	private function onResponseError( eventObj : Object ) : Void
	{
	    // length of 'X' side, padding from edge, weight of 'X' symbol
	    var size:Number = 32;
	    var padding:Number = 4;
	    var weight:Number = 4;

	    var clip:MovieClip = eventObj.clip;
	    
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