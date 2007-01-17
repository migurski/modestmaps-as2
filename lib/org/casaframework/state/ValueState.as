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
import org.casaframework.state.StateableInterface;

/**
	Class designed to store key value pairs.
	
	@author Toby Boudreaux
	@author Aaron Clinger
	@version 12/14/06
*/

class org.casaframework.state.ValueState extends CoreObject implements StateableInterface {
	private var $values:Object;
	
	public function ValueState() {
		super();
		this.$values = new Object();
		this.$setClassDescription('org.casaframework.state.ValueState');
	}
	
	public function setValueForKey(key:String, value:Object):Void {
		if (key == undefined)
			return;
		
		this.$values[key] = value;
	}
	
	public function getValueForKey(key:String):Object {
		return this.$values[key];
	}
	
	public function removeValueForKey(key:String):Boolean {
		if (this.$values[key] != undefined) {
			delete this.$values[key];
			return true;
		}
		
		return false;
	}
	
	public function getValueKeys(): /*String*/ Array {
		var r: /*String*/ Array = new Array();
		
		for (var i:String in this.$values)
			r.push(i);
		
		return r;
	}
	
	public function destroy():Void {
		delete this.$values;
		super.destroy();
	}
}