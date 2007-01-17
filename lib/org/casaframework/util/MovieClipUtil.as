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
	@version 10/29/06
*/

class org.casaframework.util.MovieClipUtil {
	
	/**
		Allows a multiple classes to use a single MovieClip in the library. It also makes it easier to change or assign class' to MovieClip without having to change the settings in the IDE environment.
		
		@param attachLocation: Scope/location to where the MovieClip should be placed.
		@param id: The linkage name of the MovieClip in the library.
		@param movieClipName: A unique instance name for the MovieClip.
		@param depth: The depth level where the MovieClip is placed.
		@param classPath: Path to the class you want to link to the MovieClip instance.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly attached MovieClip.
		@return A reference to the newly created MovieClip instance.
		@example
			<code>
				var myMc:MovieClip = MovieClipUtil.attachMovieRegisterClass(this, "libraryIdentifier", "myMovieClip_mc", this.getNextHighestDepth(), com.package.ClassName, {_x:15, _alpha:70});
			</code>
	*/
	public static function attachMovieRegisterClass(attachLocation:Object, id:String, movieClipName:String, depth:Number, classPath:Function, initObject:Object):MovieClip {
		Object.registerClass(id, classPath);
		var mc:MovieClip = attachLocation.attachMovie(id, movieClipName, depth, initObject);
		Object.registerClass(id, null);
		
		return mc;
	}
	
	/**
		Creates the ability to pass an object that contains properties with which to properties the newly created MovieClip. Mimics the ability of <code>attachMovie</code>.
		
		@param attachLocation: Scope/location to where the MovieClip should be placed.
		@param movieClipName: A unique instance name for the MovieClip.
		@param depth: The depth level where the MovieClip is placed.
		@param initObject: <strong>[optional]</strong> An object that contains properties with which to populate the newly created MovieClip.
		@return A reference to the newly created MovieClip instance.
		@example
			<code>
				var myMc:MovieClip = MovieClipUtil.createEmptyMovieClip(this, "myMovieClip_mc", this.getNextHighestDepth(), {_x:15, _alpha:70});
			</code>
	*/
	public static function createEmptyMovieClip(attachLocation:Object, movieClipName:String, depth:Number, initObject:Object):MovieClip {
		var mc:MovieClip = attachLocation.createEmptyMovieClip(movieClipName, depth);
		
		for (var prop:String in initObject)
			mc[prop] = initObject[prop];
		
		return mc;
	}
	
	private function MovieClipUtil() {} // Prevents instance creation
}