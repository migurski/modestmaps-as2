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

import org.casaframework.movieclip.CoreMovieClip;
import org.casaframework.state.MovieClipEventHandlerState;

/**
	Provides state-switching mechanism for MovieClip EventHandlers and properties.

	@author Toby Boudreaux
	@author David Nelson
	@author Aaron Clinger
	@version 11/29/06
	@example
		<code>
			this.attachMovie("statedMovieClip", "stated_mc", 20);
			
			this.stated_mc.onRelease = function():Void {
				trace("onRelease on " + this._name + " was called. Example one.");
			}
			
			this.stated_mc.createState("exampleButtonOne");
			
			this.stated_mc.onRelease = function():Void {
				trace("onRelease on " + this._name + " was called. Example two.");
			}
			
			this.stated_mc.createState("exampleButtonTwo");
		</code>
	
		Now you can switch between the states, example:
		<code>this.stated_mc.switchState("exampleButtonOne");</code> or <code>this.stated_mc.switchState("exampleButtonTwo");</code>
	
		To return to the default creation state (no EventHandlers) call:
		<code>this.stated_mc.switchState("default");</code>
	@usageNote Class creates <code>"default"</code> state on MovieClip instance creation.
*/

class org.casaframework.movieclip.StatedMovieClip extends CoreMovieClip {
	private var $states:Object;
	private var $currentState:String;
	
	/**
		@exclude
	*/
	public function StatedMovieClip() {
		super();
		
		this.$states = new Object();
		this.createState('default');
		
		this.$setClassDescription('org.casaframework.movieclip.StatedMovieClip');
	}
	
	/**
		Returns the current state of MovieClip. If no state has been created {@link #getState} will return <code>"default"</code>.
	
		@return The name of current MovieClip state.
		@usageNote {@link #getState} will always return last created or switched to state.
	*/
	public function getState():String {
		return this.$currentState;
	}
	
	/**
		Switches MovieClip's current state to a precreated state.
	
		@param stateName: Name of precreated MovieClip state.
		@param inclusionList: <strong>[optional]</strong> List of EventHandlers and properties to include/switch state of. Defaults to all MovieClip EventHandlers.
		@return Returns <code>true</code> if the precreated state was found and the MovieClip's state was successfully changed; otherwise <code>false</code>.
		@example <code>this.stated_mc.switchState("uniqueStateName", new Array("onEnterFrame", "onRelease"));</code>
		@see {@link #createState}
	*/
	public function switchState(stateName:String, inclusionList:Array):Boolean {
		if (stateName == undefined || this.$states[stateName] == undefined)
			return false;
		
		this.$currentState = stateName;
		
		var keyList:Array = (inclusionList == undefined) ? this.$states[stateName].getValueKeys() : inclusionList;
		var eventHandler:Function;
		var key:String;
		
		for (var i:String in keyList) {
			key = keyList[i];
			eventHandler = this.$states[stateName].getValueForKey(key);
			if (eventHandler == undefined)
				delete this[key];
			else 
				this[key] = eventHandler;
		}
		
		return true;
	}
	
	/**
		Creates a new state and records EventHandlers.
		
		@param stateName: Unique name for MovieClip state.
		@param inclusionList: <strong>[optional]</strong> List of EventHandlers and properties to include. Defaults to all MovieClip EventHandlers.
		@usageNote If parameter <code>stateName</code> is identical to previously created state, {@link createState} will overwrite it.
		@example <code>this.stated_mc.createState("uniqueStateName", new Array("onRollOver", "onRollOut", "onRelease"));</code>
		@see {@link MovieClipEventHandlerState}
	*/
	public function createState(stateName:String, inclusionList:Array):Void {
		if (stateName == undefined)
			return;
		
		this.$currentState = stateName;
		this.$states[stateName] = new MovieClipEventHandlerState();
		
		var keyList:Array = (inclusionList == undefined) ? this.$states[stateName].getValueKeys() : inclusionList;
		var key:String;
		
		for (var i:String in keyList) {
			key = keyList[i];
			this.$states[stateName].setValueForKey(key, this[key]);
		}
	}
	
	/**
		Registers single value to a MovieClip property for a given state.
	
		@param stateName: Name of precreated MovieClip state, or new state.
		@param keyName: Name of any MovieClip property or EventHandler.
		@param value: Value of MovieClip property or EventHandler specified by parameter <code>keyName</code>.
		@example 
			<code>
				var anonymousFunction:Function = function():Void {
					trace("onRollOver");
				} 
			
				this.stated_mc.setKeyValueForState("stateName", "onRollOver", anonymousFunction);
			</code>
			
			You can define any MovieClip properties, not just event handlers. Such as <code>_alpha</code>, <code>_x</code>, <code>_yscale</code> etc...:
			<code>this.stated_mc.setKeyValueForState("stateName", "_alpha", 25);</code>
	*/
	public function setKeyValueForState(stateName:String, keyName:String, value:Object):Void {
		if (this.$states[stateName] == undefined)
			this.$states[stateName] = new MovieClipEventHandlerState();
		
		this.$states[stateName].setValueForKey(keyName, value);
	}
	
	/**
		Removes/unregisters value from MovieClip property for a given state.
		
		@param stateName: Name of precreated MovieClip state.
		@param keyName: Name of any MovieClip property or EventHandler.
		@return Returns <code>true</code> if the key was successfully found and removed from EventHandler state; otherwise <code>false</code>.
	*/
	public function removeKeyValueForState(stateName:String, keyName:String):Boolean {
		if (this.$states[stateName] == undefined)
			return false;
		
		return this.$states[stateName].removeValueForKey(keyName);
	}
	
	/**
		Deletes precreated MovieClip state.
		
		@param stateName: Name of precreated MovieClip state.
		@return Returns <code>true</code> if the state was successfully found and removed; otherwise <code>false</code>.
	*/
	public function removeState(stateName:String):Boolean {
		if (stateName == undefined || this.$states[stateName] == undefined)
			return false;
		
		delete this.$states[stateName];
		
		return true;
	}
	
	public function destroy():Void {
		delete this.$states;
		delete this.$currentState;
		
		super.destroy();
	}
}