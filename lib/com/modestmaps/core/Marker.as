//import com.modestmaps.core.Point;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.Marker
{
    public var coord:Coordinate;
    //public var point:Point;

    function Marker(coord:Coordinate/*, point:Point*/)
    {
        this.coord = coord;
        //this.point = point;
    }
    
    public function toString():String
    {
        return 'Marker' + coord.toString();
    }
}
