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
import org.casaframework.math.geom.ShapeInterface;
import org.casaframework.math.geom.Point;

/**
	Stores position and size of a rectangle (or square).

	@author Aaron Clinger
	@version 01/03/07
*/

class org.casaframework.math.geom.Rectangle extends CoreObject implements ShapeInterface {
	private var $x:Number;
	private var $y:Number;
	private var $w:Number;
	private var $h:Number;
	
	/**
		Creates new rectangle object.
		
		@param x: The horizontal position of the rectangle.
		@param y: The vertical position of the ellipse.
		@param width: Width of the rectangle.
		@param height: <strong>[optional]</strong> Height of the rectangle. If undefined assumes <code>height</code> matches <code>width</code> (Creates square).
	*/
	public function Rectangle(x:Number, y:Number, width:Number, height:Number) {
		super();
		
		this.setX((x == undefined) ? 0 : x);
		this.setY((y == undefined) ? 0 : y);
		this.setWidth((width == undefined) ? 0 : width);
		this.setHeight((height == undefined) ? this.getWidth() : height);
		
		this.$setClassDescription('org.casaframework.math.geom.Rectangle');
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
		@return The right X position of the rectangle.
	*/
	public function getX2():Number {
		return this.getX() + this.getWidth();
	}
	
	/**
		Sets the right position of the rectangle.
		
		@param x: The right X position of the rectangle.
	*/
	public function setX2(x:Number):Void {
		this.setWidth(x - this.getX());
	}
	
	/**
		@return The bottom Y position of the rectangle.
	*/
	public function getY2():Number {
		return this.getY() + this.getHeight();
	}
	
	/**
		Sets the bottom position of the rectangle.
		
		@param y: The bottom Y position of the rectangle.
	*/
	public function setY2(y:Number):Void {
		this.setHeight(y - this.getY());
	}
	
	public function getPosition():Point {
		return new Point(this.getX(), this.getY());
	}
	
	public function setPosition(pointObject:Point):Void {
		this.setX(pointObject.getX());
		this.setY(pointObject.getY());
	}
	
	public function getWidth():Number {
		return this.$w;
	}
	
	public function setWidth(width:Number):Void {
		this.$w = width;
	}
	
	public function getHeight():Number {
		return this.$h;
	}
	
	public function setHeight(height:Number):Void {
		this.$h = height;
	}
	
	public function getPerimeter():Number {
		return this.getWidth() * 2 + this.getHeight() * 2;
	}

	public function getArea():Number {
		return this.getWidth() * this.getHeight();
	}
	
	public function containsPoint(pointObject:Point):Boolean {
		return pointObject.getX() >= this.getX() && pointObject.getX() <= this.getX2() && pointObject.getY() >= this.getY() && pointObject.getY() <= this.getY2();
	}
	
	/**
		Determines whether the rectangle specified in the <code>rectangleObject</code> parameter is equal to this rectangle object.

		@param rectangleObject: A defined {@link Rectangle} object.
		@return Returns <code>true</code> if shape's location and size is identical; otherwise <code>false</code>.
	*/
	public function equals(rectangleObject:Rectangle):Boolean {
		return this.getX() == rectangleObject.getX() && this.getY() == rectangleObject.getY() && this.getWidth() == rectangleObject.getWidth() && this.getHeight() == rectangleObject.getHeight();
	}
	
	/**
		@return A new rectangle object with the same values as this rectangle.
	*/
	public function clone():Rectangle {
		return new Rectangle(this.getX(), this.getY(), this.getWidth(), this.getHeight());
	}
	
	public function destroy():Void {
		delete this.$x;
		delete this.$y;
		delete this.$w;
		delete this.$h;
		
		super.destroy();
	}
}