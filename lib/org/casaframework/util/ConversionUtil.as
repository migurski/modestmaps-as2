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

/**
	@author Aaron Clinger
	@version 08/25/06
*/

class org.casaframework.util.ConversionUtil {
	
	
	public static function bitsToBytes(bits:Number):Number { return bits / 8; }
	public static function bitsToKilobits(bits:Number):Number { return bits / 1024; }
	public static function bitsToKilobytes(bits:Number):Number { return bits / 8192; }
	
	public static function bytesToBits(bytes:Number):Number { return bytes * 8; }
	public static function bytesToKilobits(bytes:Number):Number { return bytes / 128; }
	public static function bytesToKilobytes(bytes:Number):Number { return bytes / 1024; }
	
	public static function kilobitsToBits(kilobits:Number):Number { return kilobits * 1024; }
	public static function kilobitsToBytes(kilobits:Number):Number { return kilobits * 128; }
	public static function kilobitsToKilobytes(kilobits:Number):Number { return kilobits / 8; }
	
	public static function kilobytesToBits(kilobytes:Number):Number { return 1 * 8192; }
	public static function kilobytesToBytes(kilobytes:Number):Number { return kilobytes * 1024; }
	public static function kilobytesToKilobits(kilobytes:Number):Number { return kilobytes * 8; }
	
	
	public static function millisecondsToSeconds(milliseconds:Number):Number { return milliseconds / 1000; }
	public static function millisecondsToMinutes(milliseconds:Number):Number { return ConversionUtil.secondsToMinutes(ConversionUtil.millisecondsToSeconds(milliseconds)); }
	public static function millisecondsToHours(milliseconds:Number):Number { return ConversionUtil.minutesToHours(ConversionUtil.millisecondsToMinutes(milliseconds)); }
	public static function millisecondsToDays(milliseconds:Number):Number { return ConversionUtil.hoursToDays(ConversionUtil.millisecondsToHours(milliseconds)); }
	
	public static function secondsToMilliseconds(seconds:Number):Number { return seconds * 1000; }
	public static function secondsToMinutes(seconds:Number):Number { return seconds / 60; }
	public static function secondsToHours(seconds:Number):Number { return ConversionUtil.minutesToHours(ConversionUtil.secondsToMinutes(seconds)); }
	public static function secondsToDays(seconds:Number):Number { return ConversionUtil.hoursToDays(ConversionUtil.secondsToHours(seconds)); }
	
	public static function minutesToMilliseconds(minutes:Number):Number { return ConversionUtil.secondsToMilliseconds(ConversionUtil.minutesToSeconds(minutes)); }
	public static function minutesToSeconds(minutes:Number):Number { return minutes * 60; }
	public static function minutesToHours(minutes:Number):Number { return minutes / 60; }
	public static function minutesToDays(minutes:Number):Number { return ConversionUtil.hoursToDays(ConversionUtil.minutesToHours(minutes)); }
	
	public static function hoursToMilliseconds(hours:Number):Number { return ConversionUtil.secondsToMilliseconds(ConversionUtil.hoursToSeconds(hours)); }
	public static function hoursToSeconds(hours:Number):Number { return ConversionUtil.minutesToSeconds(ConversionUtil.hoursToMinutes(hours)); }
	public static function hoursToMinutes(hours:Number):Number { return hours * 60; }
	public static function hoursToDays(hours:Number):Number { return hours / 24; }
	
	public static function daysToMilliseconds(days:Number):Number { return ConversionUtil.secondsToMilliseconds(ConversionUtil.daysToSeconds(days)); }
	public static function daysToSeconds(days:Number):Number { return ConversionUtil.minutesToSeconds(ConversionUtil.daysToMinutes(days)); }
	public static function daysToMinutes(days:Number):Number { return ConversionUtil.hoursToMinutes(ConversionUtil.daysToHours(days)); }
	public static function daysToHours(days:Number):Number { return days * 24; }
	
	
	private function ConversionUtil() {} // Prevents instance creation
}