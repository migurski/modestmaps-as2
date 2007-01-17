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

/**
	Creates "onEnterFrame" events. Can be used instead of all <code>onEnterFrame</code>'s, and to mimic the MovieClip property in object classes.
	
	@author Aaron Clinger
	@author Mike Creighton
	@version 10/16/06
	@since Flash Player 7
	@example
		<code>
			function onFrameFire():Void {
				trace("I will be called every frame.");
			}
			
			var pulseInstance:EnterFrame = EnterFrame.getInstance();
			this.pulseInstance.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, "onFrameFire");
		</code>
*/

class org.casaframework.time.EnterFrame extends EventDispatcher {
	public  static var EVENT_ENTER_FRAME:String = 'onEnterFrame';
	private static var $pulseInstance:EnterFrame;
	private static var $pulseMovieClip:MovieClip;
	
	/**
		@return {@link EnterFrame} instance.
	*/
	public static function getInstance():EnterFrame {
		if (EnterFrame.$pulseMovieClip.onEnterFrame == undefined)
			EnterFrame.$pulseInstance = new EnterFrame();
		
		return EnterFrame.$pulseInstance;
	}
	
	/**
		@sends onEnterFrame = function() {}
	*/
	private function EnterFrame() {
		super();
		
		EnterFrame.$pulseMovieClip = _root.createEmptyMovieClip('framePulse_mc', _root.getNextHighestDepth());
		var context:EnterFrame = this;
		EnterFrame.$pulseMovieClip.onEnterFrame = function():Void {
			context.dispatchEvent(EnterFrame.EVENT_ENTER_FRAME);
		};
		
		this.$setClassDescription('org.casaframework.time.EnterFrame');
	}
}