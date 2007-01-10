/**
 * Inspired by:
 *  http://twistedmatrix.com/documents/current/api/twisted.internet.base.DelayedCall.html
 */
class com.stamen.twisted.DelayedCall
{
    public var due:Number;
    public var func:Function;
    public var args:Array;
    
    private var cancelled:Boolean;

   /**
    * Construct delayed call with time due, function to call, and arguments to pass.
    */
    public function DelayedCall(d:Number, f:Function, a:Array)
    {
        due  = d;
        func = f;
        args = a;
        
        cancelled = false;
    }
    
   /**
    * Call previously-delated call.
    */
    public function call():Void
    {
        if(!cancelled)
            func.apply(undefined, args);
    }
    
   /**
    * Cancel not-yet-called, previously-delayed call.
    */
    public function cancel():Void
    {
        cancelled = true;
    }
}