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

import org.casaframework.util.NumberUtil;

/**
	@author Aaron Clinger
	@author David Nelson
	@version 12/12/06
	@since Flash Player 7
*/

class org.casaframework.util.ArrayUtil {
	
	/**
		Creates new Array comprised of only the non-identical elements of passed Array.

		@param inArray: Array to remove equivalent items.
		@return A new Array comprised of only unique elements.
		@usage
			<code>
				var numberArray:Array = new Array(1, 2, 3, 4, 4, 4, 4, 5);
				trace(ArrayUtil.removeDuplicates(this.numberArray));
			</code>
	*/
	public static function removeDuplicates(inArray:Array):Array {
		var i:Number = -1;
		var t:Array  = new Array();
		
		while (++i < inArray.length)
			if (ArrayUtil.contains(t, inArray[i]) == 0)
				t.push(inArray[i]);
		
		return t;
	}
	
	/**
		Modifies original Array by removing all items that are identical to passed <code>item</code>.

		@param tarArray: Array to remove passed <code>item</code>.
		@param item: Value to remove.
		@return The amount of removed elements that matched <code>item</code>, if none found returns <code>0</code>.
		@usage
			<code>
				var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
				trace("Removed " + ArrayUtil.removeArrayItem(this.numberArray, 7) + " items.");
				trace(this.numberArray);
			</code>
		@usageNote <code>item</code> can be any object; <code>Number</code>, <code>String</code>, <code>Object</code>, etc...
	*/
	public static function removeArrayItem(tarArray:Array, item:Object):Number {
		var l:Number = tarArray.length;
		var f:Number = 0;
		
		while (l--) {
			if (tarArray[l] == item) {
				tarArray.splice(l, 1);
				f++;
			}
		}
		
		return f;
	}
	
	/**
		Finds the position of the first instance of passed <code>item</code> in <code>inArray</code>.

		@param inArray: Array to find <code>item</code>'s position in.
		@param item: Object to find position of.
		@param startIndex: <strong>[optional]</strong> The starting position of the search.
		@return The first position number of the instance <code>item</code>; if none found returns <code>-1</code>.
		@usage
			<code>
				var colorArray = new Array("red", "blue", "pink", "black");
				trace("First postion of 'pink' is: " + ArrayUtil.indexOf(this.colorArray, "pink"));
			</code>
		@usageNote <code>item</code> can be any object; <code>Number</code>, <code>String</code>, <code>Object</code>, etc...
	*/
	public static function indexOf(inArray:Array, item:Object, startIndex:Number):Number {
		var i:Number = (startIndex == undefined) ? -1 : startIndex - 1;
		
		while (++i < inArray.length)
			if (inArray[i] == item)
				return i;
		
		return -1;
	}
	
	/**
		Finds if Array contains <code>item</code>.
		
		@param inArray: Array to search for <code>item</code> in.
		@param item: Object to find.
		@return The amount of <code>item</code>'s found; if none were found returns <code>0</code>.
		@usage
			<code>
				var numberArray:Array = new Array(1, 2, 3, 7, 7, 7, 4, 5);
				trace("numberArray contains " + ArrayUtil.contains(this.numberArray, 7) + " 7's.");
			</code>
		@usageNote If you are trying to find if an array contains an item or not and don't need to know the total, use #indexOf instead. <code>item</code> can be any object; <code>Number</code>, <code>String</code>, <code>Object</code>, etc...
	*/
	public static function contains(inArray:Array, item:Object):Number {
		var l:Number = inArray.length;
		var t:Number = 0;
		
		while (l--)
			if (inArray[l] == item)
				t++;
		
		return t;
	}
	
	/**
		Creates new Array composed of passed Array's items in a random order.

		@param inArray: Array to create copy of, and randomize.
		@return A new Array comprised of passed Array's items in a random order.
		@usage
			<code>
				var numberArray:Array = new Array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
				trace(ArrayUtil.randomize(this.numberArray));
			</code>
	*/
	public static function randomize(inArray:Array):Array {
		var t:Array  = new Array();
		var r:Array  = inArray.sort(ArrayUtil.$sortRandom, Array.RETURNINDEXEDARRAY);
		var i:Number = -1;
		
		while (++i < inArray.length)
			t.push(inArray[r[i]]);
		
		return t;
	}
	
	private static function $sortRandom(a:Object, b:Object):Number {
		return NumberUtil.randomInteger(0, 1) ? 1 : -1;
	}
	
	
	/**
		Adds all items in <code>inArray</code> and returns the value.

		@param inArray: Array comprised only of numbers.
		@return The total of all numbers in <code>inArray</code> added.
		@usage
			<code>
				var numberArray:Array = new Array(2, 3);
				trace("Total is: " + ArrayUtil.sum(this.numberArray));
			</code>
	*/
	public static function sum(inArray: /*Number*/ Array):Number {
		var t:Number = 0;
		var l:Number = inArray.length;
		
		while (l--)
			t += inArray[l];
		
		return t;
	}
	
	/**
		Averages the values in <code>inArray</code>.

		@param inArray: Array comprised only of numbers.
		@return The average of all numbers in the <code>inArray</code>.
		@usage
			<code>
				var numberArray:Array = new Array(2, 3, 8, 3);
				trace("Average is: " + ArrayUtil.average(this.numberArray));
			</code>
	*/
	public static function average(inArray: /*Number*/ Array):Number {
		if (inArray.length == 0)
			return 0;
		
		return ArrayUtil.sum(inArray) / inArray.length;
	}
	
	/**
		Finds the lowest value in <code>inArray</code>.

		@param inArray: Array comprised only of numbers.
		@return The lowest value in <code>inArray</code>.
		@usage
			<code>
				var numberArray:Array = new Array(2, 1, 5, 4, 3);
				trace("The lowest value is: " + ArrayUtil.getLowestValue(this.numberArray));
			</code>
	*/
	public static function getLowestValue(inArray: /*Number*/ Array):Number {
		return inArray[inArray.sort(16|8)[0]];
	}
	
	/**
		Finds the highest value in <code>inArray</code>.

		@param inArray: Array comprised only of numbers.
		@return The highest value in <code>inArray</code>.
		@usage
			<code>
				var numberArray:Array = new Array(2, 1, 5, 4, 3);
				trace("The highest value is: " + ArrayUtil.getHighestValue(this.numberArray));
			</code>
	*/
	public static function getHighestValue(inArray: /*Number*/ Array):Number {
		return inArray[inArray.sort(16|8)[inArray.length - 1]];
	}
	
	private function ArrayUtil() {} // Prevents instance creation
}