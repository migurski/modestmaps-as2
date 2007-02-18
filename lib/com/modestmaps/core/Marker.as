//import com.modestmaps.core.Point;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.Marker
{
    // opaque identifier for external use
    public var id:String;

    public var coord:Coordinate;
    //public var point:Point;

    function Marker(id:String, coord:Coordinate/*, point:Point*/)
    {
        this.id = id;
        this.coord = coord;
        //this.point = point;
    }
    
    public function toString():String
    {
        return 'Marker(' + id + ' ' + coord.toString() + ')';
    }
}
