import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;
import com.modestmaps.mapproviders.AbstractImageBasedMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

/**
 * @author migurski
 * $Id$
 */

class com.modestmaps.mapproviders.BlueMarbleMapProvider
extends AbstractImageBasedMapProvider
implements IMapProvider, DispatchableInterface
{
    public function BlueMarbleMapProvider()
    {
        super();

	    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(9);
    }

    public function toString() : String
    {
        return "BLUE_MARBLE";
    }

    private function getTileUrl(coord:Coordinate):String
    {
        var sourceCoord:Coordinate = sourceCoordinate(coord);
        return 'http://s3.amazonaws.com/com.modestmaps.bluemarble/'+(sourceCoord.zoom)+'-r'+(sourceCoord.row)+'-c'+(sourceCoord.column)+'.jpg';
    }

    public function sourceCoordinate(coord:Coordinate):Coordinate
    {
	    var wrappedColumn:Number = coord.column % Math.pow(2, coord.zoom);

	    while(wrappedColumn < 0)
	        wrappedColumn += Math.pow(2, coord.zoom);
	        
        return new Coordinate(coord.row, wrappedColumn, coord.zoom);
    }
}
