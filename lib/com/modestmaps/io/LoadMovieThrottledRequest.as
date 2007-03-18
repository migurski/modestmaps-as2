import com.modestmaps.io.IRequest;
import com.modestmaps.io.ThrottledRequest;

/**
 * @author darren
 */
class com.modestmaps.io.LoadMovieThrottledRequest 
extends ThrottledRequest 
implements IRequest
{
	public var clip : MovieClip;
	public var url : String;
	
	private var __loader : MovieClipLoader;
	
	public function LoadMovieThrottledRequest( clip : MovieClip, url : String ) 
	{
		super();
		this.clip = clip;
		this.url = url;
		
		__loader = new MovieClipLoader();
		__loader.addListener( this );
	}


	public function send() : Void
	{
		if ( clip == undefined || url == undefined || url == "" )
		{
			dispatchEvent( ThrottledRequest.EVENT_REQUEST_ERROR, clip );
			
			cleanup();
		}
		else
		{
			super.send();
		}			
	}

	/*
	 * To be called by the throttler.
	 */
	public function execute() : Void
	{
		__loader.loadClip( url, clip );
	}

	// Private Methods

	/*
	 * Cleans up after a request or response.
	 */
	private function cleanup() : Void
	{
		__loader.removeListener( this );
		__loader = undefined;
		delete __loader;
	}

	// Event Handlers
	
	private function onLoadComplete( clip : MovieClip, httpStatus : Number ) : Void
	{
		dispatchEvent( ThrottledRequest.EVENT_RESPONSE_COMPLETE, clip, url );
		
		cleanup();
	}
	
	private function onLoadError( clip : MovieClip, errorCode : String, httpStatus : Number ) : Void
	{
		dispatchEvent( ThrottledRequest.EVENT_RESPONSE_ERROR, clip, errorCode, httpStatus );
		
		cleanup();
	}
}