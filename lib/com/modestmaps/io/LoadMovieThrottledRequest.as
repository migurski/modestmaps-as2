import com.modestmaps.io.ThrottledRequest;
import com.modestmaps.io.RequestThrottler;
import com.modestmaps.io.IRequest;

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
			var eventObj : Object =
			{
				target : this,
				type : ThrottledRequest.EVENT_REQUEST_ERROR,
				clip : this.clip
			};
			dispatchEvent( eventObj );
			
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
		var eventObj : Object =
		{
			target : this,
			type : ThrottledRequest.EVENT_RESPONSE_COMPLETE,
			clip : clip,
			url : url
		};
		dispatchEvent( eventObj );
		
		cleanup();
	}
	
	private function onLoadError( clip : MovieClip, errorCode : String, httpStatus : Number ) : Void
	{
		var eventObj : Object =
		{
			target : this,
			type : ThrottledRequest.EVENT_RESPONSE_ERROR,
			errorCode : errorCode,
			httpStatus : httpStatus
		};
		dispatchEvent( eventObj );
		
		cleanup();
	}
}