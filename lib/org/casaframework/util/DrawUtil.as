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

/**
	@author Aaron Clinger
	@version 09/26/06
*/

class org.casaframework.util.DrawUtil {
		
	public static function drawWedge(target:MovieClip, startAngle:Number, arc:Number, radius:Number, yRadius:Number):Void {
		if (Math.abs(arc) >= 360) {
			DrawUtil.drawOval(target, radius, yRadius);
			return;
		}
		
		var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number, x:Number, y:Number;
		
		if (yRadius == undefined) yRadius = radius;
		segs = Math.ceil(Math.abs(arc) / 45);
		segAngle = arc / segs;
		theta = -(segAngle / 180) * Math.PI;
		angle = -(startAngle / 180) * Math.PI;
		x = radius;
		y = yRadius;
		
		target.moveTo(x, y);
		
		if (segs > 0) {
			ax = x+Math.cos(startAngle/180*Math.PI)*radius;
			ay = y+Math.sin(-startAngle/180*Math.PI)*yRadius;
			target.lineTo(ax, ay);
			
			var i:Number = -1;
			while (++i < segs) {
				angle += theta;
				angleMid = angle - (theta / 2);
				bx = x + Math.cos(angle) * radius;
				by = y + Math.sin(angle) * yRadius;
				cx = x + Math.cos(angleMid) * (radius / Math.cos(theta / 2));
				cy = y + Math.sin(angleMid) * (yRadius / Math.cos(theta / 2));
				target.curveTo(cx, cy, bx, by);
			}
		}
		
		target.lineTo(x, y);
		target.endFill();
	}
	
	public static function drawOval(target:MovieClip, radius:Number, yRadius:Number):Void {
		var theta:Number, xrCtrl:Number, yrCtrl:Number, angle:Number, angleMid:Number, px:Number, py:Number, cx:Number, cy:Number, x:Number, y:Number;
		
		if (yRadius == undefined) yRadius = radius;
		theta = Math.PI / 4;
		xrCtrl = radius / Math.cos(theta / 2);
		yrCtrl = yRadius / Math.cos(theta / 2);
		angle = 0;
		x = radius;
		y = yRadius;
		
		target.moveTo(x + radius, y);
		
		var i:Number = -1;
		while (++i < 8) {
			angle += theta;
			angleMid = angle - (theta / 2);
			cx = x + Math.cos(angleMid) *  xrCtrl;
			cy = y + Math.sin(angleMid) * yrCtrl;
			px = x + Math.cos(angle) * radius;
			py = y + Math.sin(angle) * yRadius;
			target.curveTo(cx, cy, px, py);
		}
		
		target.endFill();
	}
	
	public static function drawFrame(target:MovieClip, frameWidth:Number, width:Number, height:Number):Void {
		with (target) {
			moveTo(0, 0);
			lineTo(width, 0);
			lineTo(width, height);
			lineTo(0, height);
			lineTo(0, frameWidth);
			
			lineTo(frameWidth, frameWidth);
			lineTo(frameWidth, height - frameWidth);
			lineTo(width - frameWidth, height - frameWidth);
			lineTo(width - frameWidth, frameWidth);
			lineTo(0, frameWidth);
			lineTo(0, 0);
			
			endFill();
		}
	}
	
	public static function drawRectangle(target:MovieClip, width:Number, height:Number):Void {
		with (target) {
			moveTo(0, 0);
			lineTo(width, 0);
			lineTo(width, height);
			lineTo(0, height);
			lineTo(0, 0);
			
			endFill();
		}
	}
	
	public static function drawRoundedRectangle(target:MovieClip, width:Number, height:Number, cornerRadius:Number):Void {
		if (cornerRadius <= 0) {
			drawRectangle(target, width, height);
			return;
		}
		
		var w:Number = width  - cornerRadius;
		var h:Number = height - cornerRadius;
		
		with (target) {
			moveTo(cornerRadius, 0);
			lineTo(w, 0);
			curveTo(width, 0, width, cornerRadius);
			lineTo(width, h);
			curveTo(width, height, w, height);
			lineTo(cornerRadius, height);
			curveTo(0, height, 0, h);
			lineTo(0, cornerRadius);
			curveTo(0, 0, cornerRadius, 0);
			
			endFill();
		}
	}
	
	private function DrawUtil() {} // Prevents instance creation
}