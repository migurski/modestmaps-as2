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
import org.casaframework.control.RunnableInterface;
import org.casaframework.load.base.Load;
import org.casaframework.util.ArrayUtil;

/**
	Chains/cues load requests together in the order added. To be used when loading multiple items of same or different type.
	
	@author Aaron Clinger
	@version 12/20/06
	@example
		<code>
			var myLoadCue:LoadManager = LoadManager.getInstance();
			this.myLoadCue.setThreads(2);
			
			this.myLoadCue.addLoad(mediaLoadInstance);
			this.myLoadCue.addLoad(soundLoadInstance);
			this.myLoadCue.addLoad(xmlLoadInstance);
			
			this.myLoadCue.start();
		</code>
*/

class org.casaframework.load.LoadManager extends EventDispatcher implements RunnableInterface {
	public static var EVENT_LOAD_COMPLETE:String = 'onLoadComplete';
	public static var EVENT_LOAD_ERROR:String    = 'onLoadError';
	private static var $loadInstance:LoadManager;
	private var $isLoading:Boolean;
	private var $threads:Number;
	private var $cue: /*Load*/ Array;
	
	
	/**
		@return {@link LoadManager} instance.
	*/
	public static function getInstance():LoadManager {
		if (LoadManager.$loadInstance == undefined)
			LoadManager.$loadInstance = new LoadManager();
		
		return LoadManager.$loadInstance;
	}
	
	
	private function LoadManager() {
		super();
		
		this.$isLoading = false;
		this.$threads   = 1;
		this.$cue       = new Array();
		
		this.$setClassDescription('org.casaframework.load.LoadManager');
	}
	
	/**
		Adds item to be loaded in order. Can also be used to change a file from/to a priority load.
		
		@param loadItem: File to be added to the load cue. Can be any class that inherits from {@link Load}. <code>loadItem</code> also has to dispatch events <code>"onLoadComplete"</code> and <code>"onLoadError"</code>.
		@param priority: <strong>[optional]</strong> Indicates to add item to beginning of the cue/next file to load <code>true</code>, or to add it at the end of the cue <code>false</code>; defaults to <code>false</code>.
	*/
	public function addLoad(loadItem:Load, priority:Boolean):Void {
		var i:Number = ArrayUtil.indexOf(this.$cue, loadItem);
		if (i != -1)
			if (!loadItem.isLoading())
				this.$removeLoad(loadItem, i);
		
		loadItem.addEventObserver(this, LoadManager.EVENT_LOAD_COMPLETE, '$loadCompleted');
		loadItem.addEventObserver(this, LoadManager.EVENT_LOAD_ERROR, '$loadError');
		
		if (priority)
			this.$cue.unshift(loadItem);
		else
			this.$cue.push(loadItem);
		
		this.$checkCue();
	}	
	
	/**
		Removes item from the load cue. If file is currently loading the load is stopped.
		
		@param loadItem: File to be removed from the load cue.
	*/
	public function removeLoad(loadItem:Load):Void {
		var i:Number = ArrayUtil.indexOf(this.$cue, loadItem);
		if (i == -1)
			return;
		
		if (loadItem.isLoading())
			loadItem.stop();
		
		this.$removeLoad(loadItem, i);
	}
	
	/**
		Removes all items from the load cue and cancels any currently loading.
	*/
	public function removeAllLoads():Void {
		var l:Number = this.$cue.length;
		var loadItem:Load;
		while (l--) {
			loadItem = this.$cue[l];
			if (loadItem.isLoading())
				loadItem.stop();
			
			loadItem.removeEventObserversForScope(this);
			this.$cue.pop();
		}
	}
	
	/**
		Starts or resumes loading items from the cue.
	*/
	public function start():Void {
		if (this.$isLoading)
			return;
		
		this.$isLoading = true;
		this.$checkCue();
	}
	
	/**
		Stops loading items from the cue after the currently loading items complete loading.
	*/
	public function stop():Void {
		this.$isLoading = false;
	}
	
	/**
		Defines the number of simultaneous file requests/downloads.
		
		@param theads: The number of threads the class will theoretically use, though most browsers cap the amount of threads and hold the other requests in a cue. Pass <code>0</code> for unlimited threads.
		@usageNote Class defaults to <code>1</code> thread. 
	*/
	public function setThreads(threads:Number):Void {
		this.$threads = Math.max(0, Math.round(threads));
		this.$checkCue();
	}
	
	private function $checkCue():Void {
		var l:Number = this.$cue.length;
		
		while (l--)
			if (this.$cue[l].hasLoaded())
				this.$cue.splice(l, 1);
		
		if (!this.$isLoading)
			return;
		
		var t:Number = (this.$threads == 0) ? this.$cue.length : this.$threads;
		var i:Number = 0;
		
		l = this.$cue.length;
		while (l--)
			if (this.$cue[l].isLoading())
				i++;
		
		if (i >= t)
			return;
		
		t -= i;
		l = -1;
		while (++l < this.$cue.length) {
			if (!this.$cue[l].isLoading()) {
				this.$cue[l].start();
				if (--t == 0)
					return;
			}
		}
	}
	
	/**
		@sends onLoadCompleted = function(loadItem:Load) {}
	*/
	private function $loadCompleted(sender:Load):Void {
		this.dispatchEvent(LoadManager.EVENT_LOAD_COMPLETE, sender);
		this.$removeLoad(sender);
	}
	
	/**
		@sends onLoadError = function(loadItem:Load) {}
	*/
	private function $loadError(sender:Load):Void {
		this.dispatchEvent(LoadManager.EVENT_LOAD_ERROR, sender);
		this.$removeLoad(sender);
	}
	
	private function $removeLoad(loadItem:Load, position:Number):Void {
		loadItem.removeEventObserversForScope(this);
		
		if (position == undefined)
			ArrayUtil.removeArrayItem(this.$cue, loadItem);
		else
			this.$cue.splice(position, 1);
		
		this.$checkCue();
	}
}