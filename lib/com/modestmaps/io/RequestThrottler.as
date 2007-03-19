import com.bigspaceship.utils.Delegate;
import com.modestmaps.io.IRequest;
import com.modestmaps.io.ThrottledRequest;

/**
 * Used to limit the number of requests per frame.
 * 
 * @author darren
 */
 
class com.modestmaps.io.RequestThrottler 
{
	private static var __instance : RequestThrottler;
	
	private var __queue : /*IRequest*/Array;
		
	// How often do we want to process requests?
	private var __throttleSpeedMS : Number = 100;

	// How many requests do we process for each throttle tick?
	private var __requestsPerCycle : Number = 5;
	
	private var __throttleTimer : Number;
	
	public var loader : MovieClipLoader;
	
	/* 
	 * Singleton, use getInstance().
	 */
	private function RequestThrottler()
	{
		__queue = new Array();
		
		startQueue();
	}
	
	public function toString() : String
	{
		return "RequestThrottler[]";	
	}
	
	/*
	 * Returns an instance of the RequestQueue.
	 * 
	 * @return The RequestQueue singleton.
	 */
	public static function getInstance() : RequestThrottler
	{
		if ( __instance == undefined ) __instance = new RequestThrottler();
		return __instance;
	}
	
	
	public function enqueue( request : IRequest ) : Void
	{
		__queue.push( request );
	}
	
	// Private Methods

	private function processQueue() : Void
	{
		var count = __requestsPerCycle;
		while ( __queue.length > 0 && count-- )
		{
			var request : IRequest = IRequest( __queue.shift() );
			request.execute(); 

			if ( request.isBlocking() )
			{
				// we don't care what the response was, just that it's done blocking. let the primary listener
				// handle errors
				request.addEventObserver( this, ThrottledRequest.EVENT_REQUEST_ERROR, "onBlockingRequestComplete");
				request.addEventObserver( this, ThrottledRequest.EVENT_RESPONSE_COMPLETE, "onBlockingRequestComplete");
				request.addEventObserver( this, ThrottledRequest.EVENT_RESPONSE_ERROR, "onBlockingRequestComplete");
				
				// stop the queue and wait for resolution.
				stopQueue();		
				break;
			}
		}
	}
	
	/**
	 * Stops queue execution.
	 */
	private function stopQueue() : Void
	{
		clearInterval( __throttleTimer );
		delete __throttleTimer;
	}
	
	/**
	 * Starts queue execution.
	 */
	private function startQueue() : Void
	{
		if ( __throttleTimer == undefined )
			__throttleTimer = setInterval( Delegate.create( this, this.onThrottleTimer ), __throttleSpeedMS );	
	}
	
	// Event Handlers
	
	private function onThrottleTimer() : Void
	{
		processQueue();
	}
	
	private function onBlockingRequestComplete() : Void
	{
		startQueue();
	}
	
}