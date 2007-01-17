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

import org.casaframework.math.Percent;

/**
	@author Aaron Clinger
	@version 11/10/06
*/

class org.casaframework.util.ColorUtil {
	
	/**
		Converts a color in hexadecimal format into an RGB object.
		
		@param colorHex: The hexadecimal color.
		@return Returns an object with the properties r, g and b defined.
		@example
			<code>
				var myRGB:Object = ColorUtil.getRGBFromHex(0xFF00FF);
				trace("Red = " + myRGB.r);
				trace("Green = " + myRGB.g);
				trace("Blue = " + myRGB.b);
			</code>
	*/
	public static function getRGBFromHex(colorHex:Number):Object {
		var rgb:Object = new Object();
		
		rgb.r = (colorHex >> 16);
		rgb.g = (colorHex >> 8 ^ rgb.r << 8);
		rgb.b = (colorHex ^ (rgb.r << 16 | rgb.g << 8));
		
		return rgb;
	}
	
	/**
		Converts a RGB color into a hexadecimal color string.
		
		@param r: The number value of red.
		@param g: The number value of green.
		@param b: The number value of blue.
		@return Returns a hexadecimal color as a string.
		@example <code>trace(ColorUtil.getHexStringFromRGB(255, 0, 255));</code>
	*/
	public static function getHexStringFromRGB(r:Number, g:Number, b:Number):String {
		var red:String   = r.toString(16);
		var green:String = g.toString(16);
		var blue:String  = b.toString(16);
		
		red   = (red.length < 2) ? '0' + red : red;
		green = (green.length < 2) ? '0' + green : green;
		blue  = (blue.length < 2) ? '0' + blue : blue;
		
		return (red + green + blue).toUpperCase();
	}
	
	/**
		Converts a RGB color into a hexadecimal color number.
		
		@param r: The number value of red.
		@param g: The number value of green.
		@param b: The number value of blue.
		@return Returns a hexadecimal color as a number.
		@example <code>trace(ColorUtil.getHexFromRGB(255, 0, 255));</code>
	*/
	public static function getHexFromRGB(r:Number, g:Number, b:Number):Number {
		return Number('0x' + ColorUtil.getHexStringFromRGB(r, g, b));
	}
	
	/**
		Specifies the tint color and tint percentage of a MovieClip.
		
		@param target_mc: The MovieClip to tint.
		@param tintColor: The hexadecimal color to be set.
		@param percent: The tint percentage, from transparent to completely saturated.
		@usage <code>Color.setTint(myMovie_mc, 0xFF00FF, new Percent(.8));</code>
	*/
	public static function setTint(target_mc:MovieClip, tintColor:Number, percent:Percent):Void {
		var targetColor:Color    = new Color(target_mc);
		var currentColor:Number  = targetColor.getRGB();
		var invertPercent:Number = 100 - percent.getPercentage();
		
		if (currentColor != 0) {
			var r:Number = ((currentColor & 0xff) * invertPercent + (tintColor & 0xff) * percent.getPercentage()) / 100;
			var g:Number = ((currentColor & 0xff00) / 0x100 * invertPercent + (tintColor & 0xff00) / 0x100 * percent.getPercentage()) / 100;
			var b:Number = ((currentColor & 0xff0000) / 0x10000 * invertPercent + (tintColor & 0xff0000) / 0x10000 * percent.getPercentage()) / 100;
			
			targetColor.setRGB(r | g << 8 | b << 16);
			return;
		}
		
		var rgb:Object   = ColorUtil.getRGBFromHex(tintColor);
		var trans:Object = new Object();
		
		trans.ra = trans.ga = trans.ba = invertPercent;
		trans.rb = rgb.r * percent.getDecimalPercentage();
		trans.gb = rgb.g * percent.getDecimalPercentage();
		trans.bb = rgb.b * percent.getDecimalPercentage();
		
		targetColor.setTransform(trans);
	}
	
	private function ColorUtil() {} // Prevents instance creation
}