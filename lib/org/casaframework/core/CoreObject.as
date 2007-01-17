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

import org.casaframework.core.CoreInterface;

/**
	A core level object to inherent from which extends Flash's built-in object class. All object classes not extending from core flash classes/types should extend from here
	
	@author Toby Boudreaux
	@author David Nelson
	@author Aaron Clinger
	@version 10/11/06
	@usageNote All user defined objects should inherent from CoreObject to return a detailed class description rather than the default <code>[object Object]</code>. In subclasses call method <code>$setClassDescription(description:String)</code> to set class description.
	@example
		<code>
			class com.example.Example extends CoreObject {
				public function Example() {
					super();
					
					this.$setClassDescription("com.example.Example");
				}
			}
		</code>
*/

class org.casaframework.core.CoreObject implements CoreInterface {
	private var $instanceDescription:String;
	
	public function CoreObject() {
		this.$setClassDescription('org.casaframework.core.CoreObject');
	}
	
	public function toString():String {
		return '[' + this.$instanceDescription + ']';
	}
	
	public function destroy():Void {
		delete this.$instanceDescription;
	}
	
	private function $setClassDescription(description:String):Void {
		this.$instanceDescription = description;
	}
}