import org.casaframework.movieclip.DispatchableMovieClip;

import com.modestmaps.core.Point;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.mapproviders.IMapProvider;

class com.modestmaps.core.Tile 
extends DispatchableMovieClip
{
    public var grid:TileGrid;

    public var coord:Coordinate;
    
    /*
    public var row:Number = 0;
    public var column:Number = 0;
    public var zoom:Number = 0;
    */

    public var width:Number;
    public var height:Number;
    
    private var label:TextField;
    public var origin:Boolean;

	public var displayClip : MovieClip;

    public static var symbolName:String = '__Packages.com.modestmaps.core.Tile';
    public static var symbolOwner:Function = Tile;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function Tile()
    {
    	super();
    }
    
    public function center():Point
    {
        return new Point(_x + width / 2, _y + height / 2);
    }
    
    public function zoomOut():Void
    {
        coord = new Coordinate(Math.floor(coord.row / 2), Math.floor(coord.column / 2), coord.zoom + 1);
        redraw();
    }

    public function zoomInTopLeft():Void
    {
        coord = new Coordinate(coord.row * 2, coord.column * 2, coord.zoom - 1);
        redraw();
    }

    public function zoomInTopRight():Void
    {
        coord = new Coordinate(coord.row * 2, coord.column * 2 + 1, coord.zoom - 1);
        redraw();
    }

    public function zoomInBottomLeft():Void
    {
        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2, coord.zoom - 1);
        redraw();
    }

    public function zoomInBottomRight():Void
    {
        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2 + 1, coord.zoom - 1);
        redraw();
    }

    public function panUp(distance:Number):Void
    {
        coord = coord.up(distance);
        redraw();
    }

    public function panRight(distance:Number):Void
    {
        coord = coord.right(distance);
        redraw();
    }

    public function panDown(distance:Number):Void
    {
        coord = coord.down(distance);
        redraw();
    }

    public function panLeft(distance:Number):Void
    {
        coord = coord.left(distance);
        redraw();
    }

    public function toString():String
    {
        return 'Tile' + coord.toString();
    }

    public function redraw():Void
    {
    	paint( grid.mapProvider );
    	
        dispatchEvent( "invalidated", this );
    }
    
    public function paint( mapProvider : IMapProvider ) : Void
    {
    	// set up the proper clip to paint here
    	
    	var clip : MovieClip = this.createEmptyMovieClip( "display", this.getNextHighestDepth() );
   	
    	mapProvider.paint( clip, coord );
    }
    
}