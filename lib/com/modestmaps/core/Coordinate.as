/*
 * $Id$
 */

class com.modestmaps.core.Coordinate
{
    public var row:Number, column:Number, zoom:Number;
    
    public static var MAX_ZOOM:Number = 20;

    function Coordinate(row:Number, column:Number, zoom:Number)
    {
        this.row = row;
        this.column = column;
        this.zoom = zoom;
    }
    
    public function toString():String
    {
        return '(' + row + ',' + column + ' @' + zoom + ')';
    }
    
    public function copy():Coordinate
    {
        return new Coordinate(row, column, zoom);
    }
    
   /**
    * Return a new coordinate that corresponds to that of the tile containing this one
    */
    public function container():Coordinate
    {
        return new Coordinate(Math.floor(row), Math.floor(column), zoom);
    }
    
    public function zoomTo(destination:Number):Coordinate
    {
        return new Coordinate(row * Math.pow(2, destination - zoom),
                              column * Math.pow(2, destination - zoom),
                              destination);
    }
    
    public function zoomBy(distance:Number):Coordinate
    {
        return new Coordinate(row * Math.pow(2, distance),
                              column * Math.pow(2, distance),
                              zoom + distance);
    }
    
    public function isRowEdge():Boolean
    {
        return Math.round(row) == row;
    }
    
    public function isColumnEdge():Boolean
    {
        return Math.round(column) == column;
    }
    
    public function isEdge():Boolean
    {
        return isRowEdge() && isColumnEdge();
    }
    
    public function up(distance:Number):Coordinate
    {
        return new Coordinate(row - (distance ? distance : 1), column, zoom);
    }
    
    public function right(distance:Number):Coordinate
    {
        return new Coordinate(row, column + (distance ? distance : 1), zoom);
    }
    
    public function down(distance:Number):Coordinate
    {
        return new Coordinate(row + (distance ? distance : 1), column, zoom);
    }
    
    public function left(distance:Number):Coordinate
    {
        return new Coordinate(row, column - (distance ? distance : 1), zoom);
    }
    
    /*
     * Returns true if the the two coordinates refer to the same Tile location.
     */
    public function equalTo( coord : Coordinate ) : Boolean
    {
    	return coord.row == this.row && coord.column == this.column && coord.zoom == this.zoom;
    }
}
