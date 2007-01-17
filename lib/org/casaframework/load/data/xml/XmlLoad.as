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

import org.casaframework.xml.CoreXml;
import org.casaframework.load.base.BytesLoad;

/**
	Eases the chore of loading XML. This class is designed to be extended is and is not as useful unpaired.
	
	@author Aaron Clinger
	@version 12/20/06
	@see {@link CoreXml}
*/

class org.casaframework.load.data.xml.XmlLoad extends BytesLoad {
	public static var EVENT_PARSING:String     = 'onParsing';
	public static var EVENT_PARSE_ERROR:String = 'onParseError';
	public static var EVENT_PARSED:String      = 'onParsed';
	private var $target:CoreXml;
	private var $isUnloading:Boolean;
	
	
	public function XmlLoad(xmlPath:String) {
		super(null, xmlPath);
		
		this.$target = new CoreXml();
		
		this.$remapOnLoadHandler();
		
		this.$setClassDescription('org.casaframework.load.data.xml.XmlLoad');
	}
	
	public function hasLoaded():Boolean {
		return (this.$target.loaded == undefined) ? false : this.$target.loaded;
	}
	
	/**
		@return Returns the CoreXml object XmlLoad class is wrapping and loading.
	*/
	public function getXml():CoreXml {
		return this.$target;
	}
	
	/**
		<strong>This function needs to be overwritten by a subclass.</strong>
		
		@usageNote After the subclass file is done parsing call <code>private function $parsed()</code> in order to broadcast the 'onParsed' event to listeners.
	*/
	public function parse():Void {}
	
	public function destroy():Void {
		this.$target.destroy();
		delete this.$isUnloading;
		
		super.destroy();
	}
	
	private function $startLoad():Void {
		super.$startLoad();
		
		delete this.$isUnloading;
		this.$target.load(this.getFilePath());
	}
	
	private function $stopLoad():Void {
		super.$stopLoad();
		
		this.$isUnloading = true;
		this.$target.load(''); // Cancels the current load.
	}
	
	private function $onLoad(success:Boolean):Void {
		if (!this.$isUnloading) {
			super.$onLoad(success);
		} else
			delete this.$isUnloading;
	}
	
	private function $checkForLoadComplete():Void {}
	
	/**
		@sends onParsing = function(sender_xml:XmlLoad) {}
		@sends onParseError = function(sender_xml:XmlLoad, errorStatus:Number) {}
	*/
	private function $onComplete():Void {
		super.$onComplete();
		
		if (this.$target.status == 0) {
			this.dispatchEvent(XmlLoad.EVENT_PARSING, this);
			this.parse();
		} else
			this.dispatchEvent(XmlLoad.EVENT_PARSE_ERROR, this, this.$target.status);
	}
	
	/**
		@sends onParsed = function(sender_xml:XmlLoad) {}
	*/
	private function $parsed():Void {
		this.dispatchEvent(XmlLoad.EVENT_PARSED, this);
	}
}