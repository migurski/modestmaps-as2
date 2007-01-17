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

import org.casaframework.transitions.Tween;
import org.casaframework.util.TypeUtil;
import org.casaframework.util.PropertySetter;

/**
	A simple property tween class that extends {@link Tween}.
	
	@author Aaron Clinger
	@version 11/18/06
	@example
		<code>
			var boxMove:PropertyTween = new PropertyTween(this.box_mc, "_x", com.robertpenner.easing.Bounce.easeOut, 250, 2);
			boxMove.start();
		</code>
	@usageNote If you want to tween a value other than a property use {@link Tween}.
	@see Robert Penner's <a href="http://www.robertpenner.com/easing/">easing equations</a>.
*/

class org.casaframework.transitions.PropertyTween extends Tween {
	private var $scope:Object;
	private var $property:String;
	private var $propSetter:PropertySetter;
	
	
	/**
		Creates and defines property tween.
		
		@param scope: An object that contains the property specified by "property".
		@param property: Name of the property you want to tween.
		@param equation: Tween equation.
		@param endPos: The ending value of the tween.
		@param duration: Length of time of the tween.
		@param useFrames: <strong>[optional]</strong> Indicates to use frames <code>true</code>, or seconds <code>false</code> in relation to the value specified in the <code>duration</code> parameter; defaults to <code>false</code>.
		@usageNote Class uses the property's current value when {@link #start} is called as the starting position.
	*/
	public function PropertyTween(scope:Object, property:String, equation:Function, endPos:Number, duration:Number, useFrames:Boolean) {
		super(equation, 0, endPos, duration, useFrames);
		
		this.$setClassDescription('org.casaframework.transitions.PropertyTween');
		
		if (!TypeUtil.isTypeOf(scope[property], 'number')) {
			this.destroy();
			return;
		}
		
		this.$scope    = scope;
		this.$property = property;
		
		this.$propSetter = new PropertySetter(this.$scope, this.$property);
		this.addEventObserver(this.$propSetter, Tween.EVENT_POSITION, 'defineProperty');
	}
	
	public function start():Void {
		if (this.$destroyed)
			return;
		
		if (this.$initPropertyTween())
			super.start();
	}
	
	/**
		Resumes tween from {@link Tween#stop stopped} position.
	*/
	public function resume():Void {
		if (!this.$stopped || this.$completed || this.$destroyed)
			return;
		
		if (this.$initPropertyTween())
			super.resume();
	}
	
	private function $initPropertyTween():Boolean {
		if (!TypeUtil.isTypeOf(this.$scope[this.$property], 'number')) {
			this.destroy();
			return false;
		}
		
		this.$begin = this.$currentPosition = this.$scope[this.$property];
		this.$diff  = this.$end - this.$begin;
		
		return true;
	}
	
	public function destroy():Void {
		this.$propSetter.destroy();
		
		delete this.$scope;
		delete this.$property;
		delete this.$propSetter;
		
		super.destroy();
	}
}