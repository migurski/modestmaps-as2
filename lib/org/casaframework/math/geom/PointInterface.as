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
	@author Aaron Clinger
	@version 09/29/06
*/

interface org.casaframework.math.geom.PointInterface extends CoreInterface {

	/**
		@return The left X position.
	*/
	public function getX():Number;
	
	/**
		Sets the X coordinate.
		
		@param x: The horizontal coordinate of the point.
	*/
	public function setX(x:Number):Void;
	
	/**
		@return The top Y position.
	*/
	public function getY():Number;
	
	/**
		Sets the Y coordinate.
		
		@param y: The vertical coordinate of the point.
	*/
	public function setY(y:Number):Void;
}