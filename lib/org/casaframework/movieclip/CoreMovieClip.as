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
	A core MovieClip to inherent from which extends Flash's built-in MovieClip class. All MovieClip classes should extend from here.
	
	@author Aaron Clinger
	@version 11/18/06
*/

class org.casaframework.movieclip.CoreMovieClip extends MovieClip implements CoreInterface {
	private var $instanceDescription:String;
	
	
	/**
		@exclude
	*/
	public function CoreMovieClip() {
		this.$setClassDescription('org.casaframework.movieclip.CoreMovieClip');
	}
	
	public function toString():String {
		return '[' + this.$instanceDescription + ']';
	}
	
	/**
		Removes a MovieClip created with <code>duplicateMovieClip()</code>, <code>createEmptyMovieClip()</code>, or <code>attachMovie()</code> after calling {@link #destroy}.
		
		@usageNote <code>removeMovieClip</code> automatically calls {@link destroy} before removing.
	*/
	public function removeMovieClip():Void {
		this.destroy();
		super.removeMovieClip();
	}
	
	public function destroy():Void {
		delete this.$instanceDescription;
	}
	
	private function $setClassDescription(description:String):Void {
		this.$instanceDescription = description;
	}
}