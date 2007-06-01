/**
 * Provides the simplest possible graphic for a Tile, useful for debugging purposes.
 * 
 * @author darren
 * $Id$
 */
 
import org.casaframework.event.DispatchableInterface;
import com.modestmaps.geo.MercatorProjection;
import com.modestmaps.geo.Transformation;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

class com.modestmaps.mapproviders.VanillaMapProvider 
extends AbstractMapProvider
implements IMapProvider, DispatchableInterface
{
    public function VanillaMapProvider()
    {
        super();

	    // see: http://modestmaps.mapstraction.com/trac/wiki/TileCoordinateComparisons#TileGeolocations
	    var t:Transformation = new Transformation(1.068070779e7, 0, 3.355443185e7,
		                                          0, -1.068070890e7, 3.355443057e7);
		                                          
        __projection = new MercatorProjection(26, t);

        __topLeftOutLimit = new Coordinate(0, Number.NEGATIVE_INFINITY, 0);
        __bottomRightInLimit = (new Coordinate(1, Number.POSITIVE_INFINITY, 0)).zoomTo(20);
    }

	public function paint(clip:MovieClip, coord:Coordinate):Void 
	{
        super.paint(clip, coord);
        
        clip.createTextField('label', clip.getNextHighestDepth(), 0, 0, 100, 100);
        clip['label'].selectable = false;
        clip['label'].textColor = 0xFFFFFF;
        clip['label'].text = coord.toString();
        clip['label']._width = clip['label'].textWidth + 4;
        clip['label']._height = clip['label'].textHeight + 2;
        
        raisePaintComplete();
	}
}