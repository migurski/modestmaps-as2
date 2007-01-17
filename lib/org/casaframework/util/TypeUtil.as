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
	@version 09/18/06
*/

class org.casaframework.util.TypeUtil {
	
	public static function getTypeOf(obj:Object):String {
		var t:String = typeof obj;
		if (t != 'object') return t;
		if (obj instanceof Array) return 'array';
		if (obj instanceof Button) return 'button';
		if (obj instanceof TextField) return 'textfield';
		if (obj instanceof Video) return 'video';
		return 'object';
	}
	
	public static function isTypeOf(obj:Object, type:String):Boolean {
		return TypeUtil.getTypeOf(obj) == type.toLowerCase();
	}
	
	private function TypeUtil() {} // Prevents instance creation
}