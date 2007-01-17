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
	Interface for creating lockable items.

	@author Aaron Clinger
	@author Toby Boudreaux
	@version 12/14/06
*/

interface org.casaframework.state.LockableInterface extends CoreInterface {
	
	/**
		Stores and removes EventHandlers to prevent them from triggering.
		
		@param inclusionList: <strong>[optional]</strong> List of EventHandlers and properties to lock. Defaults to all MovieClip EventHandlers.
	*/
	public function lock(inclusionList:Array):Void;
	
	/**
		Restores "locked" EventHandlers.
	*/
	public function unlock():Void;
	
	/**
		Switches the current state to the opposite state; between {@link #lock} and {@link #unlock}.
	*/
	public function toggle():Void;
	
	/**
		@return Returns <code>true</code> if currently locked; otherwise <code>false</code>.
	*/
	public function isLocked():Boolean;
}