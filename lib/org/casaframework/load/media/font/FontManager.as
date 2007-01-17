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

import org.casaframework.load.media.MediaLoad;

/**
	Manages dynamic font switching/loading.
	
	To get this working in please follow these steps:
	<ol>
		<li>Create a new FLA file and name it "testFont_lib.fla".</li>
		<li>On the root on testFont_lib.fla create a dynamic textfield.</li>
		<li>Choose a typeface and embed all characters you want to include.</li>
		<li>Enter some text into the textfield.</li>
		<li>Give the textfield an instance name of "font_txt".</li>
		<li>Convert the textfield to a symbol, give it a name of "testFont" and make sure its type is Movie clip.</li>
		<li>Make sure "Export for runtime sharing" is checked under Linkage, and give it an Indentifier of "testFont".</li>
		<li>In the URL field type "testFont_lib.swf". This path is relative to your HTML file, change if necessary.</li>
		<li>Click OK to apply these changes to the symbol.</li>
		<li>Publish this file and save it. You can now close this FLA.</li>
		<li>Create a new FLA and name it "testFont.fla".</li>
		<li>In testFont.fla create a new symbol, give it a name of "testFont" and make sure its type is Movie clip.</li>
		<li>Check "Import for runtime sharing" under Linkage, and give it an Indentifier of "testFont".</li>
		<li>In the URL field type "testFont.swf". This path is relative to your HTML file, change if necessary.</li>
		<li>Under Source click the browse button and find testFont_lib.fla and click open.</li>
		<li>Select source symbol testFont and click OK.</li>
		<li>Click OK to apply these changes to the symbol.</li>
		<li>Make sure the the symbol is on the main stage at the root level and give it an instance name of "fontContainer_mc".</li>
		<li>On a frame at the root place the following code (REQUIRED):
			<code>
				FontManager.registerFont("testFont", this.fontContainer_mc.font_txt, this, true);
			</code>
		</li>
		<li>Publish this file and save it. You can now close this FLA.</li>
		<li>Now follow and use the code in the example below to load and apply the font. Follow these steps for each font you would like to load.</li>
	</ol>
	
	@author Aaron Clinger
	@version 12/20/06
	@since Flash Player 7
	@example
		<code>
			this.createTextField("headline_txt", this.getNextHighestDepth(), 50, 50, 300, 100);
			this.headline_txt.border = this.headline_txt.background = this.headline_txt.wordWrap = this.headline_txt.multiline = true;
			this.headline_txt.type = "input";
			this.headline_txt.text = "This is an example of dynamic font loading with FontManager.";

			var fontLoad:FontManager = FontManager.loadFont("testFont.swf");
			this.fontLoad.addEventObserver(this, FontManager.EVENT_FONT_REGISTER);
			this.fontLoad.start();

			function onFontRegister(refrenceName:String, fontTextFormat:TextFormat):Void {
				FontManager.applyTextFormatByReferenceName(refrenceName, this.headline_txt);
				
				this.fontLoad.destroy();
				delete this.fontLoad;
			}
		</code>
*/

class org.casaframework.load.media.font.FontManager extends MediaLoad {
	public static var EVENT_FONT_REGISTER:String      = 'onFontRegister';
	public static var EVENT_LAST_FONT_REGISTER:String = 'onLastFontRegister';
	private static var $textFormats:Object;
	private static var $fontLoadMap:Object;
	private static var $incrementId:Number;
	private static var $fontManager_mc:MovieClip;
	
	private var $fontLoad_mc:MovieClip;
	private var $fontList:Object;
	
	/**
		Load a SWF wrapped font from a external location.
		
		@param filePath: The absolute or relative URL of the SWF.
		@return {@link FontManager} instance.
	*/
	public static function loadFont(filePath:String):FontManager {
		if (FontManager.$fontLoadMap == undefined)
			FontManager.$init();
		
		var fontLoad_mc:MovieClip  = FontManager.$fontManager_mc.createEmptyMovieClip('fontLoad' + FontManager.$incrementId + '_mc', FontManager.$fontManager_mc.getNextHighestDepth());
		FontManager.$incrementId++;
		
		var fmInstance:FontManager = new FontManager(fontLoad_mc, filePath);
		
		FontManager.$fontLoadMap[fontLoad_mc] = fmInstance;
		
		return fmInstance;
	}
	
	/**
		Looks up and returns a TextFormat by its reference name.
		
		@param refrenceName: Reference name of font.
		@return A new TextFormat with <code>font</code> defined.
	*/
	public static function getTextFormatByReferenceName(refrenceName:String):TextFormat {
		if (FontManager.$textFormats[refrenceName] != undefined)
			return FontManager.$textFormats[refrenceName];
	}
	
