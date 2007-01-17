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

import org.casaframework.core.CoreInterface;

/**
	Event interface which all objects that use {@link EventDispatcher} should adhere to.

	@author Aaron Clinger
	@version 12/12/06
*/

interface org.casaframework.event.DispatchableInterface extends CoreInterface {
	
	/**
		Reports event to all subscribed objects.

		@param eventName: Event name.
		@param param(s): <strong>[optional]</strong> Parameters passed to the function specified by "eventName". Multiple parameters are allowed and should be separated by commas: param1,param2, ...,paramN
		@return Returns <code>true</code> if observer(s) listening to specifed event was found; otherwise <code>false</code>.
		@example <code>this.dispatchEvent("onRelease", 5, true, "Aaron");</code>
	*/
	public function dispatchEvent(eventName:String):Boolean;
	
	/**
		Registers a function to receive notification when a event handler is invoked.
	
		@param scope: The target or object in which to subscribe.
		@param eventName: Event name to subscribe to.
		@param eventHandler: <strong>[optional]</strong> Name of function to recieve the event. If undefined class assumes <code>eventHandler</code> matches <code>eventName</code>.
		@return Returns <code>true</code> if the observer was established successfully; otherwise <code>false</code>.
		@example <code>this.eventButton_mc.addEventObserver(this, "onRollOver");</code>
	*/
	public function addEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean;
	
	/**
		Removes specific observer for event.
		
		@param scope: The target or object in which subscribed.
		@param eventName: Event name to unsubscribe to.
		@param eventHandler: <strong>[optional]</strong> Name of function that recieved the event. If undefined class assumes <code>eventHandler</code> matched <code>eventName</code>.
		@return Returns <code>true</code> if the observer was successfully found and removed; otherwise <code>false</code>.
		@example <code>this.eventButton_mc.removeEventObserver(this, "onRollOver");</code>
		@see {@link #removeEventObserversForEvent}, {@link #removeEventObserversForScope}
	*/
	public function removeEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean;
	
	/**
		Removes all observers for a specified event.

		@param eventName: Event name to unsubscribe to.
		@return Returns <code>true</code> if observers were successfully found for specified <code>eventName</code> and removed; otherwise <code>false</code>.
		@example <code>this.eventButton_mc.removeEventObserversForEvent("onRollOver");</code>
		@see {@link #removeEventObserver}, {@link #removeEventObserversForScope}
	*/
	public function removeEventObserversForEvent(eventName:String):Boolean;
	
	/**
		Removes all observers in a specified scope.

		@param scope: The target or object in which to unsubscribe.
		@return Returns <code>true</code> if observers were successfully found in <code>scope</code> and removed; otherwise <code>false</code>.
		@example <code>this.eventButton_mc.removeEventObserversForScope(this);</code>
		@see {@link #removeEventObserver}, {@link #removeEventObserversForEvent}
	*/
	public function removeEventObserversForScope(scope:Object):Boolean;
	
	/**
		Removes all observers regardless of scope or event.
		
		return Returns <code>true</code> if observers were successfully removed; otherwise <code>false</code>.
	*/
	public function removeAllEventObservers():Boolean;
}