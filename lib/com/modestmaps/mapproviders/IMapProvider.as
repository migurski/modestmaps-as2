/**
 * @author darren
 */
import com.modestmaps.core.Coordinate; 
import com.modestmaps.geo.Location;
 
interface com.modestmaps.mapproviders.IMapProvider 
{
	public function paint( clip : MovieClip, coord : Coordinate ) : Void;
    
   /*
    * Return projected and transformed coordinate for a location.
    */
    public function locationCoordinate(location:Location):Coordinate;
    
   /*
    * Return untransformed and unprojected location for a coordinate.
    */
    public function coordinateLocation(coordinate:Coordinate):Location;

   /*
    * Get top left outer-zoom limit and bottom right inner-zoom limits,
    * as Coordinates in a two element array.
    */
    public function outerLimits():/*Coordinate*/Array;

   /*
    * A string which describes the projection and transformation of a map provider.
    */
    public function geometry():String;
    
    public function toString() : String;
}