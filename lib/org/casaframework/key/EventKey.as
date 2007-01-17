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
	Dispatches key events to observers. Should be used instead of <code>Key.addListener</code>.
	
	@author Aaron Clinger
	@version 10/16/06
	@example
		<code>
			function onKeyDown(code:Number, ascii:Number):Void {
				trace("Code: " + code + "\tACSII: " + ascii + "\tKey: " + String.fromCharCode(ascii));
			}
	
			var keyInstance:EventKey = EventKey.getInstance();
			this.keyInstance.addEventObserver(this, EventKey.EVENT_KEY_DOWN);
		</code>
*/

class org.casaframework.key.EventKey extends EventDispatcher {
	public static var EVENT_KEY_UP:String   = 'onKeyUp';
	public static var EVENT_KEY_DOWN:String = 'onKeyDown';
	private static var $keyInstance:EventKey;
	
	/**
		@return {@link EventKey} instance.
	*/
	public static function getInstance():EventKey {
		if (EventKey.$keyInstance == undefined) EventKey.$keyInstance = new EventKey(); 
		return EventKey.$keyInstance;
	}
	
	private function EventKey() {
		super();
		
		Key.addListener(this);
		
		this.$setClassDescription('org.casaframework.key.EventKey');
	}
	
	/**
		@sends onKeyDown = function(code:Number, ascii:Number) {}
	*/
	private function onKeyDown():Void {
		this.dispatchEvent(EventKey.EVENT_KEY_DOWN, Key.getCode(), Key.getAscii());
	}
	
	/**
		@sends onKeyUp = function(code:Number, ascii:Number) {}
	*/
	private function onKeyUp():Void {
		this.dispatchEvent(EventKey.EVENT_KEY_UP, Key.getCode(), Key.getAscii());
	}
}
