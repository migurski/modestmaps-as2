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

import org.casaframework.load.base.RetryableLoad;
import org.casaframework.load.base.BytesLoadInterface;
import org.casaframework.time.EnterFrame;

/**
	Base bytes load class for items where methods <code>getBytesLoaded</code> and <code>getBytesTotal</code> are available. Class needs to be extended further to function properly.
	
	@author Aaron Clinger
	@version 12/22/06
	@since Flash Player 7
*/

class org.casaframework.load.base.BytesLoad extends RetryableLoad implements BytesLoadInterface {
	public static var EVENT_LOAD_PROGRESS:String = 'onLoadProgress';
	public static var EVENT_INSTANTIATE:String   = 'onInstantiate';
	public static var loadTimeout:Number = 8000;
	private var $loadTimeout:Number;
	private var $previousTime:Number;
	private var $previousBytesLoaded:Number;
	private var $isProgressing:Boolean;
	private var $framePulse:EnterFrame;
	
	/**
		@param target: A path to a container where the file specified by <code>filePath</code> should be loaded into.
		@param filePath: The absolute or relative URL of the file to be loaded.
	*/
	private function BytesLoad(target:Object, filePath:String) {
		super(target, filePath);
		
		this.setLoadTimeout(BytesLoad.loadTimeout);
		
		this.$setClassDescription('org.casaframework.load.base.BytesLoad');
	}
	
	/**
		{@inheritDoc}
		
		@usageNote Class defaults to <code>8000</code> milliseconds.
	*/
	public function setLoadTimeout(loadTimeout:Number):Void {
		this.$loadTimeout = loadTimeout;
	}
	
	public function getBytesLoaded():Number {
		return this.$target.getBytesLoaded();
	}
	
	public function getBytesTotal():Number {
		return this.$target.getBytesTotal();
	}
	
	public function destroy():Void {
		this.$clean();
		
		delete this.$loadTimeout;
		
		super.destroy();
	}
	
	/**
		@sends onLoadProgress = function(sender:BytesLoad, bytesLoaded:Number, bytesTotal:Number) {}
	*/
	private function $checkLoadProgress():Void {
		var bl:Number = this.getBytesLoaded();
		var bt:Number = this.getBytesTotal();
		
		var currentTime:Number = getTimer();
		
		if (bl < 50 || bl == this.$previousBytesLoaded || isNaN(bl) || isNaN(bt)) {
			if (currentTime - this.$previousTime >= this.$loadTimeout)
				this.$retryLoad();
			return;
		}
		
		this.$loadProgress(bl, currentTime);
		this.dispatchEvent(BytesLoad.EVENT_LOAD_PROGRESS, this, bl, bt);
		
		this.$checkForLoadComplete();
	}
	
	/**
		If target in subclass has an reliable <code>"onLoad"</code> handler overriding this to a bank method and follow docs located: {@link Load#$remapOnLoadHandler}. Otherwise leave as is.
	*/
	private function $checkForLoadComplete():Void {
		if (this.getBytesLoaded() >= this.getBytesTotal())
			this.$onComplete();
	}
	
	/**
		@sends onInstantiate = function(sender:BytesLoad) {}
	*/
	private function $loadProgress(bytesLoaded:Number, currentTime:Number):Void {
		if (!this.$isProgressing) {
			if (bytesLoaded > 0) {
				this.$isProgressing = true;
				this.dispatchEvent(BytesLoad.EVENT_INSTANTIATE, this);
			}
		}
		
		this.$previousBytesLoaded = bytesLoaded;
		this.$previousTime        = currentTime;
	}
	
	/**
		<strong>This function needs to be extended by a subclass.</strong>
	*/
	private function $startLoad():Void {
		super.$startLoad();
		
		this.$isProgressing = false;
		
		this.$loadProgress(0, getTimer());
		
		this.$framePulse = EnterFrame.getInstance();
		this.$framePulse.addEventObserver(this, EnterFrame.EVENT_ENTER_FRAME, '$checkLoadProgress');
	}
	
	private function $retryLoad():Void {
		this.$framePulse.removeEventObserversForScope(this);
		
		super.$retryLoad();
	}
	
	private function $onComplete():Void {
		this.$framePulse.removeEventObserversForScope(this);
		
		var prevBytesLoaded:Number = this.$previousBytesLoaded;
		
		this.$loadProgress(this.getBytesTotal(), null);
		
		if (this.getBytesTotal() != prevBytesLoaded)
			this.dispatchEvent(BytesLoad.EVENT_LOAD_PROGRESS, this, this.getBytesTotal(), this.getBytesTotal());
		
		super.$onComplete();
	}
	
	private function $clean():Void {
		this.$framePulse.removeEventObserversForScope(this);
		
		delete this.$isProgressing;
		delete this.$framePulse;
		delete this.$previousBytesLoaded;
		delete this.$previousTime;
		
		super.$clean();
	}
}