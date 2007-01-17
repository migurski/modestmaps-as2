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

import org.casaframework.load.base.Load;
import org.casaframework.load.base.RetryableLoadInterface;

/**
	Retryable load class. Class needs to be extended further to function properly.
	
	@author Aaron Clinger
	@version 12/22/06
	@since Flash Player 7
*/

class org.casaframework.load.base.RetryableLoad extends Load implements RetryableLoadInterface {
	public static var EVENT_LOAD_RETRY:String = 'onLoadRetry';
	public static var loadRetries:Number = 2;
	private var $attempts:Number;
	private var $loadRetries:Number;
	
	
	/**
		@param target: A path to a container where the file specified by <code>filePath</code> should be loaded into.
		@param filePath: The absolute or relative URL of the file to be loaded.
	*/
	private function RetryableLoad(target:Object, filePath:String) {
		super(target, filePath);
		
		this.setLoadRetries(RetryableLoad.loadRetries);
		
		this.$setClassDescription('org.casaframework.load.base.RetryableLoad');
	}
	
	/**
		{@inheritDoc}
		
		@usageNote Class defaults to <code>2</code> additional retries / <code>3</code> total load attempts.
	*/
	public function setLoadRetries(loadRetries:Number):Void {
		this.$loadRetries = loadRetries;
	}
	
	public function destroy():Void {
		this.$clean();
		
		delete this.$loadRetries;
		
		super.destroy();
	}
	
	private function $startLoad():Void {
		var loadAttempts:Number = isNaN(this.$attempts) ? 0 : this.$attempts;
		this.$clean();
		this.$attempts = loadAttempts;
		
		super.$startLoad();
	}
	
	private function $onLoad(success:Boolean):Void {
		if (success)
			this.$onComplete();
		else
			this.$retryLoad();
	}
	
	/**
		@sends onLoadRetry = function(sends:RetryableLoad, attempts:Number) {}
	*/
	private function $retryLoad():Void {
		if (++this.$attempts > this.$loadRetries) {
			this.stop();
			return;
		}
		
		this.dispatchEvent(RetryableLoad.EVENT_LOAD_RETRY, this, this.$attempts);
		this.$startLoad();
	}
	
	private function $clean():Void {
		delete this.$attempts;
		
		super.$clean();
	}
}