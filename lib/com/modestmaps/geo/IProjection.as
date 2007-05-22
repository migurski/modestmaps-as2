import flash.geom.Point;
import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Location;
 
interface com.modestmaps.geo.IProjection
{
   /*
    * Return projected and transformed point.
    */
    public function project(point:Point):Point;
    
   /*
    * Return untransformed and unprojected point.
    */
    public function unproject(point:Point):Point;
    
   /*
    * Return projected and transformed coordinate for a location.
    */
    public function locationCoordinate(location:Location):Coordinate;
    
   /*
    * Return untransformed and unprojected location for a coordinate.
    */
    public function coordinateLocation(coordinate:Coordinate):Location;
    
    public function toString():String;
}