	/**
		Assigns a TextFormat to a TextField and determines if <code>embedFonts</code> should be <code>true</code> or <code>false</code>.
		
		@param refrenceName: Reference name of font.
		@param field_txt: TextField to apply the TextFormat.
		@return Returns <code>true</code> if TextFormat by <code>refrenceName</code> was successfully found; otherwise <code>false</code>.
		@usageNote Automatically sets <code>embedFonts</code> to <code>true</code> if <code>font</code> is NOT <code>_sans</code>, <code>_serif</code> or <code>_typewriter</code>; otherwise sets <code>embedFonts</code> to <code>false</code>.
	*/
	public static function applyTextFormatByReferenceName(refrenceName:String, field_txt:TextField):Boolean {
		var textFormat:TextFormat = FontManager.getTextFormatByReferenceName(refrenceName);
		
		if (textFormat == undefined)
			return false;
		
		switch (textFormat.font.toLowerCase()) {
			case '_sans' :
			case '_serif' :
			case '_typewriter' :
				field_txt.embedFonts = false;
				break;
			default :
				field_txt.embedFonts = true;
				break;
		}
		
		field_txt.setTextFormat(textFormat);
		
		return true;
	}
	
	/**
		Gets a list of all of the refrence names of registered fonts.
		
		@return Array of font reference names.
	*/
	public static function getFontReferenceNames(): /*String*/ Array {
		var referenceNames: /*String*/ Array = new Array();
		
		for (var i:String in FontManager.$textFormats)
			referenceNames.push(i);
		
		return referenceNames;
	}
	
	/**
		Used by external font SWF files to register fonts. Should not be called by anything else.
		
		@param refrenceName: The unique reference name of your font. Used to look up at a later time with {@link #getTextFormatByReferenceName}.
		@param field: TextField with the embedded font.
		@param sender_mc: Reference to the external SWFs root/shell; if this code is on the top timeline <code>sender_mc</code> should be <code>this</code>.
		@param isLastRegister: <strong>[optional]</strong> Indicates it's the last font registered <code>true</code>, or that there are other fonts left to register <code>false</code>; defaults to <code>false</code>.
		@return Returns <code>true</code> if parameter <code>sender_mc</code> was referenced correctly and the font was successfully registered; otherwise <code>false</code>.
		@usageNote Parameter <code>isLastRegister</code> should only be <code>true</code> during the registering of the last font in the loaded SWF. If there is only one font being registered it should always be <code>true</code>.
	*/
	public static function registerFont(referenceName:String, field:TextField, sender_mc:MovieClip, isLastRegister:Boolean):Boolean {
		var fontLoad:FontManager = FontManager.$fontLoadMap[sender_mc];
		
		if (fontLoad != undefined) {
			fontLoad.$registerTextFormat(referenceName, field, (isLastRegister == undefined) ? false : isLastRegister);
			
			if (isLastRegister) {
				fontLoad.destroy();
				delete FontManager.$fontLoadMap[sender_mc];
			}
			
			return true;
		}
		
		return false;
	}
	
	private static function $init():Void {
		FontManager.$fontLoadMap    = new Object();
		FontManager.$textFormats    = new Object();
		FontManager.$incrementId    = 0;
		FontManager.$fontManager_mc = _root.createEmptyMovieClip('fontManager_mc', _root.getNextHighestDepth());
		
		FontManager.$fontManager_mc._visible = false;
	}
	
	/**
		@sends onLoadStart = function (sender:Object) {}
		@sends onLoadStop = function (sender:Object) {}
		@sends onLoadError = function (sender:Object) {}
	*/
	private function FontManager(target_mc:MovieClip, filePath:String) {
		super(target_mc, filePath, true);
		
		this.$setClassDescription('org.casaframework.load.media.font.FontManager');
	}
	
	/**
		@sends onFontRegister = function(referenceName:String, fontTextFormat:TextFormat) {}
		@sends onLastFontRegister = function() {}
	*/
	private function $registerTextFormat(referenceName:String, field:TextField, isLastRegister:Boolean):Void {
		var register:TextFormat = field.getTextFormat();
		var textFormat:TextFormat = new TextFormat();
		
		textFormat.font   = register.font;
		textFormat.italic = register.italic;
		textFormat.bold   = register.bold;
		
		FontManager.$textFormats[referenceName] = textFormat;
		
		this.dispatchEvent(FontManager.EVENT_FONT_REGISTER, referenceName, textFormat);
		
		if (isLastRegister)
			this.dispatchEvent(FontManager.EVENT_LAST_FONT_REGISTER);
	}
	
	/**
		Removes all observers and deletes event functionality. This frees objects for garbage collection.
		
		<strong>Always call <code>destroy()</code> before deleting/removing event instance.</strong>
		
		@usageNote {@link #destroy} is called automatically after event <code>onLastFontRegister</code>.
	*/
	public function destroy():Void {
		var loadContainer_mc:MovieClip = this.getMovieClip();
		delete FontManager.$fontLoadMap[loadContainer_mc];
		
		loadContainer_mc.unloadMovie();
		loadContainer_mc.removeMovieClip();
		
		delete this.$fontLoad_mc;
		delete this.$fontList;
		
		super.destroy();
	}
}
