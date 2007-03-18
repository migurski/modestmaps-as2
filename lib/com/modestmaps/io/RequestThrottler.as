import com.bigspaceship.utils.Delegate;
import com.modestmaps.io.IRequest;

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
		
		__throttleTimer = setInterval( Delegate.create( this, this.onThrottleTimer ), __throttleSpeedMS );	
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
		}
	}
	
	// Event Handlers
	
	private function onThrottleTimer() : Void
	{
		processQueue();
	}
}