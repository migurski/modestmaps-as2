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
	Creates a setter function for properties. Designed to be used with objects where methods require a function but you want to ultimately set a value of a property.
	
	@author Aaron Clinger
	@version 11/11/06
	@example
		<code>
			var buttonLock:PropertySetter = new PropertySetter(this.button_mc, "enabled");
			
			var timeOut:Interval = Interval.setTimeout(this.buttonLock, "defineProperty", 5000, false);
			this.timeOut.start();
		</code>
		or
		<code>
			var clipMove:PropertySetter = new PropertySetter(this.box_mc, "_x");
			
			var slideMotion:Tween = new Tween(com.robertpenner.easing.Bounce.easeOut, 0, 250, 1.5);
			this.slideMotion.addEventObserver(this.clipMove, Tween.EVENT_POSITION, "defineProperty");
			this.slideMotion.start();
		</code>
	@see {@link Interval} & {@link Tween}.
*/

class org.casaframework.util.PropertySetter extends CoreObject {
	private var $scope:Object;
	private var $property:String;
	private var $argument:Number;
	
	/**
		Defines the property you wish to define with {@link #defineProperty}.
		
		@param scope: An object that contains the property specified by "property".
		@param property: Name of the property you want to assign the value of.
		@param argument: <strong>[optional]</strong> The position the value to assign falls in the argument order; defaults to <code>0</code>.
	*/
	public function PropertySetter(scope:Object, property:String, argument:Number) {
		if (scope[property] == undefined) return;
		
		this.$scope    = scope;
		this.$property = property;
		this.$argument = (argument == undefined) ? 0 : argument;
		
		this.$setClassDescription('org.casaframework.util.PropertySetter');
	}
	
	/**
		Defines property with the value of the targeted argument.
	*/
	public function defineProperty():Void {
		this.$scope[this.$property] = arguments[this.$argument];
	}
	
	public function destroy():Void {
		delete this.$scope;
		delete this.$property;
		delete this.$argument;
		
		super.destroy();
	}
}