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
import org.casaframework.math.geom.PointInterface;

/**
	Stores location of a point in a two-dimensional coordinate system, where x represents the horizontal axis and y represents the vertical axis.
	
	@author Aaron Clinger
	@version 11/10/06
*/

class org.casaframework.math.geom.Point extends CoreObject implements PointInterface {
	private var $x:Number;
	private var $y:Number;
	
	/**
		Creates point object.
		
		@param x: The horizontal coordinate of the point.
		@param y: The vertical coordinate of the point.
	*/
	public function Point(x:Number, y:Number) {
		super();
		
		this.setX((x == undefined) ? 0 : x);
		this.setY((y == undefined) ? 0 : y);
		
		this.$setClassDescription('org.casaframework.math.geom.Point');
	}
	
	public function getX():Number {
		return this.$x;
	}
	
	public function setX(x:Number):Void {
		this.$x = x;
	}
	
	public function getY():Number {
		return this.$y;
	}
	
	public function setY(y:Number):Void {
		this.$y = y;
	}
	
	/**
		Offsets the Point object by the specified amount.
		
		@parem x: The amount by which to offset the horizontal coordinate.
		@param y: The amount by which to offset the vertical coordinate.
	*/
	public function offset(x:Number, y:Number):Void {
		this.$x += x;
		this.$y += y;
	}
	
	/**
		Determines whether the point specified in the <code>pointObject</code> parameter is equal to this point object.

		@param pointObject: A defined {@link Point} object.
		@return Returns <code>true</code> if shape's location is identical; otherwise <code>false</code>.
	*/
	public function equals(pointObject:Point):Boolean {
		return this.getX() == pointObject.getX() && this.getY() == pointObject.getY();
	}
	
	/**
		@return A new point object with the same values as this point.
	*/
	public function clone():Point {
		return new Point(this.getX(), this.getY());
	}
	
	/**
		Determines the distance between the first and second points.
		
		@param firstPoint: The first point.
		@parem secondPoint: The second point.
	*/
	public static function distance(firstPoint:Point, secondPoint:Point):Number {
		var x:Number = secondPoint.getX() - firstPoint.getX();
		var y:Number = secondPoint.getY() - firstPoint.getY();
		
		return Math.sqrt(x * x + y * y);
	}
	
	/**
		Determines the angle/degree between the first and second point.
		
		@param firstPoint: The first point.
		@parem secondPoint: The second point.
	*/
	public static function angle(firstPoint:Point, secondPoint:Point):Number {
		return Math.atan((firstPoint.getY() - secondPoint.getY()) / (firstPoint.getX() - secondPoint.getX())) / (Math.PI / 180);
	}
	
	public function destroy():Void {
		delete this.$x;
		delete this.$y;
		
		super.destroy();
	}
}