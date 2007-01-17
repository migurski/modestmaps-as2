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
	@author Mike Creighton
	@version 11/01/06
*/

class org.casaframework.util.StringUtil {
	
	
	public static function toTitleCase(source:String):String {
		var t:Array  = source.split(' ');
		var i:Number = -1;
		var r:String = '';
		
		while (++i < t.length)
			r += t[i].substr(0, 1).toUpperCase() + t[i].substr(1) + ' ';
		
		return r.substr(0, -2);
	}
	
	public static function removeNumbersFromString(source:String):String {
		var i:Number = -1;
		
		while (++i < source.length) {
			if (!isNaN(source.substr(i, 1))) {
				source = StringUtil.removeAt(source, i);
				i--;
			}
		}
		
		return source;
	}
	
	public static function getNumbersFromString(source:String):String {
		var i:Number = -1;
		
		while (++i < source.length) {
			if (isNaN(source.substr(i, 1))) {
				source = StringUtil.removeAt(source, i);
				i--;
			}
		}
		
		return source;
	}
	
	public static function contains(source:String, search:String):Number {
		var i:Number     = source.indexOf(search);
		var total:Number = 0;
		
		while (source.indexOf(search, i++) > -1)
			total++;
		
		return total;
	}
	
	public static function removeExtraSpaces(source:String):String {
		var i:Number = -1;
		var char:String;
		var lastChar:String;
		
		while (++i < source.length) {
			char = source.substr(i, 1);
			if (char == ' ') {
				if (lastChar == ' ') {
					source = StringUtil.removeAt(source, i);
					i--;
				}
			}
			lastChar = char;
		}
		
		return source;
	}
	
	public static function remove(source:String, remove:String):String {
		return StringUtil.replace(source, remove, '');
	}
	
	public static function replace(source:String, remove:String, replaceWith:String):String {
		return source.split(remove).join(replaceWith);
	}
	
	public static function removeAt(source:String, point:Number):String {
		return StringUtil.replaceAt(source, point, '');
	}
	
	public static function replaceAt(source:String, point:Number, replaceWith:String):String {
		var parts:Array = source.split('');
		parts.splice(point, 1, replaceWith);
		return parts.join('');
	}
	
	public static function addAt(source:String, point:Number, addition:String):String {
		var parts:Array = source.split('');
		parts.splice(point, 0, addition);
		return parts.join('');
	}
	
	/**
	 * Extracts all the unique characters from a source String.
	 * 
	 * @param source: String to find unique characters within.
	 * @return String containing unique characters from source String.
	 */
	public static function getUniqueCharacters(source:String) : String {
		var unique:String = '';
		var i:Number      = -1;
		var char:String;
		
		while (++i < source.length){
			char = source.charAt(i);
			
			if (unique.indexOf(char, 0) == -1)
				unique += char;
		}
		
		return unique;
	}
	
	private function StringUtil() {} // Prevents instance creation
}
