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

import org.casaframework.event.DispatchableInterface;
import org.casaframework.event.EventDispatcher;

/**
	Base Sound object that includes {@link EventDispatcher} and implements {@link CoreInterface}. All Sound classes implementing EventDispatcher should inherent from this class.

	@author Aaron Clinger
	@version 12/20/06
	@example
		<code>
			function onSoundLoad(sender:EventSound, success:Boolean):Void {
				if (success) {
					sender.start();
				}
			}

			function onSoundId3(sender:EventSound, id3:Object):Void {
				for (var i:String in id3) {
					trace(i + ": " + id3[i]);
				}
			}

			var eventSound:EventSound = new EventSound(this);
			this.eventSound.addEventObserver(this, EventSound.EVENT_LOAD, "onSoundLoad");
			this.eventSound.addEventObserver(this, EventSound.EVENT_ID3, "onSoundId3");
			this.eventSound.loadSound("test.mp3");
		</code>
*/

class org.casaframework.sound.EventSound extends Sound implements DispatchableInterface {
	public static var EVENT_ID3:String            = 'onID3';
	public static var EVENT_LOAD:String           = 'onLoad';
	public static var EVENT_SOUND_COMPLETE:String = 'onSoundComplete';
	private var $eventDispatcher:EventDispatcher;
	private var $instanceDescription:String;
	
	/**
		Creates an EventSound object.
		
		@param target_mc: The MovieClip instance on which the Sound object operates.
	*/
	public function EventSound(target_mc:MovieClip) {
		super(target_mc);
		
		this.$eventDispatcher = new EventDispatcher();
		
		this.$setClassDescription('org.casaframework.sound.EventSound');
	}
	
	/**
		@sends onID3 = function(sender:EventSound, id3:Object) {}
	*/
	private function onID3():Void {
		this.dispatchEvent(EventSound.EVENT_ID3, this, this.id3);
	}
	
	/**
		@sends onLoad = function(sender:EventSound, success:Boolean) {}
	*/
	private function onLoad(success:Boolean):Void {
		this.dispatchEvent(EventSound.EVENT_LOAD, this, success);
	}
	
	/**
		@sends onSoundComplete = function(sender:EventSound) {}
	*/
	private function onSoundComplete():Void {
		this.dispatchEvent(EventSound.EVENT_SOUND_COMPLETE, this);
	}
	
	public function toString():String {
		return '[' + this.$instanceDescription + ']';
	}

	private function $setClassDescription(description:String):Void {
		this.$instanceDescription = description;
	}
	
	public function dispatchEvent(eventName:String):Boolean {
		return this.$eventDispatcher.dispatchEvent.apply(this.$eventDispatcher, arguments);
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
	
	public function destroy():Void {
		this.$eventDispatcher.destroy();
		delete this.$eventDispatcher;
		delete this.$instanceDescription;
	}
}
