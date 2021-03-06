/**
 * @author darren
 * $Id$
 */
class com.modestmaps.util.BinaryUtil 
{
	public static function convertToBinary( numberToConvert : Number ) : String 
	{ 
	    var result : String = ""; 
	    for ( var i : Number = 0; i < 32; i++) 
	    { 
	        // Extract least significant bit using bitwise AND 
	        var lsb : Number = numberToConvert & 1; 
	        
	        // Add this bit to the result 
	        result = (lsb ? "1" : "0") + result; 
	        
	        // Shift numberToConvert right by one bit, to see next bit 
	        numberToConvert >>= 1; 
	    } 
	    return result; 
	}
	
	public static function convertToDecimal( binaryRepresentation : String ) : Number
	{
		var result : Number = 0;
			
		for ( var i : Number = binaryRepresentation.length; i > 0; i-- )
		{
			result += parseInt( binaryRepresentation.charAt( binaryRepresentation.length-i ) ) * Math.pow( 2, i-1 );
		}
		
		return result;
	}
}