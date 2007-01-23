/**
 * @author darren
 */
interface com.modestmaps.events.IDispatchable 
{
	public function dispatchEvent( eventObj : Object ) : Void;
	public function addEventListener( type : String, handler ) : Void;
	public function removeEventListener( type : String, handler ) : Void;
}