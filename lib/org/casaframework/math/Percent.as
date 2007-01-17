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

/**
	Creates a standardized way of describing and storing percentages. You can store and receive percentages in two different formats; regular percentage or as an decimal percentage.
	
	If percent is 37.5% a regular percentage would be expressed as <code>37.5</code> while the decimal percentage will be expressed <code>.375</code>.
	
	@author Aaron Clinger
	@version 12/01/06
	@example
		<code>
			var boxWidthPer:Percent = new Percent();
			this.boxWidthPer.setPercentage(25);
			
			this.box_mc._width *= boxWidthPer.getDecimalPercentage();
		</code>
*/

class org.casaframework.math.Percent extends CoreObject {
	private var $percent:Number;
	
	/**
		Creates a new percentage class with the option of defining the percent on creation.
		
		@param percentage: <strong>[optional]</strong> Percent formated at a percentage or an decimal percentage.
		@param isDecimalPercentage: <strong>[optional]</strong> Indicates if the parameter <code>percentage</code> is a decimal percentage <code>true</code>, or regular percentage <code>false</code>; defaults to <code>true</code>.
	*/
	public function Percent(percentage:Number, isDecimalPercentage:Boolean) {
		super();
		
		if (isDecimalPercentage == true || isDecimalPercentage == undefined)
			this.setDecimalPercentage(percentage);
		else
			this.setPercentage(percentage);
		
		this.$setClassDescription('org.casaframework.math.Percent');
	}
	
	/**
		Sets the percentage.
		
		@param percent: Percent expressed as a regular percentage. 37.5% would be expressed as <code>37.5</code>.
	*/
	public function setPercentage(percent:Number):Void {
		this.$percent = percent * .01;
	}
	
	/**
		Gets the percentage.
		
		@return Returns percent expressed as a regular percentage. 37.5% would be returned as <code>37.5</code>.
	*/
	public function getPercentage():Number {
		return 100 * this.$percent;
	}
	
	/**
		Sets the percentage.
		
		@param percent: Percent expressed as a decimal percentage. 37.5% would be expressed as <code>.375</code>.
	*/
	public function setDecimalPercentage(percent:Number):Void {
		this.$percent = percent;
	}
	
	/**
		Gets the percentage.
		
		@return Returns percent expressed as a decimal percentage. 37.5% would be returned as <code>.375</code>.
	*/
	public function getDecimalPercentage():Number {
		return this.$percent;
	}
	
	/**
		Determines whether the percent specified in the <code>percent</code> parameter is equal to this percent object.

		@param percent: A defined {@link Percent} object.
		@return Returns <code>true</code> if percents are identical; otherwise <code>false</code>.
	*/
	public function equals(percent:Percent):Boolean {
		return this.getDecimalPercentage() == percent.getDecimalPercentage();
	}
	
	/**
		@return A new percent object with the same value as this percent.
	*/
	public function clone():Percent {
		return new Percent(this.getDecimalPercentage());
	}
	
	public function destroy():Void {
		delete this.$percent;
		super.destroy();
	}
}