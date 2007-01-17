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

import org.casaframework.load.base.BytesLoad;
import org.casaframework.util.LoadUtil;
import org.casaframework.math.Percent;

/**
	Provides a easier way to load FLVs and includes additional events notifying buffer progress.

	@author Aaron Clinger
	@version 12/22/06
	@since Flash Player 7
	@example
		<code>
			function onBufferProgress(sender:FlvLoad, percentBuffered:Percent, secondsTillBuffered:Number):Void {
				trace("Video " + Math.round(percentBuffered.getPercentage()) +"% buffered.");
				trace("Video will be buffered in " + Math.round(secondsTillBuffered) + " seconds.");
			}
			
			function onBufferComplete(sender:FlvLoad):Void {
				this.flvLoad.getNetStream().pause(false);
			}
			
			var flvLoad:FlvLoad = new FlvLoad(this.myVideo, "test.flv");
			this.flvLoad.addEventObserver(this, FlvLoad.EVENT_BUFFER_PROGRESS);
			this.flvLoad.addEventObserver(this, FlvLoad.EVENT_BUFFER_COMPLETE);
			this.flvLoad.start();
		</code>
*/

class org.casaframework.load.media.video.FlvLoad extends BytesLoad {
	public static var EVENT_STATUS:String          = 'onStatus';
	public static var EVENT_META_DATA:String       = 'onMetaData';
	public static var EVENT_BUFFER_PROGRESS:String = 'onBufferProgress';
	public static var EVENT_BUFFER_COMPLETE:String = 'onBufferComplete';
	private var $target:Video;
	private var $stream:NetStream;
	private var $connection:NetConnection;
	private var $duration:Number;
	private var $startTime:Number;
	private var $bufferPercent:Percent;
	private var $bufferSeconds:Number;
	private var $pause:Boolean;
	private var $hasBuffered:Boolean;
	private var $readyToCalcBuffer:Boolean;
	
	
	/**
		Defines file and location of load triggered by {@link #start}.
		
		@param target_vid: A path to a Video container where the file specified by <code>flvPath</code> should be loaded into.
		@param flvPath: The absolute or relative URL of the FLV file to be loaded.
		@param pause: <strong>[optional]</strong> Indicates to pause video until at start <code>true</code>, or to let the video automatically play <code>false</code>; defaults to <code>true</code>.
		@param duration: <strong>[optional]</strong> Length of FLV in seconds; if left undefined duration is taken from the FLV's meta data.
	*/
	public function FlvLoad(target_vid:Video, flvPath:String, pause:Boolean, duration:Number) {
		super(target_vid, flvPath);
		
		this.$initNetObjects();
		
		this.$pause = (pause == undefined) ? true : pause;
		
		if (!isNaN(duration)) 
			this.$duration = Math.max(duration - 2, 0); // Making two seconds shorter to insure a good buffer.
		
		this.$setClassDescription('org.casaframework.load.media.video.FlvLoad');
	}
	
	/**
		@return Returns Video specified in {@link #FlvLoad}.
	*/
	public function getVideo():Video {
		return this.$target;
	}
	
	/**
		@return Returnes the NetStream object being used internally to load and control the FLV.
	*/
	public function getNetStream():NetStream {
		return this.$stream;
	}
	
	public function getBytesLoaded():Number {
		return this.$stream.bytesLoaded;
	}
	
	public function getBytesTotal():Number {
		return this.$stream.bytesTotal;
	}
	
	public function destroy():Void {
		this.$stopLoad();
		
		this.$bufferPercent.destroy();
		
		delete this.$stream;
		delete this.$connection;
		delete this.$readyToCalcBuffer;
		delete this.$bufferPercent;
		delete this.$bufferSeconds;
		delete this.$duration;
		delete this.$startTime;
		delete this.$pause;
		delete this.$hasBuffered;
		
		super.destroy();
	}
	
