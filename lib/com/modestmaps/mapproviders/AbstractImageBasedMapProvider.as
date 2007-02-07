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
	}		
}