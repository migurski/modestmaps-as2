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
	Dispatches stage "onResize" event to observers. Should be used instead of <code>Stage.addListener</code>.
	
	@author Aaron Clinger
	@version 12/20/06
	@example
		<code>
			function onResize(stageWidth:Number, stageHeight:Number):Void {
				trace("Stage resized to " + stageWidth + " wide by " + stageHeight + " tall.");
			}
	
			var stageInstance:EventStage = EventStage.getInstance();
			this.stageInstance.addEventObserver(this, EventStage.EVENT_RESIZE);
		</code>
*/

class org.casaframework.stage.EventStage extends EventDispatcher {
	public static var EVENT_RESIZE:String = 'onResize';
	private static var $stageInstance:EventStage;
	
	/**
		@return {@link EventStage} instance.
	*/
	public static function getInstance():EventStage {
		if (EventStage.$stageInstance == undefined) EventStage.$stageInstance = new EventStage(); 
		return EventStage.$stageInstance;
	}
	
	private function EventStage() {
		super();
		
		Stage.addListener(this);
		
		this.$setClassDescription('org.casaframework.stage.EventStage');
	}
	
	/**
		@sends onResize = function(stageWidth:Number, stageHeight:Number) {}
	*/
	private function onResize():Void {
		this.dispatchEvent(EventStage.EVENT_RESIZE, Stage.width, Stage.height);
	}
}