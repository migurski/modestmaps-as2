import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.core.Coordinate;
import com.modestmaps.util.BinaryUtil;

/**
 * @author darren
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

    public function sourceCoordinate(coord:Coordinate):Coordinate
    {
	    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);

	    while(wrappedColumn < 0)
	        wrappedColumn += Math.pow(2, coord.zoom);
	        
        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
    }
}