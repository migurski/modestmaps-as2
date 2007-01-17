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
import org.casaframework.math.Percent;

/**
	Creates a standardized way of describing and storing an amount or extent of variation/a value range.
	
	@author Aaron Clinger
	@version 11/30/06
	@example
		<code>
			var valueRange:Range = new Range(-100, 100);
			trace(valueRange.getValueOfPercent(new Percent(.25)));
		</code>
*/

class org.casaframework.math.Range extends CoreObject {
	private var $startValue:Number;
	private var $endValue:Number;
	
	/**
		Creates and defines a Range object.
		
		@param startValue: <strong>[optional]</strong> Beginning value of the range.
		@param endValue: <strong>[optional]</strong> Ending value of the range.
		@usageNote You are not required to define the range in the contructor you can do it at any point by calling {@link #setRange}.
	*/
	public function Range(startValue:Number, endValue:Number) {
		super();
		
		this.setRange(startValue, endValue);
		
		this.$setClassDescription('org.casaframework.math.Range');
	}
	
	/**
		Defines or redefines range.
		
		@param startValue: Beginning value of the range.
		@param endValue: Ending value of the range.
	*/
	public function setRange(startValue:Number, endValue:Number):Void {
		this.$startValue = startValue;
		this.$endValue   = endValue;
	}
	
	/**
		@return Returns the value of <code>"startValue"</code> as defined by {@link #Range} or {@link #setRange}.
	*/
	public function getStartValue():Number {
		return this.$startValue;
	}
	
	/**
		@return Returns the value of <code>"endValue"</code> as defined by {@link #Range} or {@link #setRange}.
	*/
	public function getEndValue():Number {
		return this.$endValue;
	}
	
	/**
		@return Returns the minimum value of the range.
	*/
	public function getMinValue():Number {
		return (this.$startValue <= this.$endValue) ? this.$startValue : this.$endValue;
	}
	
	/**
		@return Returns the maximum value of the range.
	*/
	public function getMaxValue():Number {
		return (this.$startValue >= this.$endValue) ? this.$startValue : this.$endValue;
	}
	
	/**
		Determines if value is included in the range including the range's start and end values.
		
		@return Returns <code>true</code> if value was included in range; otherwise <code>false</code>.
	*/
	public function isWithinRange(value:Number):Boolean {
		return (value > this.getMaxValue() || value < this.getMinValue()) ? false : true;
	}
	
	/**
		Calculates the percent of the range.
		
		@param percent: A defined Percent object.
		@return The value the percent represent of the range.
	*/
	public function getValueOfPercent(percent:Percent):Number {
		var min:Number;
		var max:Number;
		var val:Number;
		var per:Percent = percent.clone();
		
		if (this.$startValue <= this.$endValue) {
			min = this.$startValue;
			max = this.$endValue;
		} else {
			per.setDecimalPercentage(1 - per.getDecimalPercentage());
			
			min = this.$endValue;
			max = this.$startValue;
		}
		
		val = Math.abs(max - min) * per.getDecimalPercentage() + min;
		
		per.destroy();
		
		return val;
	}
	
	/**
		Returns the percentage the value represents out of the range.
		
		@param value: An integer.
		@return A Percent object.
	*/
	public function getPercentOfValue(value:Number):Percent {
		var min:Number;
		var max:Number;
		var per:Percent;
		
		if (this.$startValue <= this.$endValue) {
			min = this.$startValue;
			max = this.$endValue;
			
			per = new Percent((value - min) / (max - min));
		} else {
			min = this.$endValue;
			max = this.$startValue;
			
			per = new Percent(1 - (value - min) / (max - min));
		}
		
		return per;
	}
	
	/**
		Determines whether the range specified in the <code>range</code> parameter is equal to this range object.

		@param percent: A defined {@link Range} object.
		@return Returns <code>true</code> if ranges are identical; otherwise <code>false</code>.
	*/
	public function equals(range:Range):Boolean {
		return this.getStartValue() == range.getStartValue() && this.getEndValue() == range.getEndValue();
	}
	
	/**
		@return A new range object with the same values as this range.
	*/
	public function clone():Range {
		return new Range(this.getStartValue(), this.getEndValue());
	}
	
	public function destroy():Void {
		delete this.$startValue;
		delete this.$endValue;
		
		super.destroy();
	}
}