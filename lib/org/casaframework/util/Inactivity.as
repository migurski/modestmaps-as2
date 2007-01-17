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
import org.casaframework.mouse.EventMouse;
import org.casaframework.time.Interval;
import org.casaframework.key.EventKey;

/**
	Detects user inactivity by checking for a void in mouse movement and key presses.

	@author Aaron Clinger
	@version 11/11/06
	@example
		<code>
			function onInactive(sender:Object):Void {
				trace("User has been inactive for 5 seconds.");
			}
			
			function onReactive(sender:Object):Void {
				trace("User has resumed activity.");
			}
	
			var inactivityDetect:Inactivity = new Inactivity(5000);
			this.inactivityDetect.addEventObserver(this, "onInactive");
			this.inactivityDetect.addEventObserver(this, "onReactive");
		</code>
*/

class org.casaframework.util.Inactivity extends EventDispatcher {
	private var $keyInstance:EventKey;
	private var $mouseInstance:EventMouse;
	private var $inactiveInterval:Interval;
	
	/**
		Creates Inactivity object, and defines time until user is inactive.
	
		@param timeUntilInactive: The time in milliseconds until a user is considered inactive.
		@sends onInactive = function(sender:Object) {}
	*/
	public function Inactivity(timeUntilInactive:Number) {
		super();
		
		this.$mouseInstance = EventMouse.getInstance();
		this.$mouseInstance.addEventObserver(this, EventMouse.EVENT_MOUSE_MOVE, '$userInput');
		
		this.$keyInstance = EventKey.getInstance();
		this.$keyInstance.addEventObserver(this, EventKey.EVENT_KEY_DOWN, '$userInput');
		
		this.$inactiveInterval = Interval.setTimeout(this, 'dispatchEvent', timeUntilInactive, 'onInactive', this);
		this.$inactiveInterval.start();
		
		this.$setClassDescription('org.casaframework.util.Inactivity');
	}
	
	public function destroy():Void {
		this.$keyInstance.destroy();
		this.$mouseInstance.destroy();
		this.$inactiveInterval.destroy();
		
		delete this.$keyInstance;
		delete this.$mouseInstance;
		delete this.$inactiveInterval;
		
		super.destroy();
	}
	
	/**
		@sends onReactive = function(sender:Object) {}
	*/
	private function $userInput():Void {
		if (!this.$inactiveInterval.isFiring())
			this.dispatchEvent('onReactive', this);
		
		this.$inactiveInterval.start();
	}
}