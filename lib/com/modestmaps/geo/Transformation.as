import com.modestmaps.core.Point;
import com.modestmaps.geo.Transformation;
 
class com.modestmaps.geo.Transformation
{
    private var ax:Number;
    private var bx:Number;
    private var cx:Number;
    private var ay:Number;
    private var by:Number;
    private var cy:Number;

	function Transformation(ax:Number, bx:Number, cx:Number, ay:Number, by:Number, cy:Number)
	{
        this.ax = ax;
        this.bx = bx;
        this.cx = cx;
        this.ay = ay;
        this.by = by;
        this.cy = cy;
	}
	
	public function transform(point:Point):Point
	{
	    return new Point(ax*point.x + bx*point.y + cx,
	                     ay*point.x + by*point.y + cy);
	}
	
	public function untransform(point:Point):Point
	{
	    return new Point((point.x*by - point.y*bx - cx*by + cy*bx) / (ax*by - ay*bx),
	                     (point.x*ay - point.y*ax - cx*ay + cy*ax) / (bx*ay - by*ax));
	}
}
