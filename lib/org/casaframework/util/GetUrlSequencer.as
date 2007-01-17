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

import org.casaframework.time.Interval;

/**
	GetUrlSequencer delays/spaces out <code>getURL</code> requests to prevent browsers from choking from too many requests sent quickly in succession.
	
	@author Aaron Clinger
	@version 09/14/06
	@example
		<code>
			GetUrlSequencer.getURL("javascript:alert('call one');");
			GetUrlSequencer.getURL("javascript:alert('call two');");
			GetUrlSequencer.getURL("javascript:alert('call three');");
		</code>
*/

class org.casaframework.util.GetUrlSequencer {
	private static var $getCue:Array;
	private static var $delay:Number = 250;
	private static var $hasInit:Boolean;
	private static var $interval:Interval;
	
	/**
		Loads a document from a specific URL into a window or passes variables to another application at a defined URL.
		
		@param url: The URL from which to obtain the document.
		@param window: <strong>[optional]</strong> Specifies the window or HTML frame into which the document should load.
		@param method: <strong>[optional]</strong> A <code>GET</code> or <code>POST</code> method for sending variables.
		@usageNote This acts identical to flash's native <code>getURL</code>.
	*/
	public static function getURL(url:String, window:String, method:String):Void {
		if (!GetUrlSequencer.$hasInit) GetUrlSequencer.$init();
		
		GetUrlSequencer.$getCue.push({u:url, w:window, m:method});
		
		if (!GetUrlSequencer.$interval.isFiring()) GetUrlSequencer.$interval.start();
	}
	
	/**
		Changes the delay/spacing between <code>getURL</code> calls.
		
		@param delay: The time in milliseconds between calls.
		@usageNote Class defaults to <code>250</code> milliseconds between <code>getURL</code> calls.
	*/
	public static function changeDelay(delay:Number):Void {
		if (GetUrlSequencer.$hasInit) GetUrlSequencer.$interval.changeDelay(delay);
		else GetUrlSequencer.$delay = delay;
	}
	
	private static function $init():Void {
		GetUrlSequencer.$getCue   = new Array();
		GetUrlSequencer.$interval = Interval.setInterval(GetUrlSequencer, "$sendRequest", GetUrlSequencer.$delay);
		GetUrlSequencer.$hasInit  = true;
	}
	
	private static function $sendRequest():Void {
		var request:Object = GetUrlSequencer.$getCue.shift();
		_root.getURL(request.u, request.w, request.m);
		
		if (GetUrlSequencer.$getCue.length == 0) GetUrlSequencer.$interval.stop();
	}
	
	
	private function GetUrlSequencer() {} // Prevents instance creation
}	