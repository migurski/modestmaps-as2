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
}