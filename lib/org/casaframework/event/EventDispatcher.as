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
import org.casaframework.event.DispatchableInterface;
import org.casaframework.util.TypeUtil;

/**
	Provides event notification and listener management capabilities to objects. 
	
	Advantages of using this EventDispatcher:
	<ul>
		<li>Ability to {@link #addEventObserver remap event handlers} to a function not sharing the same name as the event.</li>
		<li>Ability to {@link #removeEventObserversForEvent remove all} event observers for a specified event.</li>
		<li>Ability to {@link #removeEventObserversForScope remove all} event observers for a specified scope.</li>
		<li>Ability to {@link #removeAllEventObservers remove all} event observers subscribed to broadcasting object.</li>
	</ul>

	@author Aaron Clinger
	@version 12/18/06
	@usageNote <strong>Always call {@link #destroy} before deleting/removing an EventDispatcher instance.</strong>
*/

class org.casaframework.event.EventDispatcher extends CoreObject implements DispatchableInterface {
	private var $eventMap:Object;
	
	public function EventDispatcher() {
		super();
		
		this.$eventMap = new Object();
		
		this.$setClassDescription('org.casaframework.event.EventDispatcher');
	}
	
	public function addEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		var eventFunction:String = (eventHandler == undefined) ? eventName : eventHandler;
		
		if (!TypeUtil.isTypeOf(scope[eventFunction], 'function'))
			return false;
		
		var eventList:Array = this.$eventMap[eventName];
		
		if (eventList == undefined)
			this.$eventMap[eventName] = new Array();
		else {
			var len:Number = eventList.length;
			while (len--)
				if (eventList[len].obser == scope && eventList[len].funct == eventFunction)
					return false;
		}
		
		var event:Object = new Object();
		event.obser      = scope;
		event.funct      = eventFunction;
		
		this.$eventMap[eventName].push(event);
		
		return true;
	}
	
	public function removeEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		var funct:String    = (eventHandler == undefined) ? eventName : eventHandler;
		var eventList:Array = this.$eventMap[eventName];
		var len:Number      = eventList.length;
		
		while (len--) {
			if (eventList[len].obser == scope && eventList[len].funct == funct) {
				eventList.splice(len, 1);
				
				if (eventList.length == 0)
					delete this.$eventMap[eventName];
				
				return true;
			}
		}
		
		return false;
	}
	
	public function removeEventObserversForEvent(eventName:String):Boolean {
		if (this.$eventMap[eventName] == undefined)
			return false;
		
		delete this.$eventMap[eventName];
		
		return true;
	}
	
	public function removeEventObserversForScope(scope:Object):Boolean {
		var removed:Boolean = false;
		
		for (var i:String in this.$eventMap) {
			var eventList:Array = this.$eventMap[i];
			var len:Number      = eventList.length;
			
			while (len--) {
				if (eventList[len].obser == scope) {
					this.$eventMap[i].splice(len, 1);
					
					if (eventList.length == 0)
						delete this.$eventMap[i];
					
					removed = true;
				}
			}
		}
		
		return removed;
	}
	
	public function removeAllEventObservers():Boolean {
		for (var i:String in this.$eventMap) {
			this.$eventMap[i].splice(0);
			delete this.$eventMap[i];
		}
		
		this.$eventMap = new Object();
		
		return true;
	}
	
	public function dispatchEvent(eventName:String):Boolean {
		var eventList:Array = this.$eventMap[eventName];
		if (eventList == undefined)
			return false;
		
		var i:Number = -1;
		while (++i < eventList.length)
			eventList[i].obser[eventList[i].funct].apply(eventList[i].obser, arguments.slice(1));
		
		return true;
	}
	
	public function destroy():Void {
		this.removeAllEventObservers();
		delete this.$eventMap;
		
		super.destroy();
	}
}
