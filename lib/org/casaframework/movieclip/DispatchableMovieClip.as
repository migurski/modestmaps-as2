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
import org.casaframework.event.DispatchableInterface;
import org.casaframework.event.EventDispatcher;

/**
	Base MovieClip that includes {@link EventDispatcher} and extends {@link CoreMovieClip}.
	
	@author Aaron Clinger
	@version 12/12/06
*/

class org.casaframework.movieclip.DispatchableMovieClip extends CoreMovieClip implements DispatchableInterface {
	private var $eventDispatcher:EventDispatcher;
	
	/**
		@exclude
	*/
	public function DispatchableMovieClip() {
		super();
		
		this.$eventDispatcher = new EventDispatcher();
		
		this.$setClassDescription('org.casaframework.movieclip.DispatchableMovieClip');
	}
	
	public function addEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		return this.$eventDispatcher.addEventObserver(scope, eventName, eventHandler);
	}
	
	public function removeEventObserver(scope:Object, eventName:String, eventHandler:String):Boolean {
		return this.$eventDispatcher.removeEventObserver(scope, eventName, eventHandler);
	}
	
	public function removeEventObserversForEvent(eventName:String):Boolean {
		return this.$eventDispatcher.removeEventObserversForEvent(eventName);
	}
	
	public function removeEventObserversForScope(scope:Object):Boolean {
		return this.$eventDispatcher.removeEventObserversForScope(scope);
	}
	
	public function removeAllEventObservers():Boolean {
		return this.$eventDispatcher.removeAllEventObservers();
	}
	
	public function dispatchEvent(eventName:String):Boolean {
		return this.$eventDispatcher.dispatchEvent.apply(this.$eventDispatcher, arguments);
	}
	
	public function destroy():Void {
		this.$eventDispatcher.destroy();
		delete this.$eventDispatcher;
		
		super.destroy();
	}
}