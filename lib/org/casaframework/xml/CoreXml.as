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
	Core XML class that includes {@link CoreInterface} and defaults <code>ignoreWhite</code> to <code>true</code>. All other XML classes should inherent from here.
	
	@author Aaron Clinger
	@version 12/20/06
*/

class org.casaframework.xml.CoreXml extends XML implements CoreInterface {
	private var $instanceDescription:String;
	
	
	/**
		@param text: The XML text parsed to create the new XML object.
	*/
	public function CoreXml(text:String) {
		super(text);
		
		this.ignoreWhite = true;
		
		this.$setClassDescription('org.casaframework.xml.CoreXml');
	}
	
	public function toString():String {
		return '[' + this.$instanceDescription + ']';
	}
	
	public function destroy():Void {
		delete this.$instanceDescription;
	}
	
	private function $setClassDescription(description:String):Void {
		this.$instanceDescription = description;
	}
}