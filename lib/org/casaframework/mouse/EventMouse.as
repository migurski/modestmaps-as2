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
	Dispatches mouse events to observers. Should be used instead of <code>Mouse.addListener</code>.
	
	@author Aaron Clinger
	@version 10/18/06
	@example
		<code>
			function onMouseMove():Void {
				trace("Mouse position is x:" + _root._xmouse + " y:" + _root._ymouse + ".");
			}
	
			var mouseInstance:EventMouse = EventMouse.getInstance();
			this.mouseInstance.addEventObserver(this, EventMouse.EVENT_MOUSE_MOVE);
		</code>
*/

class org.casaframework.mouse.EventMouse extends EventDispatcher {
	public static var EVENT_MOUSE_DOWN:String  = 'onMouseDown';
	public static var EVENT_MOUSE_MOVE:String  = 'onMouseMove';
	public static var EVENT_MOUSE_UP:String    = 'onMouseUp';
	public static var EVENT_MOUSE_WHEEL:String = 'onMouseWheel';
	private static var $mouseInstance:EventMouse;
	
	/**
		@return {@link EventMouse} instance.
	*/
	public static function getInstance():EventMouse {
		if (EventMouse.$mouseInstance == undefined)
			EventMouse.$mouseInstance = new EventMouse(); 
		
		return EventMouse.$mouseInstance;
	}
	
	private function EventMouse() {
		super();
		
		Mouse.addListener(this);
		
		this.$setClassDescription('org.casaframework.mouse.EventMouse');
	}
	
	/**
		@sends onMouseDown = function() {}
	*/
	private function onMouseDown():Void {
		this.dispatchEvent(EventMouse.EVENT_MOUSE_DOWN);
	}
	
	/**
		@sends onMouseMove = function() {}
	*/
	private function onMouseMove():Void {
		this.dispatchEvent(EventMouse.EVENT_MOUSE_MOVE);
	}
	
	/**
		@sends onMouseUp = function() {}
	*/
	private function onMouseUp():Void {
		this.dispatchEvent(EventMouse.EVENT_MOUSE_UP);
	}
	
	/**
		@sends onMouseWheel = function(delta:Number, scrollTarget:String) {}
	*/
	private function onMouseWheel(delta:Number, scrollTarget:String):Void {
		this.dispatchEvent(EventMouse.EVENT_MOUSE_WHEEL, delta, scrollTarget);
	}
}
