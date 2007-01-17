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

import org.casaframework.control.RunnableInterface;

/**
	@author Aaron Clinger
	@version 12/18/06
*/

interface org.casaframework.load.base.LoadInterface extends RunnableInterface {
	
	/**
		Retrieves the path to the file that is to be loaded.
		
		@return String containing the path to the file.
	*/
	public function getFilePath():String;
	
	/**
		Determines whether the requested file has finished loading.
		
		@return	 Returns <code>true</code> if file has completely loaded; otherwise <code>false</code>.
	*/
	public function hasLoaded():Boolean;
	
	/**
		Determines whether the requested file is in the process of loading.
		
		@return Returns <code>true</code> if the file is currently loading; otherwise <code>false</code>.
	*/
	public function isLoading():Boolean;
}