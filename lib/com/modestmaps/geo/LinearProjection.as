import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.AbstractProjection; 
 
class com.modestmaps.geo.LinearProjection
extends AbstractProjection
{
    function LinearProjection(zoom:Number, T:Transformation)
    {
        super(zoom, T);
    }
}
