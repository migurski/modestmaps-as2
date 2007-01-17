/*
	CASA Framework for ActionScript 2.0
	Copyright (C) 2006  CASA Framework
	http://casaframework.org
	
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.
	
	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import org.casaframework.event.EventDispatcher;
import org.casaframework.control.RunnableInterface;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.TypeUtil;

/**
	To be used instead of built in <code>setInterval</code> function. 
	
	Advantages over <code>setInterval</code>:
	<ul>
		<li>Auto stopping/clearing of intervals if method called no longer exists.</li>
		<li>Ability to {@link #stop} and {@link #start} intervals without redefining.</li>
		<li>Change the delay with {@link #changeDelay} without redefining.</li>
		<li>Included {@link #setReps} for intervals that only need to fire finitely.</li>
		<li>{@link #setInterval} returns object instead of interval id for better OOP structure.</li>
		<li>Built in events/event dispatcher.</li>
	</ul>

	@author Aaron Clinger
	@author Toby Boudreaux
	@author Mike Creighton
	@version 12/14/06
	@example
		<code>
			var example_si:Interval = Interval.setInterval(this, "exampleFire", 1000, "Aaron");
			this.example_si.setReps(3);
			this.example_si.start();
	
			function exampleFire(firstName:String):Void {
				trace("exampleFire called and passed firstName = " + firstName);
			}
		</code>
	@see {@link PropertySetter}.
*/

class org.casaframework.time.Interval extends EventDispatcher implements RunnableInterface {
	public static var EVENT_START:String    = 'onStart';
	public static var EVENT_STOP:String     = 'onStop';
	public static var EVENT_FIRE:String     = 'onFire';
	public static var EVENT_COMPLETE:String = 'onComplete';
	private var $id:Number;
	private var $reps:Number;
	private var $fires:Number;
	private var $arguments:Array;
	private var $isFiring:Boolean;
	
	private static var $intervalMap:Array;
		
	/**
		Calls a function or a method of an object at periodic intervals.
	
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param delay: The time in milliseconds between calls.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "methodName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
		@return: {@link Interval} reference.
	*/
	public static function setInterval(scope:Object, methodName:String, delay:Number, param:Object):Interval {
		if (!TypeUtil.isTypeOf(scope[methodName], 'function'))
			return undefined;
		
		if (Interval.$intervalMap == undefined)
			Interval.$intervalMap = new Array();
		
		var intervalItem:Interval = new Interval();
		intervalItem.setArguments(arguments);
		
		Interval.$intervalMap.push(intervalItem);
		
		return intervalItem;
	}
	
	/**
		Calls a function or a method of an object once after time has elasped, <code>setTimeout</code> defaults {@link #setReps} to 1. 
	
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param delay: The time in milliseconds until call.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "methodName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
		@return: {@link Interval} reference.
	*/
	public static function setTimeout(scope:Object, methodName:String, delay:Number, param:Object):Interval {
		var intervalItem:Interval = Interval.setInterval.apply(null, arguments);
		intervalItem.setReps(1);
		return intervalItem;
	}
	
	/**
		@exclude
	*/
	public static function clearInterval(intervalReference:Interval):Void {
		_global.clearInterval(intervalReference.getId());
	}
	
	/**
		Stops all intervals in a defined location.

		@param scope: <strong>[optional]</strong> Object reference that contains a method referenced by one or more Interval instance. If scope is <code>undefined</code>, {@link #stopIntervals} will stop all running intervals.
		@see {@link #stop}
	*/
	public static function stopIntervals(scope:Object):Void {
		var len:Number = Interval.$intervalMap.length;
		
		if (scope == undefined)
			while (len--)
				Interval.$intervalMap[len].stop();
		else
			while (len--)
				if (Interval.$intervalMap[len].$arguments[0] == scope)
					Interval.$intervalMap[len].stop();
	}
	
	
	
	private function Interval() {
		super();
		this.$isFiring = false;
		this.$setClassDescription('org.casaframework.time.Interval');
	}
	
	/**
		Starts or restarts the interval method calls. Resets reps/fires to 0.
	
		@sends onStart = function(sender:Interval) {}
	*/
	public function start():Void {
		Interval.clearInterval(this);
		this.dispatchEvent(Interval.EVENT_START, this);
		this.$fires    = 0;
		this.$id       = _global.setInterval(this, '$onFire', this.$arguments[2]);
		this.$isFiring = true;
	}
	
	/**
		Stops the interval method calls. Used instead of clearInterval. Always call before deleting reference instance.
	
		@sends onStop = function(sender:Interval) {}
	*/
	public function stop():Void {
		if (!this.$isFiring)
			return;
		
		this.$stopInterval();
		this.dispatchEvent(Interval.EVENT_STOP, this);
	}
	
	/**
		Defines the amount of total repetitions/fires. If not set repetitions will continue until {@link #stop} is called.
	
		@param reps: Number of repetitions.
	*/
	public function setReps(reps:Number):Void {
		this.$reps = reps;
	}
	
	/**
		@exclude
	*/
	public function setArguments(args:Array):Void {
		this.$arguments = args;
	}
	
	/**
		Returns the number of fires.

		@return The number of elapsed fires.
	*/
	public function getFires():Number {
		return this.$fires;
	}
	
	/**
		Changes the time between repetitions. Does NOT reset reps/fires.
	
		@param delay: The time in milliseconds between calls.
	*/
	public function changeDelay(delay:Number):Void {
		var fires:Number = this.$fires;
		this.$stopInterval();
		this.$arguments[2] = delay;
		
		if (this.isFiring()) {
			this.start();
			this.$fires = fires;
		}
	}
	
	/**
		@return Returns <code>true</code> if interval instance is running/firing; otherwise <code>false</code>.
	*/
	public function isFiring():Boolean {
		return this.$isFiring;
	}
	
	/**
		@exclude
	*/
	public function getId():Number {
		return this.$id;
	}
	
	/**
		@sends onFire = function(sender:Interval, fires:Number) {}
		@sends onComplete = function(sender:Interval, fires:Number) {}
	*/
	private function $onFire():Void {
		var scope:Object      = this.$arguments[0];
		var methodName:String = this.$arguments[1];
		
		if (!TypeUtil.isTypeOf(scope[methodName], 'function')) {
			this.destroy();
			return;
		}
		
		this.dispatchEvent(Interval.EVENT_FIRE, this, ++this.$fires);
		scope[methodName].apply(scope, this.$arguments.slice(3));
		
		if (this.$reps != undefined) {
			if (this.$reps <= this.$fires) {
				this.$stopInterval();
				this.dispatchEvent(Interval.EVENT_COMPLETE, this, this.$fires);
			}
		}
	}
	
	private function $stopInterval():Void {
		Interval.clearInterval(this);
		this.$isFiring = false;
	}
	
	public function destroy():Void {
		this.$stopInterval();
		
		delete this.$id;
		delete this.$reps;
		delete this.$fires;
		this.$arguments.splice(0);
		delete this.$arguments;
		delete this.$isFiring;
		
		ArrayUtil.removeArrayItem(Interval.$intervalMap, this);
		
		super.destroy();
	}
}