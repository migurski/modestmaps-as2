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

import org.casaframework.util.TypeUtil;

/**
	@author Aaron Clinger
	@author David Nelson
	@version 08/22/06
*/

class org.casaframework.util.ObjectUtil {
	
	
	public function contains(obj:Object, member:Object):Boolean {
		for (var prop:String in obj) if (obj[prop] == member) return true;
		return false;
	}
	
	public static function clone(org:Object):Object {
		var cloneObj:Object = new Object();

		for (var prop:String in org) {
			switch (TypeUtil.getTypeOf(org[prop])) {
				case 'array' :
					var i:Number = -1;
					cloneObj[prop] = new Array();
					while (++i <  org[prop].length) cloneObj[prop].push(org[prop][i]);
					break;
				case 'object' :
					cloneObj[prop] = ObjectUtil.clone(org[prop]);
					break;
				default :
					cloneObj[prop] = org[prop];
					break;
			}
		}

		return cloneObj;
	}
		
	public static function isUndefined(obj:Object):Boolean {
		return obj === undefined;
	}
	
	public static function isNull(obj:Object):Boolean {
		return obj === null;
	}
	
	public static function isEmpty(obj:Object):Boolean {
		if (obj == undefined) return true;
		
		switch (TypeUtil.getTypeOf(obj)) {
			case 'string' :
			case 'array' :
				return (obj.length == 0) ? true : false;
				break;
			case 'object' :
				for (var prop:String in obj) return true;				
				break;
		}
		
		return false;
	}
	
	private function ObjectUtil() {} // Prevents instance creation
}