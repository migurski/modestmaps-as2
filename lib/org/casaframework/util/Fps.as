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
import org.casaframework.control.RunnableInterface;
import org.casaframework.util.ArrayUtil;
import org.casaframework.time.EnterFrame;
import org.casaframework.time.Stopwatch;

/**
	Calculates the movie's frames per second.
	
	@author Aaron Clinger
	@version 12/14/06
	@since Flash Player 7
	@example
		<code>
			var movieFps:Fps = Fps.getInstance();
			this.movieFps.start();
			
			this.myButton_btn.onRelease = function():Void {
				trace(this._parent.movieFps.getFps());
			}
		</code>
*/

class org.casaframework.util.Fps extends CoreObject implements RunnableInterface {
	private static var $fpsInstance:Fps;
	private var $pulseInstance:EnterFrame;
	private var $frameTimes: /*Number*/ Array;
	private var $stopwatch:Stopwatch;
	private var $frameTotal:Number;
	
	/**
		@return {@link Fps} instance.
	*/
	public static function getInstance():Fps {
		if (Fps.$fpsInstance == undefined)
			Fps.$fpsInstance = new Fps();
		
		return Fps.$fpsInstance;
	}
	
	private function Fps() {
		super();
		
		this.$stopwatch     = new Stopwatch();
		this.$frameTimes    = new Array();
		this.$pulseInstance = EnterFrame.getInstance();
		
		this.setFramesToAverage(20);
		
		this.$setClassDescription('org.casaframework.util.Fps');
	}
	
	/**
		Calculates the current frames per second of the movie.
		
		@return The FPS.
	*/
	public function getFps():Number {
		return 1000 / ArrayUtil.average(this.$frameTimes);
	}
	
	/**
		Defines the amount of frames the class compares and averages.
		
		@param total: The amount of previous frames to average; defaults to <code>20</code>.
	*/
	public function setFramesToAverage(total:Number):Void {
		this.$frameTotal = total;
	}
	
	/**
		Starts observing the FPS and actively records and calulates the FPS.
	*/
	public function start():Void {
		this.$stopwatch.start();
		this.$pulseInstance.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onEnterFrame');
	}
	
	/**
		Stops observing the FPS.
	*/
	public function stop():Void {
		this.$pulseInstance.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onEnterFrame');
	}
	
	private function $onEnterFrame():Void {
		this.$stopwatch.stop();
		this.$frameTimes.push(this.$stopwatch.getTime());
		
		if (this.$frameTimes.length > this.$frameTotal)
			this.$frameTimes.splice(0, 1);
		
		this.$stopwatch.start();
	}
}
