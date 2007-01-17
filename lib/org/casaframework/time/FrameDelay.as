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
import org.casaframework.time.EnterFrame;

/**
	Creates a callback after one or more frames have been fired. Helps prevent race conditions by allowing recently created MovieClips, Classed, etc... a frame to initialize before proceeding. Should only need a single frame because <code>onEnterFrame</code> should only occur when all frame jobs are finished.

	@author Aaron Clinger
	@version 12/14/06
	@since Flash Player 7
	@example
		<code>
			class Example {
				public function Example() {
					// A lot of inits, attachMovies, etc...
					
					var initDelay:FrameDelay = new FrameDelay(this, "initComplete");
					initDelay.start();
				}
				
				public function initComplete():Void {
					// Safe to execute code
				}
			}
		</code>
		
		When starting a SWF or after attaching a movie:
		<code>
			var initDelay:FrameDelay = new FrameDelay(this, "initComplete", 1, "Aaron", 1984);
			this.initDelay.start();
			
			function initComplete(firstName:String, birthYear:Number):Void {
				trace(firstName + " was born in " + birthYear);
			}
		</code>
*/

class org.casaframework.time.FrameDelay extends CoreObject implements RunnableInterface {
	private var $scope:Object;
	private var $methodName:String;
	private var $frames:Number;
	private var $fires:Number;
	private var $arguments:Array;
	private var $enterFrameInstance:EnterFrame;
	
	/**
		Defines {@link FrameDelay} object.
		
		@param scope: An object that contains the method specified by "methodName".
		@param methodName: A method that exists in the scope of the object specified by "scope".
		@param frames: <strong>[optional]</strong> The number of frames to wait before calling "methodName". <code>frames</code> defaults to <code>1</code>.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "methodName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
	*/
	public function FrameDelay(scope:Object, methodName:String, frames:Number, param:Object) {
		super();
		
		this.$setClassDescription('org.casaframework.time.FrameDelay');
		
		this.$scope      = scope;
		this.$methodName = methodName;
		this.$frames     = (frames == undefined || frames == null) ? 1 : frames;
		this.$arguments  = arguments.slice(3);
	}
	
	/**
		Starts or restarts the frame delay.
	*/
	public function start():Void {
		this.$fires = 0;
		this.$enterFrameInstance = EnterFrame.getInstance();
		this.$enterFrameInstance.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrameFire');
	}
	
	/**
		Stops the frame delay from completing.
	*/
	public function stop():Void {
		this.$enterFrameInstance.removeEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$onFrameFire');
		delete this.$enterFrameInstance;
		delete this.$fires;
	}
	
	public function destroy():Void {
		this.stop();
		
		delete this.$scope;
		delete this.$methodName;
		delete this.$frames;
		delete this.$arguments;
		
		super.destroy();
	}
	
	private function $onFrameFire():Void {
		if (++this.$fires >= this.$frames) {
			this.stop();
			this.$scope[this.$methodName].apply(this.$scope, this.$arguments);
		}
	}
}