	private function $startLoad():Void {
		this.$startTime = getTimer();
		this.$readyToCalcBuffer = this.$hasBuffered = false;
		
		delete this.$bufferPercent;
		delete this.$bufferSeconds;
		
		super.$startLoad();
		
		this.$stream.play(this.$filePath);
		this.$stream.pause(this.$pause);
	}
	
	private function $stopLoad():Void {
		super.$stopLoad();
		
		this.$stream.close();
		this.getVideo().clear();
	}
	
	private function $initNetObjects():Void {
		this.$connection = new NetConnection();
		this.$connection.connect(null);
		
		this.$stream = new NetStream(this.$connection);
		
		this.$target.attachVideo(this.$stream);
		
		var _this:FlvLoad = this;
		this.$stream.onStatus = function(infoObject:Object):Void {
			_this.$onStatus(infoObject);
		};
//		this.$stream.onMetaData = function(infoObject:Object):Void {
//			_this.$onMetaData(infoObject);
//		};
	}
	
	private function $loadProgress(bytesLoaded:Number, currentTime:Number):Void {
		super.$loadProgress(bytesLoaded, currentTime);
		this.$calculateBuffer(currentTime);
	}
	
	/**
		@sends onStatus = function(sender:FlvLoad, infoObject:Object) {}
	*/
	private function $onStatus(infoObject:Object):Void {
		if (infoObject.code.toLowerCase() == 'netstream.play.streamnotfound')
			this.$retryLoad();
		
		this.dispatchEvent(FlvLoad.EVENT_STATUS, this, infoObject);
	}
	
	/**
		@sends onMetaData = function(sender:FlvLoad, infoObject:Object) {}
	*/
	private function $onMetaData(infoObject:Object):Void {
		if (this.$duration == undefined)
			if (!isNaN(infoObject.duration))
				this.$duration = Math.max(infoObject.duration - 2, 0); // Making two seconds shorter to insure a good buffer.
		
		this.dispatchEvent(FlvLoad.EVENT_META_DATA, this, infoObject);
	}
	
	/**
		@sends onBufferProgress = function(sender:FlvLoad, percentBuffered:Percent, secondsTillBuffered:Number) {}
		@sends onBufferComplete = function(sender:FlvLoad) {}
	*/
	private function $calculateBuffer(currentTime:Number):Void {
		if (!isNaN(this.$duration) && !this.$hasBuffered) {
			if (this.$readyToCalcBuffer) {
				var bufferInfo:Object   = LoadUtil.calculateBuffer(this.getBytesLoaded(), this.getBytesTotal(), this.$startTime, currentTime, this.$duration);
				var decimalPer:Number   = bufferInfo.percent.getDecimalPercentage();
				var valueChange:Boolean = false;
				
				if (decimalPer > this.$bufferPercent.getDecimalPercentage() || this.$bufferPercent == undefined) {
					this.$bufferPercent.setDecimalPercentage(bufferInfo.percent.getDecimalPercentage());
					valueChange = true;
				}
				
				if (bufferInfo.seconds < this.$bufferSeconds || isNaN(this.$bufferSeconds)) {
					this.$bufferSeconds = bufferInfo.seconds;
					valueChange = true;
				}
				
				if (valueChange) {
					this.dispatchEvent(FlvLoad.EVENT_BUFFER_PROGRESS, this, this.$bufferPercent.clone(), this.$bufferSeconds);
			
					if (decimalPer >= 1) {
						this.$hasBuffered = true;
						this.dispatchEvent(FlvLoad.EVENT_BUFFER_COMPLETE, this);
					}
				}
			} else {
				if (currentTime - this.$startTime > 2000)
					this.$readyToCalcBuffer = true;
			}
		}
	}
	
	private function $onComplete():Void {
		if (!this.$hasBuffered) {
			this.$hasBuffered = true;
			this.dispatchEvent(FlvLoad.EVENT_BUFFER_PROGRESS, this, new Percent(1), 0);
			this.dispatchEvent(FlvLoad.EVENT_BUFFER_COMPLETE, this);
		}
		
		super.$onComplete();
	}
}