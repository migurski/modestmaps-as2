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

import org.casaframework.util.NumberUtil;
import org.casaframework.util.StringUtil;

/**
	@author David Nelson
	@author Aaron Clinger
	@version 09/22/06
*/

class org.casaframework.util.LoremIpsum {
	private static var $words:Array = new Array('lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetuer', 'adipiscing', 'elit', 'nam', 'imperdiet', 'dignissim', 'erat', 'mauris', 'ut', 'pellentesque', 'habitant', 'morbi', 'tristique', 'senectus', 'et', 'netus', 'malesuada', 'fames', 'ac', 'turpis', 'egestas', 'phasellus', 'sem', 'metus', 'lacinia', 'facilisis', 'at', 'sagittis', 'vel', 'felis', 'aenean', 'bibendum', 'in', 'enim', 'nulla', 'sed', 'ante', 'scelerisque', 'aliquet', 'facilisi', 'aliquam', 'velit', 'vitae', 'tellus', 'massa', 'etiam', 'hendrerit', 'rutrum', 'orci', 'nibh', 'fringilla', 'posuere', 'mi', 'praesent', 'interdum', 'risus', 'arcu', 'donec', 'auctor', 'dui', 'tempus', 'nec', 'id', 'laoreet', 'blandit', 'ligula', 'eu', 'dapibus', 'tincidunt', 'nunc', 'lectus', 'integer', 'curabitur', 'a', 'ultricies', 'quis', 'suscipit', 'eleifend', 'augue', 'congue', 'eros', 'non', 'sapien', 'neque', 'vestibulum', 'nonummy', 'leo', 'ornare', 'vehicula', 'eget', 'tempor', 'magna', 'suspendisse', 'placerat', 'mattis', 'luctus', 'lacus', 'duis', 'venenatis', 'porta', 'urna', 'vivamus', 'nisl', 'proin', 'sollicitudin', 'pulvinar', 'quam', 'maecenas', 'lobortis', 'pharetra', 'purus', 'pretium', 'mollis', 'cum', 'sociis', 'natoque', 'penatibus', 'magnis', 'dis', 'parturient', 'montes', 'nascetur', 'ridiculus', 'mus', 'fusce', 'est', 'ultrices', 'feugiat', 'iaculis', 'nisi', 'sodales', 'vulputate', 'tortor', 'accumsan', 'commodo', 'faucibus', 'justo', 'volutpat', 'porttitor', 'gravida', 'nullam', 'molestie', 'condimentum', 'euismod', 'elementum', 'odio');
	
	
	public static function generate(amount:Number, type:String):String {
		var t:String = 'Lorem ipsum dolor sit amet. ';
		
		switch (type) {
			case 's' :
			case 'sentance' :
			case 'sentances' :
				t += LoremIpsum.$generateSentances(amount);
				break;
			case 'p' :
			case 'paragraph' :
			case 'paragraphs' :
				t += LoremIpsum.$generateParagraphs(amount);
				break;
			case 'w' :
			case 'word' :
			case 'words' :
			default :
				t = LoremIpsum.$generateWords(amount);
				break;
		}
		
		return t;
	}
	
	private static function $generateWords(amount:Number):String {
		var i:Number = amount - 1;
		var l:Number = LoremIpsum.$words.length;
		var t:String = StringUtil.toTitleCase(LoremIpsum.$words[NumberUtil.randomInteger(0, l)]);
		
		while (i--) t += ' ' + LoremIpsum.$words[NumberUtil.randomInteger(0, l)];
		return t;
	}
	
	private static function $generateSentances(amount:Number):String {
		var wordAmount:Number;
		var l:Number = LoremIpsum.$words.length;
		var t:Array;
		var r:String = '';
		amount--;
		
		while (amount--) {
			t = new Array();
			wordAmount = NumberUtil.randomInteger(6, 15);
			while (wordAmount--) t.push(LoremIpsum.$words[NumberUtil.randomInteger(0, l)]);
			t[0] = StringUtil.toTitleCase(t[0]);
			r += t.join(' ') + '. ';
		}
		
		return r;
	}
	
	private static function $generateParagraphs(amount:Number):String {
		var t:String = '';		
		while (amount--) t += LoremIpsum.$generateSentances(NumberUtil.randomInteger(5, 10)) + '\r\r';
		return t;
	}
	
	private function LoremIpsum() {} // Prevents instance creation
}