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
	@author Toby Boudreaux
	@author Aaron Clinger
	@version 12/14/06
*/

interface org.casaframework.state.StateableInterface extends CoreInterface {
	
	/**
		Stores a key value pair.
		
		@param key: Name of key.
		@param value: Value of key.
	*/
	public function setValueForKey(key:String, value:Object):Void;
	
	/**
		Gets the value of specified key.
		
		@param key: Name of key.
		@return Value of key.
	*/
	public function getValueForKey(key:String):Object;
	
	/**
		Removes a key value pair from being stored.
		
		@param key: Name of key.
		@return Returns <code>true</code> if key value pair was found and removed; otherwise <code>false</code>.
	*/
	public function removeValueForKey(key:String):Boolean;
	
	/**
		@return Returns an Array composed of all stored key names as strings.
	*/
	public function getValueKeys():Array;
}