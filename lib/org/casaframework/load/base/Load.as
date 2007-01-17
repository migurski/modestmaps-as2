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
import org.casaframework.load.base.LoadInterface;
import org.casaframework.time.FrameDelay;

/**
	Base load class. Class needs to be extended further to function properly.
	
	@author Aaron Clinger
	@version 12/22/06
	@since Flash Player 7
*/

class org.casaframework.load.base.Load extends EventDispatcher implements LoadInterface {
	public static var EVENT_LOAD_START:String    = 'onLoadStart';
	public static var EVENT_LOAD_ERROR:String    = 'onLoadError';
	public static var EVENT_LOAD_COMPLETE:String = 'onLoadComplete';
	public static var EVENT_LOAD_INIT:String     = 'onLoadInit';
	private var $filePath:String;
	private var $target:Object;
	private var $hasLoaded:Boolean;
	private var $isLoading:Boolean;
	private var $frameDelay:FrameDelay;
	
	
	/**
		@param target: A path to a container where the file specified by <code>filePath</code> should be loaded into.
		@param filePath: The absolute or relative URL of the file to be loaded.
	*/
	private function Load(target:Object, filePath:String) {
		super();
		
		this.$target    = target;
		this.$filePath  = filePath;
		this.$hasLoaded = this.$isLoading = false;
		
		this.$setClassDescription('org.casaframework.load.base.Load');
	}
	
	/**
		Begins the loading process and broadcasts events to observers.
		
		@usageNote Use {@link EventDispatcher#addEventObserver} to listen for broadcasted events.
		@sends onLoadStart = function(sender:Load) {}
	*/
	public function start():Void {
		if (this.isLoading() || this.hasLoaded())
			return;
		
		if (this.$filePath == undefined || this.$target == undefined) {
			this.dispatchEvent(Load.EVENT_LOAD_ERROR, this);
			return;
		}
		
		this.$startLoad();
		
		this.dispatchEvent(Load.EVENT_LOAD_START, this);
	}
	
	/**
		Unloads a file that has previously loaded, or cancels a currently loading file from completing.
		
		@usageNote If you issue this command while a file is loading, event <code>onLoadError</code> is also invoked.
	*/
	public function stop():Void {
		if (this.isLoading())
			this.dispatchEvent(Load.EVENT_LOAD_ERROR, this);
		
		this.$stopLoad();
	}
	
	public function getFilePath():String {
		return this.$filePath;
	}
	
	public function hasLoaded():Boolean {
		return this.$hasLoaded;
	}
	
	public function isLoading():Boolean {
		return this.$isLoading;
	}
	
	public function destroy():Void {
		this.$clean();
		
		delete this.$hasLoaded;
		delete this.$filePath;
		delete this.$target;
		
		super.destroy();
	}
	
	/**
		<strong>This function needs to be extended by a subclass.</strong>
	*/
	private function $startLoad():Void {
		this.$isLoading = true;
		this.$hasLoaded = false;
	}
	
	/**
		<strong>This function needs to be extended by a subclass.</strong>
	*/
	private function $stopLoad():Void {
		this.$clean();
		this.$hasLoaded = false;
	}
	
	/**
		<strong>This function needs to be called by a subclass.</strong>
		
		If target in subclass has an reliable <code>"onLoad"</code> handler call this method after target is defined in the constructor.
		
		@param loadContainer: <strong>[optional]</strong> Defines object file is loading into and has the event handler <code>"onLoad"</code>; defaults to <code>$target</code>.
	*/
	private function $remapOnLoadHandler(loadContainer:Object):Void {
		var _this:Load  = this;
		var targ:Object = (loadContainer == undefined) ? this.$target : loadContainer;
		
		targ.onLoad = function(success:Boolean):Void {
			_this.$onLoad(success);
		};
	}
	
	private function $onLoad(success:Boolean):Void {
		if (success)
			this.$onComplete();
	}
	
	/**
		@sends onLoadComplete = function(sender:Load) {}
		@sends onLoadError = function(sender:Load) {}
	*/
	private function $onComplete():Void {
		this.$hasLoaded = true;
		
		this.dispatchEvent(Load.EVENT_LOAD_COMPLETE, this);
		
		this.$frameDelay = new FrameDelay(this, '$onInitialized');
		this.$frameDelay.start();
	}
	
	/**
		@sends onLoadInit = function(sender:Load) {}	
	*/
	private function $onInitialized():Void {
		this.dispatchEvent(Load.EVENT_LOAD_INIT, this);
		this.$clean();
	}
	
	private function $clean():Void {
		this.$frameDelay.destroy();
		
		delete this.$frameDelay;
		delete this.$isLoading;
	}
}