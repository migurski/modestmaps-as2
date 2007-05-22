import flash.geom.Point;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.MapPosition
{
    public var coord:Coordinate;
    public var point:Point;
    
    public function MapPosition(c:Coordinate, p:Point)
    {
        coord = c;
        point = p;
    }
}
