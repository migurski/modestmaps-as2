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

import TextField.StyleSheet;
import org.casaframework.load.base.RetryableLoad;

/**
	StyleSheet object to ease the chore of loading and assigning StyleSheets.
	
	Unfortunately due the sub-par support of StyleSheets, this class cannot follow {@link BytesLoadInterface}/{@link BytesLoad}. The StyleSheet class does not include <code>getBytesLoaded</code> or <code>getBytesTotal</code> for reasions that are totally unclear.
	
	@author Aaron Clinger
	@version 12/22/06
	@since Flash Player 7
	@example
		<code>
			this.createTextField("headline_txt", this.getNextHighestDepth(), 50, 50, 300, 100);
			this.headline_txt.border = this.headline_txt.background = this.headline_txt.html = true;
			
			function initTextField(sender:StyleSheetLoad):Void {
				sender.assignStyleSheet(this.headline_txt);
				this.headline_txt.htmlText = "<h1>Heading</h1>";
			}
			
			var loadStyle:StyleSheetLoad = new StyleSheetLoad("style.css");
			this.loadStyle.addEventObserver(this, StyleSheetLoad.EVENT_LOAD_COMPLETE, "initTextField");
			this.loadStyle.start();
		</code>
	@usageNote Class will stall and fail silently if a empty CSS file is loaded, do to an error in the StyleSheet object.
*/

class org.casaframework.load.data.stylesheet.StyleSheetLoad extends RetryableLoad {
	private var $target:StyleSheet;
	private var $isUnloading:Boolean;
	
	/**
		Defines file and location of load triggered by {@link #start}.
		
		@param styleSheetPath: The absolute or relative URL of the CSS file to be loaded.
	*/
	public function StyleSheetLoad(styleSheetPath:String) {
		super(null, styleSheetPath);
		
		this.$target = new StyleSheet();
		
		this.$remapOnLoadHandler();
		
		this.$setClassDescription('org.casaframework.load.data.stylesheet.StyleSheetLoad');
	}
	
	/**
		@return Returns the StyleSheet object StyleSheetLoad class is wrapping and loading.
	*/
	public function getStyleSheet():StyleSheet {
		return this.$target;
	}
	
	/**
		Assigns StyleSheet to passed TextField. Can only be called after StyleSheet has successfully loaded.
		
		@param target_txt: Target TextField.
		@usageNote StyleSheets in Flash are extremely buggy. It is best to call <code>assignStyleSheet</code> before assigning text to a TextField.
	*/
	public function assignStyleSheet(target_txt:TextField):Void {
		if (!this.hasLoaded())
			return;
		
		target_txt.styleSheet = this.getStyleSheet();
	}
	
	public function destroy():Void {
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
		this.$target.clear();
	}
	
	private function $onLoad(success:Boolean):Void {
		if (!this.$isUnloading) {
			super.$onLoad(success);
		} else
			delete this.$isUnloading;
	}
	
	private function $checkForLoadComplete():Void {}
}