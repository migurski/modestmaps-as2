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

import org.casaframework.core.CoreObject;
import org.casaframework.control.ResumeableInterface;

/**
	Simple stopwatch class that records elapsed time in milliseconds.

	@author Aaron Clinger
	@version 12/14/06
	@example
		<code>
			var stopwatch:Stopwatch = new Stopwatch();

			this.start_mc.onPress = function():Void {
				this._parent.stopwatch.start();
				trace("Stopwatch started.");
			}

			this.stop_mc.onPress = function():Void {
				trace("Stopwatch stopped. Time elapsed: " + this._parent.stopwatch.stop());
			}
			
			this.resume_mc.onPress = function():Void {
				this._parent.stopwatch.resume();
				trace("Stopwatch continued.");
			}
		</code>
*/

class org.casaframework.time.Stopwatch extends CoreObject implements ResumeableInterface {
	private var $startTime:Number;
	private var $elapsedTime:Number;
	private var $stopped:Boolean;
	
	public function Stopwatch() {
		super();
		
		this.$setClassDescription('org.casaframework.time.Stopwatch');
		
		this.$elapsedTime = this.$startTime = 0;
		this.$stopped = false;
	}
	
	/**
		Starts stopwatch and resets previous elapsed time.
	*/
	public function start():Void {
		this.$elapsedTime = 0;
		this.$startTime   = getTimer();
		this.$stopped     = false;
	}
	
	/**
		Stops stopwatch.
	*/
	public function stop():Void {
		this.$elapsedTime = this.getTime();
		this.$startTime   = 0;
		this.$stopped     = true;
	}
	
	/**
		Resumes stopwatch from {@link stop}.
	*/
	public function resume():Void {
		if (this.$stopped)
			this.$startTime = getTimer();
	}
	
	/**
		Gets the time elapsed since {@link #start} or until {@link #stop} was called.
		
		@return Returns the elapsed time in milliseconds.
		@usageNote Can be called before or after calling {@link #stop}.
	*/
	public function getTime():Number {
		return (this.$startTime != 0) ? getTimer() - this.$startTime + this.$elapsedTime : this.$elapsedTime;
	}
	
	public function destroy():Void {
		delete this.$startTime;
		delete this.$elapsedTime;
		delete this.$stopped;
		
		super.destroy();
	}
}