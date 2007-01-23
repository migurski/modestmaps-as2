/**
 * @author darren
 */
 
import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.core.mapproviders.AbstractMapProvider;
import com.modestmaps.core.Coordinate;
import com.modestmaps.events.IDispatchable;

class com.modestmaps.core.mapproviders.VanillaMapProvider 
extends AbstractMapProvider
implements IMapProvider, IDispatchable
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