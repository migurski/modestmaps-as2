import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.IMapProvider;
import com.stamen.twisted.DelayedCall;

class com.modestmaps.core.TilePaintCall
extends com.stamen.twisted.DelayedCall
{
	// Events
	public static var EVENT_CANCELLED : String = "TilePaintCall cancelled";

    private var __call:DelayedCall;
    private var __mapProvider:IMapProvider;
    private var __tileCoord:Coordinate;

    public function TilePaintCall(call:DelayedCall, provider:IMapProvider, coord:Coordinate)
    {
        __call = call;
        __mapProvider = provider;
        __tileCoord = coord;
    }
    
    public function toString():String
    {
        return __mapProvider.toString() + ', ' + __tileCoord.toString(); 
    }
    
    public function match(provider:IMapProvider, coord:Coordinate):Boolean
    {
        return (__mapProvider == provider)
            && (__tileCoord.toString() == coord.toString());
    }
    
    public function pending():Boolean
    {
        return __call.pending();
    }
    
    public function cancel():Void
    {
        return __call.cancel();
    }
}