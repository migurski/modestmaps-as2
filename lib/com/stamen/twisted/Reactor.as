/**
 * @author migurski
 *
 * com.stamen.twisted.Reactor is inspired by the Reactor class of Twisted Python.
 *
 * It is a static class that can schedule events via a single onEnterFrame loop.
 * The Reactor is well-suited to setting up delayed function calls complete with
 * arguments, and scheduling their execution some number of milliseconds into the
 * future. It is also useful for helping to maintain framerate, by only executing
 * as many calls as can fit in a pre-determined time limit.
 *
 * @see http://twistedmatrix.com/projects/core/documentation/howto/reactor-basics.html
 *
 * @usage <code>
 *          import com.stamen.twisted.Reactor;
 *          ...
 *          Reactor.run(_root, null, 50);
 *          Reactor.callLater(1000, trace, "A message in the mysterious future");
 *        </code>
 */

import com.stamen.twisted.DelayedCall;
import com.bigspaceship.utils.Delegate;

class com.stamen.twisted.Reactor
{
    private static var oldEnterFrame:Function;
    private static var runningEnterFrame:Function;
    
    private static var clip:MovieClip;  // clip to which onEnterFrame is attached
    private static var start:Number;    // timestamp at start
    private static var limit:Number;    // time limit for mainLoop() to maintain fps

    private static var calls:/*DelayedCall*/Array;
    private static var nextFrameCalls:/*DelayedCall*/Array;

   /**
	* Run Reactor with clip that will host onEnterFrame, and a limit value for
	* main loop duration (default is 50ms if not provided).
    */
    public static function run(mc:MovieClip, lim:Number):Void
    {
        trace('Starting Reactor...');

        if(runningEnterFrame) {
            trace('Warning: possible that reactor was already started?');
            throw new Error('Warning: possible that reactor was already started?');
        }

        clip = mc;
        limit = lim || 50;
        start = getTime();
        calls = [];
        nextFrameCalls = [];

        if(clip.onEnterFrame)
            oldEnterFrame = Delegate.create(clip, clip.onEnterFrame);

        clip.onEnterFrame = runningEnterFrame = Delegate.create(Reactor, mainLoop);
        trace('Started Reactor at '+start+'.');
    }
    
   /**
    * Determine whether the reactor is currently running.
    */
    public static function running():Boolean
    {
        return Boolean(runningEnterFrame);
    }
    
   /**
    * Stop running Reactor.
    */
    public static function stop():Void
    {
        trace('Stopping Reactor...');

        if(!runningEnterFrame) {
            trace('Warning: possible that reactor had not been stopped?');
            throw new Error('Warning: possible that reactor had not been stopped?');
        }
        
        delete clip.onEnterFrame;
        delete runningEnterFrame;

        if(oldEnterFrame)
            clip.onEnterFrame = oldEnterFrame;

        trace('Stopped Reactor.');
    }
    
    private static function getTime():Number
    {
        var d:Date = new Date();
        return d.getTime();
    }
    
    private static function sortCalls(a:DelayedCall, b:DelayedCall):Number
    {
        // Sort with the most urgent calls at the beginning
        return a.due - b.due;
    }
    
    private static function mainLoop():Void
    {
        trace('...Reactor main loop...');
        
        var loopStop:Number = getTime() + limit;
        
        while(nextFrameCalls.length)
            addCall(DelayedCall(nextFrameCalls.pop()));
        
        while(calls.length) {
            // Stop as soon as we encounter one that's not due
            // Calls are kept in order by callLater()
            if(calls[0].due > getTime())
                break;

            try {
                // Shift n' call first in the list, most urgent!
                calls.shift().call();
            } catch(e) {
                // do nothing
            }
            
            // Stop if the limit is exceeded
            if(getTime() > loopStop)
                break;
        }
    
        if(oldEnterFrame)
            oldEnterFrame();
    }
    
    private static function addCall(call:DelayedCall):Void
    {
        calls.push(call);
        
        // Most-urgent calls go to the front.
        // Hopefully cheap, since these will generally stay in order.
        calls.sort(sortCalls);
    }
    
   /**
    * Schedule a call for later, with time in the future, a function to call, and optional arguments to pass.
    */
    public static function callLater(delay:Number, func:Function):DelayedCall
    {
        var due:Number = getTime() + delay;     // due <delay> msec from now
        var args:Array = arguments.slice(2);    // more than two arguments can be passed to this function
        var call:DelayedCall = new DelayedCall(due, func, args);

        trace('Adding delayed call with '+call.args.length+' arguments at '+call.due+'...');
        addCall(call);
        return call;
    }
    
   /**
    * Schedule a call for the next frame, with a function to call and optional arguments to pass.
    */
    public static function callNextFrame(func:Function):DelayedCall
    {
        var due:Number = getTime();             // due ASAP
        var args:Array = arguments.slice(1);    // more than one argument can be passed to this function
        var call:DelayedCall = new DelayedCall(due, func, args);

        trace('Adding delayed call for next frame with '+call.args.length+' arguments at '+call.due+'...');
        nextFrameCalls.push(call);
        return call;
    }
}
