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

import org.casaframework.load.base.RetryableLoadInterface;

/**
	Load interface to be used in load classes where methods <code>getBytesLoaded</code> and <code>getBytesTotal</code> are available.

	@author Aaron Clinger
	@version 12/21/06
*/

interface org.casaframework.load.base.BytesLoadInterface extends RetryableLoadInterface {
	
	/**
		Sets the amount of time a load will wait without receiving further progress before {@link RetryableLoadInterface#setLoadRetries retrying}.
		
		@param loadTimeout: Time in milliseconds.
	*/
	public function setLoadTimeout(loadTimeout:Number):Void;
	
	/**
		Returns the number of bytes that have loaded (streamed).
		
		@return An integer that indicates the number of bytes loaded.
	*/
	public function getBytesLoaded():Number;
	
	/**
		Returns the size, in bytes, of the file currently or completed loading.
		
		@return An integer that indicates the total size, in bytes, of the movie clip.
	*/
	public function getBytesTotal():Number;
}