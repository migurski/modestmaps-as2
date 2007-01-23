/**
 * Inspired by:
 *  http://twistedmatrix.com/documents/current/api/twisted.internet.base.DelayedCall.html
 */
class com.stamen.twisted.DelayedCall
{
    public var due:Number;
    public var func:Function;
    public var args:Array;
    
    private var called:Boolean;
    private var cancelled:Boolean;

   /**
    * Construct delayed call with time due, function to call, and arguments to pass.
    */
    public function DelayedCall(d:Number, f:Function, a:Array)
    {
        due  = d;
        func = f;
        args = a;
        
        called = false;
        cancelled = false;
    }
    
   /**
    * Call previously-delayed call.
    */
    public function call():Void
    {
        try {
            if(pending())
                func.apply(undefined, args);
        } catch(e) {
            // do nothing
        }
            
        called = true;
    }
    
   /**
    * Cancel not-yet-called, previously-delayed call.
    */
    public function cancel():Void
    {
        cancelled = true;
    }
    
   /**
    * Check if this call is still pending.
    */
    public function pending():Boolean
    {
        return !called && !cancelled;
    }
}