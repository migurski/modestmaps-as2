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
	@version 08/22/06
*/

class org.casaframework.util.TextFieldUtil {
	
	public static function hasOverFlow(target_txt:TextField):Boolean {
		return target_txt.maxscroll > 1;
	}
	
	public static function removeOverFlow(target_txt:TextField, omissionIndicator:String):Void {
		if (!TextFieldUtil.hasOverFlow(target_txt)) return;
		
		if (omissionIndicator == undefined) omissionIndicator = '';
		
		var lines:Array = target_txt.text.split('. ');
		var words:Array;
		var lastSentence:String;
		var sentences:String;
		
		while (TextFieldUtil.hasOverFlow(target_txt)) {
			var lastSentence = lines.pop();
			target_txt.text = lines.join('. ') + '.';
		}
		
		sentences = lines.join('. ') + '. ';
		words = lastSentence.split(' ');
		target_txt.text += lastSentence;
		
		while (TextFieldUtil.hasOverFlow(target_txt)) {
			words.pop();
			target_txt.text = sentences + words.join(' ') + omissionIndicator;
		}
	}
	
	public static function normalizeHeight(target_txt:TextField):Void {
		var copy:String  = target_txt.htmlText;
		var lines:Number = target_txt.bottomScroll;
		
		target_txt.htmlText = '';
		target_txt._height  = 1;
		target_txt.autoSize = 'left';
		
		while (lines--) target_txt.htmlText += '\r';
		var h:Number = target_txt._height;
		
		target_txt.autoSize = 'none';
		target_txt._height  = h + 2;
		target_txt.htmlText = copy;
	}
	
	private function TextFieldUtil() {} // Prevents instance creation
}