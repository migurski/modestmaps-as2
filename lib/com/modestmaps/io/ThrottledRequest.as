import org.casaframework.event.EventDispatcher;

import com.modestmaps.io.IRequest;
import com.modestmaps.io.RequestThrottler;

/**
 * @author darren
 */
class com.modestmaps.io.ThrottledRequest 
extends EventDispatcher
implements IRequest
{
	// Events
	public static var EVENT_REQUEST_ERROR : String = "onRequestError";
	public static var EVENT_RESPONSE_COMPLETE : String = "onResponseComplete";
	public static var EVENT_RESPONSE_ERROR : String = "onResponseError";
	
	private var __blocking : Boolean;
	
	public function ThrottledRequest( blocking : Boolean )
	{
		__blocking = blocking != null ? blocking : false;
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
	
	public function isBlocking() : Boolean
	{
		return __blocking;	
	}
}