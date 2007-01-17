/**
 * @author darren
 */
import com.modestmaps.core.Coordinate; 
 
interface com.modestmaps.core.mapproviders.IMapProvider 
{
	public function paint( clip : MovieClip, coord : Coordinate ) : Void;
}