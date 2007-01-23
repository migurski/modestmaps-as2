import Math;
import com.modestmaps.core.Point;
import com.modestmaps.core.Coordinate;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.AbstractProjection; 
 
class com.modestmaps.geo.MercatorProjection
extends AbstractProjection
{
    function MercatorProjection(zoom:Number, T:Transformation)
    {
        super(zoom, T);
    }
    
   /*
    * Return raw projected point.
    * See: http://mathworld.wolfram.com/MercatorProjection.html (2)
    */
    private function rawProject(point:Point):Point
    {
        return new Point(point.x,
                         Math.log(Math.tan(0.25 * Math.PI + 0.5 * point.y)));
    }
    
   /*
    * Return raw unprojected point.
    * See: http://mathworld.wolfram.com/MercatorProjection.html (7)
    */
    private function rawUnproject(point:Point):Point
    {
        return new Point(point.x,
                         2 * Math.atan(Math.pow(Math.E, point.y)) - 0.5 * Math.PI);
    }
}
