import com.modestmaps.core.Coordinate;
import com.modestmaps.core.TileGrid;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;
import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;

/**
 * @author darren
 * $Id$
 */
class com.modestmaps.mapproviders.yahoo.AbstractYahooMapProvider 
extends AbstractImageBasedMapProvider 
{
	function AbstractYahooMapProvider() 
	{
		super();

	    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(Coordinate.MAX_ZOOM);
	}

	/**
	 * Yahoo clips are 258x258 to deal with Flash pixel fudge, we mask and offset them by
	 * one pixel so they show up correctly.
	 */
	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		super.paint( clip, coord );

	    clip.image._x = clip.image._y = -.5;
		createMask( clip );		
	}


    public function sourceCoordinate(coord:Coordinate):Coordinate
    {
	    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);

	    while(wrappedColumn < 0)
	        wrappedColumn += Math.pow(2, coord.zoom);
	        
        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
    }
    
    private function createMask( clip : MovieClip ) : Void
    {
	    var mask : MovieClip = clip.createEmptyMovieClip( "mask", clip.getNextHighestDepth() );
	    with ( mask )
	    {
	        moveTo(0, 0);
	        //lineStyle( 1, 0x000000 );
	        beginFill(0x000000, 100);
	        lineTo(0, TileGrid.TILE_HEIGHT);
	        lineTo(TileGrid.TILE_WIDTH, TileGrid.TILE_HEIGHT);
	        lineTo(TileGrid.TILE_WIDTH, 0);
	        lineTo(0, 0);
	        endFill(0, 0);
	    }
	    clip.setMask( mask );    	
    }
}