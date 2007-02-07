import com.modestmaps.io.LoadMovieThrottledRequest;
import com.modestmaps.core.Coordinate;
import com.modestmaps.io.ThrottledRequest;

/**
 * @author darren
 */
class com.modestmaps.io.MapProviderPaintThrottledRequest 
extends LoadMovieThrottledRequest 
{
	public var coord : Coordinate;
	
	public function MapProviderPaintThrottledRequest(clip : MovieClip, url : String, coord : Coordinate ) 
	{
		super(clip, url);
		
		this.coord = coord;
	}

	private function onLoadComplete( clip : MovieClip, httpStatus : Number ) : Void
	{
		var eventObj : Object =
		{
			target : this,
			type : ThrottledRequest.EVENT_RESPONSE_COMPLETE,
			clip : clip,
			coord : coord
		};
		dispatchEvent( eventObj );
		
		cleanup();
	}
}