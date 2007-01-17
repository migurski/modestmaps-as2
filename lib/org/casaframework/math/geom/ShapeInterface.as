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

import org.casaframework.math.geom.PointInterface;
import org.casaframework.math.geom.Point;

/**
	@author Aaron Clinger
	@version 10/05/06
*/

interface org.casaframework.math.geom.ShapeInterface extends PointInterface {
	
	/**
		@return The width of the shape at its widest point.
	*/
	public function getWidth():Number;
	
	/**
		Sets the width of the shape at its widest point.
		
		@param width: Width of the shape.
	*/
	public function setWidth(width:Number):Void;
	
	/**
		@return The height of the shape at its tallest point.
	*/
	public function getHeight():Number;
	
	/**
		Sets the height of the shape at its tallest point.
		
		@param height: Height of the shape.
	*/
	public function setHeight(height:Number):Void;
	
	/**
		@return A defined {@link Point} object with the value of the top left X and Y position of the shape.
	*/
	public function getPosition():Point;
	
	/**
		Sets the value of the top left X and Y position of the shape.
		
		@param pointObject: A defined {@link Point} object.
	*/
	public function setPosition(pointObject:Point):Void;
	
	/**
		@return The distance around the shape.
	*/
	public function getPerimeter():Number;

	/**
		@return The size of the shape.
	*/
	public function getArea():Number;
	
	/**
		Finds if point is contained inside the shape's perimeter.
		
		@param pointObject: A defined {@link Point} object.
		@return Returns <code>true</code> if area contains point; otherwise <code>false</code>.
	*/
	public function containsPoint(pointObject:Point):Boolean;
}