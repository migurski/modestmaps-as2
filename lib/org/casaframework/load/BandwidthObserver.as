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
import org.casaframework.time.Stopwatch;
import org.casaframework.util.LoadUtil;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.ConversionUtil;
import org.casaframework.load.base.BytesLoad;
import org.casaframework.load.base.Load;

/**
	Calculates load speeds for individual watched files and remembers the values for comparison with other loads.

	@author Aaron Clinger
	@version 12/20/06
	@since Flash Player 7
	@example
		<code>
			this.createEmptyMovieClip("loadZone_mc", this.getNextHighestDepth());
			
			function onImageLoadProgress(sender:MediaLoad, bytesLoaded:Number, bytesTotal:Number):Void {
				trace("File is loading at " + this.bandwidth.getKBps() + " kBps.");
			}
			
			var mediaLoad:MediaLoad = new MediaLoad(this.loadZone_mc, "test.jpg");
			var bandwidth:BandwidthObserver = BandwidthObserver.observe(this.mediaLoad);
			
			this.mediaLoad.addEventObserver(this, BytesLoad.EVENT_LOAD_PROGRESS, "onImageLoadProgress");
			this.mediaLoad.start();
		</code>
	@usageNote This class only calculates kiloBYTES per seconds, not the bandwidth speed norm kilobits per second. Bits are not very useful in flash; flash only knows object's size in bytes so kBps is a much more useful number. If you need to find kbps or bits use {@link ConversionUtil} to convert the values.
*/

class org.casaframework.load.BandwidthObserver extends CoreObject {
	private var $loadItem:BytesLoad;
	private var $fileLargeEnough:Boolean;
	private var $stopwatch:Stopwatch;
	private var $kBps:Number;
	
	private static var $observedLoads:Array;
	private static var $hasInit:Boolean;
	
	
	/**
		Defines load to observe and calculate the speed of transfer in kBps.
		
		@param loadItem: File to observe the request and download speed. Can be any class that inherits from {@link BytesLoad}. <code>loadItem</code> also has to dispatch events <code>"onLoadStart"</code>, <code>"onLoadProgress"</code>, <code>"onLoadComplete"</code> and <code>"onLoadError"</code>.
		@return Returns {@link BandwidthObserver} instance.
	*/
	public static function observe(loadItem:BytesLoad):BandwidthObserver {
		if (!BandwidthObserver.$hasInit) {
			BandwidthObserver.$observedLoads = new Array();
			BandwidthObserver.$hasInit       = true;
		} else {
			var len:Number = BandwidthObserver.$observedLoads.length;
			while (len--)
				if (BandwidthObserver.$observedLoads[len].getLoadItem() == loadItem)
					return;
		}
		
		var observer:BandwidthObserver = new BandwidthObserver(loadItem);
		BandwidthObserver.$observedLoads.push(observer);
		
		return observer;
	}
	
	/**
		@return Returns the average kBps of all observed loads.
	*/
	public static function getAverageKBps():Number {
		return ArrayUtil.average(BandwidthObserver.$getAllKBpsValues());
	}
	
	/**
		@return Returns the lowest/slowest kBps of all observed loads.
	*/
	public static function getLowestKBps():Number {
		return ArrayUtil.getLowestValue(BandwidthObserver.$getAllKBpsValues());
	}
	
	/**
		@return Returns the highest/fastest kBps of all observed loads.
	*/
	public static function getHighestKBps():Number {
		return ArrayUtil.getHighestValue(BandwidthObserver.$getAllKBpsValues());
	}
	
	private static function $getAllKBpsValues(): /*Number*/ Array {
		var len:Number = BandwidthObserver.$observedLoads.length;
		var kBps: /*Number*/ Array = new Array();
		var val:Number;
		
		while (len--) {
			val = BandwidthObserver.$observedLoads[len].getKBps();
			if (val != undefined)
				kBps.push(val);
		}
		
		return kBps;
	}
	
	
	private function BandwidthObserver(loadItem:BytesLoad) {
		super();
		
		this.$stopwatch = new Stopwatch();
		
		this.$loadItem = loadItem;
		this.$loadItem.addEventObserver(this.$stopwatch, Load.EVENT_LOAD_START, 'start');
		this.$loadItem.addEventObserver(this, BytesLoad.EVENT_LOAD_PROGRESS, '$calculateKBps');
		this.$loadItem.addEventObserver(this, Load.EVENT_LOAD_COMPLETE, '$loadComplete');
		this.$loadItem.addEventObserver(this, Load.EVENT_LOAD_ERROR, '$clean');
		
		this.$setClassDescription('org.casaframework.load.BandwidthObserver');
	}
	
	/**
		@return returns the kBps of the specific load this instance is observing.
	*/
	public function getKBps():Number {
		return this.$kBps;
	}
	
	/**
		@return Returns the load instance being observed.
	*/
	public function getLoadItem():BytesLoad {
		return this.$loadItem;
	}
	
	public function destroy():Void {
		this.$clean();
		delete this.$loadItem;
		
		super.destroy();
	}
	
	private function $calculateKBps(sender:Object, bytesLoaded:Number, bytesTotal:Number):Void {
		var kB:Number = LoadUtil.calculateKBps(bytesLoaded, 0, this.$stopwatch.getTime());
		
		switch (this.$fileLargeEnough) {
			case undefined :
				this.$fileLargeEnough = ConversionUtil.bytesToKilobytes(bytesTotal) >= 30;
				break;
			case true :
				this.$kBps = kB;
				break;
		}
	}
	
	private function $loadComplete():Void {
		var currentTime:Number = this.$stopwatch.getTime();
		
		if (currentTime < 2000)
			this.$clean();
		else {
			this.$removeBandwidthObserver();
			
			if (this.$kBps == undefined)
				this.$kBps = LoadUtil.calculateKBps(this.getLoadItem().getBytesLoaded(), 0, currentTime);
		}
	}
	
	private function $removeBandwidthObserver():Void {
		ArrayUtil.removeArrayItem(BandwidthObserver.$observedLoads, this.$loadItem);
		
		this.$loadItem.removeEventObserversForScope(this);
		this.$loadItem.removeEventObserversForScope(this.$stopwatch);
		
		this.$stopwatch.destroy();
		
		delete this.$stopwatch;
		delete this.$fileLargeEnough;
	}
	
	private function $clean():Void {
		this.$removeBandwidthObserver();
		
		delete this.$kBps;
	}
}