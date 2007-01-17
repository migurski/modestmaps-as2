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

import org.casaframework.util.StringUtil;
import org.casaframework.util.ArrayUtil;
import org.casaframework.util.ObjectUtil;

/**
	@author Aaron Clinger
	@version 09/27/06
*/

class org.casaframework.util.ValidationUtil {
	
	
	public static function isEmail(email:String):Boolean {
		if (email.length < 6 || ValidationUtil.isEmpty(email))
			return false;
		
		if (StringUtil.contains(email, ' ') > 0)
			return false;
		
		if (StringUtil.contains(email, '@') != 1)
			return false;
		
		var atSign:Number  = email.indexOf('@');
		var lastDot:Number = email.lastIndexOf('.');
		
		if ((lastDot < atSign + 2) || (lastDot > email.length - 3))
			return false;
		
		return true;
	}
	
	public static function isPhone(phone:String):Boolean {
		return StringUtil.getNumbersFromString(phone).length >= 10;
	}
	
	public static function isZip(zip:String):Boolean {
		var l:Number = StringUtil.getNumbersFromString(zip).length;
		return (l == 5 || l == 9);
	}
	
	public static function isStateAbbreviation(state:String):Boolean {
		var states:Array = new Array('ak', 'al', 'ar', 'az', 'ca', 'co', 'ct', 'dc', 'de', 'fl', 'ga', 'hi', 'ia', 'id', 'il', 'in', 'ks', 'ky', 'la', 'ma', 'md', 'me', 'mi', 'mn', 'mo', 'ms', 'mt', 'nb', 'nc', 'nd', 'nh', 'nj', 'nm', 'nv', 'ny', 'oh', 'ok', 'or', 'pa', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut', 'va', 'vt', 'wa', 'wi', 'wv', 'wy');
		return ArrayUtil.contains(states, state.toLowerCase()) == 1;
	}
	
	public static function contains(source:String, search:String):Boolean {
		return StringUtil.contains(source, search) > 0;
	}
	
	public static function isEmpty(source:String):Boolean {
		return ObjectUtil.isEmpty(source);
	}
	
	public static function isCreditCard(cardNumber:String):Boolean {
		if (cardNumber.length < 7 || cardNumber.length > 19 || Number(cardNumber) < 1000000) return false;
		
		// Luhn Formula
		var pre:Number;
		var sum:Number  = 0;
		var alt:Boolean = true;
		
		var i:Number = cardNumber.length;
		while (--i > -1) {
			if (alt)
				sum += Number(cardNumber.substr(i, 1));
			else {
				pre =  Number(cardNumber.substr(i, 1)) * 2;
				sum += (pre > 8) ? pre -= 9 : pre;
			}
			
			alt = !alt;
		}
		
		return sum % 10 == 0;
	}
	
	public static function getCreditCardProvider(cardNumber:String):String {
		if (!ValidationUtil.isCreditCard(cardNumber))
			return 'invalid';
		
		if (cardNumber.length == 13 ||
			cardNumber.length == 16 &&
			cardNumber.indexOf('4') == 0)
		{
			return 'visa';
		} 
		else if (cardNumber.indexOf('51') == 0 ||
				 cardNumber.indexOf('52') == 0 ||
				 cardNumber.indexOf('53') == 0 ||
				 cardNumber.indexOf('54') == 0 ||
				 cardNumber.indexOf('55') == 0 &&
				 cardNumber.length == 16)
		{
			return 'mastercard';
		}
		else if (cardNumber.length == 16 &&
			     cardNumber.indexOf('6011') == 0)
		{
			 return 'discover';
		} 
		else if (cardNumber.indexOf('34') == 0 ||
				 cardNumber.indexOf('37') == 0 &&
				 cardNumber.length == 15)
		{
			return 'amex';
		}
		else if (cardNumber.indexOf('300') == 0 ||
				 cardNumber.indexOf('301') == 0 ||
				 cardNumber.indexOf('302') == 0 ||
				 cardNumber.indexOf('303') == 0 ||
				 cardNumber.indexOf('304') == 0 ||
				 cardNumber.indexOf('305') == 0 ||
				 cardNumber.indexOf('36') == 0 ||
				 cardNumber.indexOf('38') == 0 &&
				 cardNumber.length == 14)
		{
			return 'diners';
		}
		else return 'other';
	}
	
	private function ValidationUtil() {} // Prevents instance creation
}