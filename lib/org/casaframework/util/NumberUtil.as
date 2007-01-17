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
	@author David Nelson
	@version 11/24/06
*/

class org.casaframework.util.NumberUtil {
	
	public static function min(val1:Number, val2:Number):Number {
		if (val1 == undefined || val2 == undefined)
			return (val2 == undefined) ? val1 : val2;
		
		return Math.min(val1, val2);
	}
	
	public static function max(val1:Number, val2:Number):Number {
		if (val1 == undefined || val2 == undefined) 
			return (val2 == undefined) ? val1 : val2;
		
		return Math.max(val1, val2);
	}
	
	public static function randomInteger(min:Number, max:Number):Number {
		return min + Math.floor(Math.random() * (max + 1 - min));
	}
	
	public static function isEven(num:Number):Boolean {
		return (num & 1) == 0;
	}
	
	public static function isOdd(num:Number):Boolean {
		return !NumberUtil.isEven(num);
	}
	
	public static function isInteger(num:Number):Boolean {
		return (num % 1) == 0;
	}
	
	public static function roundToPlace(num:Number, place:Number):Number {
		var p:Number = Math.pow(10, Math.round(place));
		
		return Math.round(num * p) / p;
	}
	
	public static function isBetween(num:Number, val1:Number, val2:Number):Boolean {
		var min:Number = (val1 <= val2) ? val1 : val2;
		var max:Number = (val1 >= val2) ? val1 : val2;
		
		return !(num < min || num > max);
	}
	
	public static function makeBetween(num:Number, val1:Number, val2:Number):Number {
		return Math.min(Math.max(num, (val1 <= val2) ? val1 : val2), (val1 >= val2) ? val1 : val2);
	}
	
	public static function createStepsBetween(begin:Number, end:Number, steps:Number): /*Number*/ Array {
		steps++;
		
		var i:Number = 0;
		var stepsBetween: /*Number*/ Array = new Array();
		var increment:Number = (end - begin) / steps;
		
		while (++i < steps) stepsBetween.push((i * increment) + begin);
		
		return stepsBetween;
	}
	
	public static function format(numberToFormat:Number, minLength:Number, thouDelim:String, fillChar:String):String {
		var num:String = numberToFormat.toString();
		var len:Number = num.length;
		
		if (thouDelim != undefined) {
			var numSplit:Array = num.split('');
			var counter:Number = 3;
			var i:Number       = numSplit.length;
			
			while (--i > 0) {
				counter--;
				if (counter == 0) {
					counter = 3;
					numSplit.splice(i, 0, thouDelim);
				}
			}
			
			num = numSplit.join('');
		}
		
		if (minLength != undefined) {
			if (len < minLength) {
				minLength -= num.length;
				var addChar:String = (fillChar == undefined) ? '0' : fillChar;
				while (minLength--) num = addChar + num;
			}
		}
		
		return num;
	}
	
	public static function addLeadingZero(num:Number):String {
		return (num < 10) ? '0' + num : num.toString();
	}
	
	private function NumberUtil() {} // Prevents instance creation
}