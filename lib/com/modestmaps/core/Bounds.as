import flash.geom.Point;

class com.modestmaps.core.Bounds
{
    var min:Point, max:Point;

    function Bounds(min:Point, max:Point)
    {
        this.min = min;
        this.max = max;
    }
}
