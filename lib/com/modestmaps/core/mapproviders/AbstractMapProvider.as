import com.modestmaps.core.mapproviders.IMapProvider;
import com.modestmaps.io.RequestThrottler;
import com.modestmaps.core.Coordinate;

/**
 * @author darren
 */
class com.modestmaps.core.mapproviders.AbstractMapProvider  
{
	private var __requestThrottler : RequestThrottler;

	private function AbstractMapProvider()
	{
		__requestThrottler = RequestThrottler.getInstance();	
	}

	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
		clip.createEmptyMovieClip( "image", clip.getNextHighestDepth() );
	}

	public function createLabel( clip : MovieClip, label : String ) : Void
	{
		clip.createTextField('labelTF', 1, 0, 0, 1, 1);
	    var tf : TextField = clip["labelTF"];
	    tf.autoSize = true;
	    tf.selectable = false;
	    tf.textColor = 0xFF0000;
		tf.text = label;	
	}
}