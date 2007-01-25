import mx.events.EventDispatcher;
import com.modestmaps.io.RequestThrottler;
import com.modestmaps.io.IRequest;

/**
 * @author darren
 */
class com.modestmaps.io.ThrottledRequest 
implements IRequest
{
	// tracks if we're set up to broadcast events
	private static var __dispatcherInited : Boolean = false;
	
	// Events
	public static var EVENT_REQUEST_ERROR : String = "onRequestError";
	public static var EVENT_RESPONSE_COMPLETE : String = "onResponseComplete";
	public static var EVENT_RESPONSE_ERROR : String = "onResponseError";
	
	// stubs for EventDispatcher
	public var dispatchEvent : Function;
	public var addEventListener : Function;
	public var removeEventListener : Function;
	
	public function ThrottledRequest()
	{
		// only set up broadcasting once, in the prototype
		if ( !__dispatcherInited )
		{		
			EventDispatcher.initialize( this.__proto__ );
			__dispatcherInited = true;
		}
	}
	
	/*
	 * Called by the invoker when we the request is to be started.
	 */
	public function send() : Void
	{
		var throttler : RequestThrottler = RequestThrottler.getInstance();
		throttler.enqueue( this );
	}	
	
	/*
	 * Abstract method, to be implemented by subclass.
	 */
	public function execute() : Void
	{
		throw new Error( "Abstract method not implemented by subclass." );	
	}
}