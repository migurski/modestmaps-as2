/**
 * @author darren
 */
 
import org.casaframework.event.DispatchableInterface;

import com.modestmaps.core.Coordinate;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;

class com.modestmaps.mapproviders.VanillaMapProvider 
extends AbstractMapProvider
implements IMapProvider, DispatchableInterface
{
	public function paintTile( clip : MovieClip, coord : Coordinate ) : Void 
	{
		super.paint( clip, coord );

		with ( clip )
		{
			clear();
		    moveTo(0, 0);
		    lineStyle(0, 0x0099FF, 100);
		    beginFill(0x000000, 20);
		    lineTo(0, clip._height);
		    lineTo(clip._width, clip._height);
		    lineTo(clip._width, 0);
		    lineTo(0, 0);
		    endFill();
		}

	    createLabel( clip, coord.toString() );

		// TODO: Fire even when paint is done.
	}
}