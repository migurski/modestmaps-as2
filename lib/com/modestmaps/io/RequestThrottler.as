import org.casaframework.time.EnterFrame;

/**
 * Used to limit the number of requests per frame.
 * 
 * @author darren
 */
 
class com.modestmaps.io.RequestThrottler 
{
	private static var __instance : RequestThrottler;
	
	private var __queue : /*Object*/Array;
	
	private var __frameEventSource : EnterFrame;
	
	private var maxActiveConnectionsPerFrame : Number = 5;

	public var loader : MovieClipLoader;
	
		/* 
	 * Singleton, use getInstance().
	 */
	private function RequestThrottler()
	{
		__queue = new Array();
		
		loader = new MovieClipLoader();
		loader.addListener( this );
			
		__frameEventSource = EnterFrame.getInstance();
		__frameEventSource.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, "handleEnterFrame");
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
	
	
	public function enqueue( clip : MovieClip, url : String ) : Void
	{
		// ensure no pending requests exist for the same clip
		var count : Number = __queue.length;
		for ( var i : Number = 0; i < count; i++ )
		{
			if ( MovieClip( __queue[i]["clip"] ) == clip )
			{
				trace ( this + ": enqueue(): overriding pending request for tile " + clip );
				__queue.splice( i, 1 );
				count--;
				i--;
			}	
		}
		
		trace ( this + ": enqueue(): queued " + clip );
		__queue.push( { clip : clip, url : url } );
	}
	
	// Private Methods

	private function processQueue() : Void
	{
		var count = maxActiveConnectionsPerFrame;
		while ( __queue.length > 0 && count-- )
		{
			var request : Object = __queue.shift();			
			request["clip"].loadMovie( request["url"].toString() ); 
		}
	}
	
	// Event Handlers
	
	private function handleEnterFrame() : Void
	{
		processQueue();
	}
}