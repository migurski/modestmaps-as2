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

import org.casaframework.util.ConversionUtil;
import org.casaframework.util.NumberUtil;
import org.casaframework.math.Percent;

/**
	@author Aaron Clinger
	@version 11/19/06
*/

class org.casaframework.util.LoadUtil {
	
	/**
		Calculates the percent loaded.
		
		@param loadTarget: Any object that has either <code>getBytesLoaded</code>/<code>getBytesTotal</code> or <code>bytesLoaded</code>/<code>bytesTotal</code> methods.
		@return Percent loaded.
	*/
	public static function getPercentLoaded(loadTarget:Object):Percent {
		if (loadTarget.getBytesLoaded != undefined)
			return new Percent(loadTarget.getBytesLoaded() / loadTarget.getBytesTotal());
		else if (loadTarget.bytesLoaded != undefined)
			return new Percent(loadTarget.bytesLoaded / loadTarget.bytesTotal);
	}
	
	/**
		Calculates the load speed in KBps.
		
		@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
		@param startTime: Time in milliseconds when the load started. Can be <code>0</code>.
		@param elapsedTime: Time in milliseconds since the load started or time when load completed.
		@return Kilobytes per second.
		@usageNote This gets kiloBYTES per second, not kilobits per second.
	*/
	public static function calculateKBps(bytesLoaded:Number, startTime:Number, elapsedTime:Number):Number {
		var elapsed:Number   = (elapsedTime - startTime) / 1000;
		var sizeInKBs:Number = ConversionUtil.bytesToKilobytes(bytesLoaded);
		
		return sizeInKBs / elapsed;
	}
	
	/**
		Calculates the load speed in kbps.
		
		@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
		@param startTime: Time in milliseconds when the load started. Can be <code>0</code>.
		@param elapsedTime: Time in milliseconds since the load started or time when load completed.
		@return Kilobits per second.
		@usageNote This gets kiloBITS per second, not kilobytes per second.
	*/
	public static function calculateKbps(bytesLoaded:Number, startTime:Number, elapsedTime:Number):Number {
		var elapsed:Number   = (elapsedTime - startTime) / 1000;
		var sizeInKbs:Number = ConversionUtil.bytesToKilobits(bytesLoaded);
		
		return sizeInKbs / elapsed;
	}
	
	/**
		Calculates the time and percentage until movie/animation has buffered.
		
		@param bytesLoaded: Number of bytes that have loaded between <code>startTime</code> and <code>elapsedTime</code>.
		@param bytesTotal: Number of bytes total to be loaded.
		@param startTime: Time in milliseconds when the load started. Can be <code>0</code>.
		@param elapsedTime: Time in milliseconds since the load started or time when load completed.
		@param lengthInSeconds: Length in seconds of the video or animation being loaded. Can also be calculated by dividing <code>_totalframes</code> by the FPS (frames per second).
		@return An object with properties <code>seconds</code> and <code>percent</code> defined. Property <code>percent</code> is a {@link Percent} object.
		@usage
			<code>
				var bufferInfo:Object = LoadUtil.calculateBuffer(102400, 1536000, 0, 5000, 30);
				trace("File will be buffered in " + bufferInfo.seconds + " seconds.");
				trace("File is " + bufferInfo.percent.getPercentage() + "% buffered.");
			</code>
	*/
	public static function calculateBuffer(bytesLoaded:Number, bytesTotal:Number, startTime:Number, elapsedTime:Number, lengthInSeconds:Number):Object {
		var kBps:Number         = LoadUtil.calculateKBps(bytesLoaded, startTime, elapsedTime);
		var totalKBs:Number     = ConversionUtil.bytesToKilobytes(bytesTotal);
		var totalWait:Number    = totalKBs / kBps - lengthInSeconds;
		var secsTillLoad:Number = Math.ceil(ConversionUtil.bytesToKilobytes(bytesTotal - bytesLoaded) / kBps);
		
		var buffer:Object = new Object();
		buffer.seconds    = Math.max(secsTillLoad - lengthInSeconds, 0);
		buffer.percent    = new Percent(NumberUtil.makeBetween(1 - buffer.seconds / totalWait, 0, 1));
		
		return buffer;
	}
	
	private function LoadUtil() {} // Prevents instance creation
}