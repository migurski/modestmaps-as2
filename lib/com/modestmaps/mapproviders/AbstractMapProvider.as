/**
 * vim:et sts=4 sw=4 cindent:
 * @ignore
 *
 * @author darren
 * @author migurski
 * $Id$
 *
 * AbstractMapProvider is the base class for all map providers.
 * 
 * @description AbstractMapProvider is the base class for all map providers.
 * 				Map providers are primarily responsible for "painting" map
 *              tiles with the correct graphic imagery.
 */

import org.casaframework.event.DispatchableInterface;
import org.casaframework.event.EventDispatcher;

import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.IProjection;
import com.modestmaps.geo.LinearProjection;
import com.modestmaps.geo.Location;
import com.modestmaps.geo.Transformation;
import com.modestmaps.io.RequestThrottler;

class com.modestmaps.mapproviders.AbstractMapProvider  
extends EventDispatcher
implements DispatchableInterface
{
	// Event Types
	public static var EVENT_PAINT_COMPLETE : String = "onPaintComplete";
	
	private var __requestThrottler : RequestThrottler;
	private var __projection:IProjection;
	
	// boundaries for the current provider
	private var __topLeftOutLimit:Coordinate;
	private var __bottomRightInLimit:Coordinate;

	/*
	 * Abstract constructor, should not be instantiated directly.
	 */
	private function AbstractMapProvider()
	{
		__requestThrottler = RequestThrottler.getInstance();

	    var t:Transformation = new Transformation(1, 0, 0, 0, 1, 0);
        __projection = new LinearProjection(Coordinate.MAX_ZOOM, t);

        __topLeftOutLimit = new Coordinate(0, 0, 0);
        __bottomRightInLimit = (new Coordinate(1, 1, 0)).zoomTo(Coordinate.MAX_ZOOM);
	}

	/**
	 * Paints a map graphic onto the supplied MovieClip.
	 * 
	 * @param clip The MovieClip to contain the graphics.
	 * @param coord The coordinate of the Tile that contains the clip.
	 */
	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
	    clip.createEmptyMovieClip( "image", clip.getNextHighestDepth() );
	}

   /*
    * String signature of the current map provider's geometric behavior.
    */
	public function geometry():String
	{
        return __projection.toString();
	}

	/**
	 * Generates a copy of the specified coordinate.
	 * 
	 * @param coord The Coordinate to copy.
	 */
    public function sourceCoordinate(coord:Coordinate):Coordinate
    {
        return coord.copy();
    }

   /*
    * Get top left outer-zoom limit and bottom right inner-zoom limits,
    * as Coordinates in a two element array.
    */
    public function outerLimits():/*Coordinate*/Array
    {
        var limits:/*Coordinate*/Array = [];

        limits[0] = __topLeftOutLimit.copy();
        limits[1] = __bottomRightInLimit.copy();

        return limits;
    }

   /*
    * Return projected and transformed coordinate for a location.
    */
    public function locationCoordinate(location:Location):Coordinate
    {
        return __projection.locationCoordinate(location);
    }
    
   /*
    * Return untransformed and unprojected location for a coordinate.
    */
    public function coordinateLocation(coordinate:Coordinate):Location
    {
        return __projection.coordinateLocation(coordinate);
    }
	
	// Private Methods
	
	private function raisePaintComplete( clip : MovieClip, coord : Coordinate ) : Void
	{
		dispatchEvent( AbstractMapProvider.EVENT_PAINT_COMPLETE, clip, coord );
	}
}
