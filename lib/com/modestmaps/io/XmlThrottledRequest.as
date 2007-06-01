import com.modestmaps.io.IRequest;
import com.modestmaps.io.ThrottledRequest;
import com.bigspaceship.utils.Delegate;

/**
 * @author darren
 * $Id$
 */
class com.modestmaps.io.XmlThrottledRequest 
extends ThrottledRequest 
implements IRequest 
{
	private var __xml : XML;
	
	public var url : String;
	
	public function XmlThrottledRequest( url : String, blocking : Boolean ) 
	{
		super( blocking );
		
		this.url = url;
	}

	public function send() : Void 
	{
		if ( url == undefined || url == "" )
		{
			dispatchEvent( ThrottledRequest.EVENT_REQUEST_ERROR, url );
		}
		else
		{
			super.send();
		}			
	}

	public function execute() : Void 
	{
		__xml = new XML();
		__xml.ignoreWhite = true;
		__xml.onLoad = Delegate.create( this, this.onXmlLoaded );
		__xml.load( url );
	}

	private function onXmlLoaded( success : Boolean ) : Void
	{
		if ( success )
			dispatchEvent( ThrottledRequest.EVENT_RESPONSE_COMPLETE, __xml );
		else
			dispatchEvent( ThrottledRequest.EVENT_RESPONSE_ERROR );
	}
}