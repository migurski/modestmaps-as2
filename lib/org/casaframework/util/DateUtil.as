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
import org.casaframework.util.ConversionUtil;

/**
	@author Aaron Clinger
	@version 09/28/06
*/

class org.casaframework.util.DateUtil {
	
	public static function formatDate(dateToFormat:Date, formatString:String):String {
		var returnString:String;
		var char:String;
		var i:Number = -1;
		var t:Number;
		
		while (++i < formatString.length) {
			char = formatString.substr(i, 1);
			
			if (char == '^') {
				i++;
				returnString += formatString.substr(i, 1);
			} else {
				switch (char) {
					// Day of the month, 2 digits with leading zeros
					case 'd' :
						returnString += NumberUtil.addLeadingZero(dateToFormat.getDate());
						break;
					// A textual representation of a day, three letters
					case 'D' :
						returnString += DateUtil.getDayAbbrAsString(dateToFormat.getDay());
						break;
					// Day of the month without leading zeros
					case 'j' :
						returnString += dateToFormat.getDate().toString();
						break;
					// A full textual representation of the day of the week
					case 'l' :
						returnString += DateUtil.getDayAsString(dateToFormat.getDay());
						break;
					// ISO-8601 numeric representation of the day of the week
					case 'N' :
						t = dateToFormat.getDay();
						if (t == 0) t = 7;
						returnString += t.toString();
						break;
					// English ordinal suffix for the day of the month, 2 characters
					case 'S' :
						returnString += DateUtil.getOrdinalSuffix(dateToFormat.getDate());
						break;
					// Numeric representation of the day of the week
					case 'w' :
						returnString += dateToFormat.getDay().toString();
						break;
					// The day of the year (starting from 0)
					case 'z' :
						returnString += NumberUtil.addLeadingZero(DateUtil.getDayOfTheYear(dateToFormat)).toString();
						break;
					// ISO-8601 week number of year, weeks starting on Monday 
					case 'W' :
						returnString += NumberUtil.addLeadingZero(DateUtil.getWeekOfTheYear(dateToFormat)).toString();
						break;
					// A full textual representation of a month, such as January or March
					case 'F' :
						returnString += DateUtil.getMonthAsString(dateToFormat.getMonth());
						break;
					// Numeric representation of a month, with leading zeros
					case 'm' :
						returnString += NumberUtil.addLeadingZero(dateToFormat.getMonth() + 1);
						break;
					// A short textual representation of a month, three letters
					case 'M' :
						returnString += DateUtil.getMonthAbbrAsString(dateToFormat.getMonth());
						break;
					// Numeric representation of a month, without leading zeros
					case 'n' :
						returnString += dateToFormat.getMonth().toString();
						break;
					// Number of days in the given month
					case 't' :
						returnString += DateUtil.getDaysInMonth(dateToFormat.getMonth(), dateToFormat.getFullYear()).toString();
						break;
					// Whether it's a leap year
					case 'L' :
						returnString += (DateUtil.isLeapYear(dateToFormat.getFullYear())) ? '1' : '0';
						break;
					// A full numeric representation of a year, 4 digits
					case 'o' :
					case 'Y' :
						returnString += dateToFormat.getFullYear().toString();
						break;
					// A two digit representation of a year
					case 'y' :
						returnString += dateToFormat.getFullYear().toString().substr(-2);
						break;
					// Lowercase Ante meridiem and Post meridiem
					case 'a' :
						returnString += DateUtil.getMeridiem(dateToFormat.getHours()).toLowerCase();
						break;
					// Uppercase Ante meridiem and Post meridiem
					case 'A' :
						returnString += DateUtil.getMeridiem(dateToFormat.getHours());
						break;
					// Swatch Internet time
					case 'B' :
						returnString += DateUtil.getInternetTime(dateToFormat).toString();
						break;
					// 12-hour format of an hour without leading zeros
					case 'g' :
						t = dateToFormat.getHours() + 1;
						if (t > 12) t -= 12;
						returnString += t.toString();
						break;
					// 24-hour format of an hour without leading zeros
					case 'G' :
						returnString += dateToFormat.getHours().toString();
						break;
					// 12-hour format of an hour with leading zeros
					case 'h' :
						t = dateToFormat.getHours() + 1;
						if (t > 12) t -= 12;						
						returnString += NumberUtil.addLeadingZero(t);
						break;
					// 24-hour format of an hour with leading zeros
					case 'H' :
						returnString += NumberUtil.addLeadingZero(dateToFormat.getHours());						
						break;
					// Minutes with leading zeros
					case 'i' :
						returnString += NumberUtil.addLeadingZero(dateToFormat.getMinutes());
						break;
					// Seconds, with leading zeros
					case 's' :
						returnString += NumberUtil.addLeadingZero(dateToFormat.getSeconds());
						break;
					// Whether or not the date is in daylights savings time
					case 'I' :
						returnString += (DateUtil.isDaylightSavings(dateToFormat)) ? '1' : '0';
						break;
					// Difference to Greenwich time (GMT/UTC) in hours
					case 'O' :
						returnString += DateUtil.getDifferenceFromUTCInHours(dateToFormat);
						break;
					// Timezone identifier
					case 'e' :
					case 'T' :
						returnString += DateUtil.getTimezone(dateToFormat);
						break;
					// Timezone offset (GMT/UTC) in seconds.
					case 'Z' :
						returnString += DateUtil.getDifferenceFromUTCInSeconds(dateToFormat).toString();
						break;
					// ISO 8601 date
					case 'c' :
						returnString += dateToFormat.getFullYear() + "-" + NumberUtil.addLeadingZero(dateToFormat.getMonth() + 1) + "-" + NumberUtil.addLeadingZero(dateToFormat.getDate()) + "T" + NumberUtil.addLeadingZero(dateToFormat.getHours()) + ":" + NumberUtil.addLeadingZero(dateToFormat.getMinutes()) + ":" + NumberUtil.addLeadingZero(dateToFormat.getSeconds());
						break;
					// RFC 2822 formatted date
					case 'r' :
						returnString += DateUtil.getDayAbbrAsString(dateToFormat.getDay()) + ', ' + dateToFormat.getDate() + ' ' + DateUtil.getMonthAbbrAsString(dateToFormat.getMonth()) + ' ' + dateToFormat.getFullYear() + ' ' + NumberUtil.addLeadingZero(dateToFormat.getHours()) + ':' + NumberUtil.addLeadingZero(dateToFormat.getMinutes()) + ':' + NumberUtil.addLeadingZero(dateToFormat.getSeconds()) + ' ' + DateUtil.getDifferenceFromUTCInHours(dateToFormat);
						break;
					// Seconds since the Unix Epoch (January 1 1970 00:00:00 GMT)
					case 'U' :
						t = dateToFormat.getTime() / 1000;
						returnString += t.toString();
						break;
					default :
						returnString += formatString.substr(i, 1);
						break;
				}
			}
		}
		
		
		return returnString;
	}
	
	
	public static function getMonthAsString(month:Number):String {
		var monthNamesFull:Array = new Array('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
		return monthNamesFull[month];
	}
	
	public static function getMonthAbbrAsString(month:Number):String {
		return DateUtil.getMonthAsString(month).substr(0, 3);
	}
	
	public static function getDayAsString(day:Number):String {
		var dayNamesFull:Array = new Array('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
		return dayNamesFull[day];
	}
	
	public static function getDayAbbrAsString(day:Number):String {
		return DateUtil.getDayAsString(day).substr(0, 3);
	}
	
	public static function getDayTwoLetterAbbrAsString(day:Number):String {
		return DateUtil.getDayAsString(day).substr(0, 2);
	}
	
	public static function getDaysInMonth(month:Number, year:Number):Number {
		var t:Date = new Date(year, month, 0);
		return t.getDate();
	}
	
	public static function getOrdinalSuffix(date:Number):String {
		var day:Number = Number(date.toString().substr(-1));
		
		if (day > 3 || day == 0) return 'th';
		else if (day == 3) return 'rd';
		else if (day == 2) return 'nd';
		else return 'st';
	}
	
	public static function getMeridiem(hours:Number):String {
		return (hours < 11) ? 'AM' : 'PM';
	}
	
	public static function getTimeUntil(startDate:Date, futureDate:Date):Object {
		var differenceInMilliseconds:Number = futureDate.getTime() - startDate.getTime();
		
		return {
					days:         Math.floor(ConversionUtil.millisecondsToDays(differenceInMilliseconds)),
					hours:        Math.floor(ConversionUtil.millisecondsToHours(differenceInMilliseconds)),
					minutes:      Math.floor(ConversionUtil.millisecondsToMinutes(differenceInMilliseconds)),
					seconds:      Math.floor(ConversionUtil.millisecondsToSeconds(differenceInMilliseconds)), 
					milliseconds: differenceInMilliseconds};
	}
	
	public static function getCountdownUntil(startDate:Date, futureDate:Date):Object {
		var differenceInMilliseconds:Number = futureDate.getTime() - startDate.getTime();
		
		var daysUntil:Number  = ConversionUtil.millisecondsToDays(differenceInMilliseconds);
		var hoursUntil:Number = ConversionUtil.daysToHours(daysUntil % 1);
		var minsUntil:Number  = ConversionUtil.hoursToMinutes(hoursUntil % 1);
		var secsUntil:Number  = ConversionUtil.minutesToSeconds(minsUntil % 1);
		var milliUntil:Number = ConversionUtil.secondsToMilliseconds(secsUntil % 1);
		
		
		return {
					days:         Math.floor(daysUntil),
					hours:        Math.floor(hoursUntil),
					minutes:      Math.floor(minsUntil),
					seconds:      Math.floor(secsUntil), 
					milliseconds: Math.round(milliUntil)};
	}
	
	public static function getDifferenceFromUTCInSeconds(d:Date):Number {
		return -Math.round(ConversionUtil.minutesToSeconds(d.getTimezoneOffset()));
	}
	
	public static function getDifferenceFromUTCInHours(d:Date):String {
		var t:Number   =  Math.round(ConversionUtil.minutesToHours(d.getTimezoneOffset()));
		var pre:String = (-t < 0) ? '-' : '+';
		
		return pre + NumberUtil.addLeadingZero(Math.abs(t)) + '00';
	}
	
	public static function getTimezone(d:Date):String {
		var timeZones = new Array('IDLW', 'NT', 'HST', 'AKST', 'PST', 'MST', 'CST', 'EST', 'AST', 'ADT', 'AT', 'WAT', 'GMT', 'CET', 'EET', 'MSK', 'ZP4', 'ZP5', 'ZP6', 'WAST', 'WST', 'JST', 'AEST', 'AEDT', 'NZST');
		var hour:Number = Math.round(12 + -(d.getTimezoneOffset() / 60));
		if (DateUtil.isDaylightSavings(d)) hour--;
		
		return timeZones[hour];
	}
	
	public static function isLeapYear(year:Number):Boolean {
		var d:Date = new Date(year, 2, 0);
		return (d.getDate() == 29) ? true : false;
	}
	
	public static function isDaylightSavings(d:Date):Boolean {
		var futureDate:Date = new Date(d.getFullYear(), d.getMonth() - 6);
		
		return (d.getTimezoneOffset() < futureDate.getTimezoneOffset()) ? true : false;
	}
	
	public static function getInternetTime(d:Date):Number {
		return Math.floor((((((d.getUTCHours() + 1) * 60) + d.getUTCMinutes()) * 60) + d.getUTCSeconds()) /  86.4);
	}
	
	public static function getDayOfTheYear(d:Date):Number {
		var firstDay:Date = new Date(d.getFullYear(), 0, 1);
		return Math.floor((d.getTime() - firstDay.getTime()) / 86400000);
	}
	
	public static function getWeekOfTheYear(d:Date):Number {
		var firstDay:Date = new Date(d.getFullYear(), 0, 1);
		return Math.floor(((d.getTime() - firstDay.getTime()) / 86400000) / 7) + 1;
	}
	
	public static function gregorianToJulian(year:Number, month:Number, day:Number, hours:Number, minutes:Number, seconds:Number) : Number {
		var JD:Number;
		var GGG:Number;
		var J1:Number;
		var S:Number;
		var A:Number;
		var MM:Number=month;
		var DD:Number=day;
		var YY:Number=year;
		var HR:Number=hours;
		var MN:Number=minutes;
		var SC:Number=seconds;
		
		HR = HR + (MN / 60) + (SC/3600);
		GGG = 1;
		if (YY <= 1585) GGG = 0;
		JD = -1 * Math.floor(7 * (Math.floor((MM + 9) / 12) + YY) / 4);
		S = 1;
		if ((MM - 9)<0) S=-1;
		A = Math.abs(MM - 9);
		J1 = Math.floor(YY + S * Math.floor(A / 7));
		J1 = -1 * Math.floor((Math.floor(J1 / 100) + 1) * 3 / 4);
		JD = JD + Math.floor(275 * MM / 9) + DD + (GGG * J1);
		JD = JD + 1721027 + 2 * GGG + 367 * YY - 0.5;
		JD = JD + (HR / 24);
		
		return JD;
	}
	
	private function DateUtil() {} // Prevents instance creation
}