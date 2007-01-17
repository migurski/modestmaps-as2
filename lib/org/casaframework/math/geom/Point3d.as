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

import org.casaframework.math.geom.Point;

/**
	Stores location of a point in a three-dimensional coordinate system, where x represents the horizontal axis, y represents the vertical axis, z represents the axis that is vertically perpendicular to the xy axes or depth.
	
	@author Aaron Clinger
	@version 11/10/06
*/

class org.casaframework.math.geom.Point3d extends Point {
	private var $z:Number;
    
	/**
		Creates 3d point object.
		
		@param x: The horizontal coordinate of the point.
		@param y: The vertical coordinate of the point.
		@param z: The depth coordinate of the point.
	*/
	public function Point3d(x:Number, y:Number, z:Number) {
		super(x, y);
		
		this.setZ((z == undefined) ? 0 : z);
		
		this.$setClassDescription('org.casaframework.math.geom.Point3d');
	}
	
	/**
		@return The Z position.
	*/
	public function getZ():Number {
		return this.$z;
	}
	
	/**
		Sets the Z coordinate.
		
		@param z: The depth coordinate of the point.
	*/
	public function setZ(z:Number):Void {
		this.$z = z;
	}
	
	/**
		Offsets the Point object by the specified amount.
		
		@parem x: The amount by which to offset the horizontal coordinate.
		@param y: The amount by which to offset the vertical coordinate.
		@param z: The amount by which to offset the depth coordinate.
	*/
	public function offset(x:Number, y:Number, z:Number):Void {
		super.offset(x, y);
		this.$z += z;
	}
	
	/**
		Determines whether the point specified in the <code>pointObject</code> parameter is equal to this point object.

		@param pointObject: A defined {@link Point3d} object.
		@return Returns <code>true</code> if shape's location is identical; otherwise <code>false</code>.
	*/
	public function equals(pointObject:Point3d):Boolean {
		return this.getX() == pointObject.getX() && this.getY() == pointObject.getY() && this.getZ() == pointObject.getZ();
	}
	
	/**
		@return A new point object with the same values as this point.
	*/
	public function clone():Point3d {
		return new Point3d(this.getX(), this.getY(), this.getZ());
	}
	
	/**
		Determines the distance between the first and second points in 3D space.
		
		@param firstPoint: The first point.
		@parem secondPoint: The second point.
	*/
	public static function distance(firstPoint:Point3d, secondPoint:Point3d):Number {
		var x:Number = secondPoint.getX() - firstPoint.getX();
		var y:Number = secondPoint.getY() - firstPoint.getY();
		var z:Number = secondPoint.getZ() - firstPoint.getZ();
		
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	public function destroy():Void {
		delete this.$z;
		super.destroy();
	}
}