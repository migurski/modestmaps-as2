import mx.events.EventDispatcher;

import com.modestmaps.mapproviders.IMapProvider;
import com.modestmaps.io.RequestThrottler;
import com.modestmaps.core.Coordinate;
import com.modestmaps.events.IDispatchable;
import com.modestmaps.geo.IProjection;
import com.modestmaps.geo.LinearProjection;
import com.modestmaps.geo.Transformation;
import com.modestmaps.geo.Location;

/**
 * @author darren
 */
class com.modestmaps.mapproviders.AbstractMapProvider  
implements IDispatchable
{
	// Event Types
	public static var EVENT_PAINT_COMPLETE : String = "onPaintComplete";
	
	private var __requestThrottler : RequestThrottler;
	private var __projection:IProjection;

	// tracks if we're set up to broadcast events
	private static var _dispatcherInited : Boolean = false;

	/*
	 * Constructor.
	 */
	private function AbstractMapProvider()
	{
		// only set up broadcasting once, in the prototype
		if ( !_dispatcherInited )
		{		
			EventDispatcher.initialize( this.__proto__ );
			_dispatcherInited = true;
		}

		__requestThrottler = RequestThrottler.getInstance();

	    var t:Transformation = new Transformation(1, 0, 0, 0, 1, 0);
        __projection = new LinearProjection(Coordinate.MAX_ZOOM, t);
	}

	public function paint( clip : MovieClip, coord : Coordinate ) : Void 
	{
	    clip.createEmptyMovieClip( "image", clip.getNextHighestDepth() );
	}

   /*
    * String signature of the current map provider's geometric behavior.
    */
	public function toString():String
	{
        return __projection.toString();
	}

	public function createLabel( clip : MovieClip, label : String ) : Void
	{
		clip["labelTF"].removeTextField();
		
		clip.createTextField('labelTF', 1, 0, 0, 1, 1);
	    var tf : TextField = clip["labelTF"];
	    tf.autoSize = true;
	    tf.selectable = false;
	    tf.textColor = 0xFF0000;
		tf.text = label;	
	}
	
	// Private Methods
	
	private function raisePaintComplete( clip : MovieClip, coord : Coordinate ) : Void
	{
		var eventObj : Object =
		{
			target : this,
			type : EVENT_PAINT_COMPLETE,
			clip : clip,
			coord : coord
		};
		dispatchEvent( eventObj );
	}

	// IDispatchable
	public function addEventListener( type : String, handler ) : Void
	{
		super.addEventListener( type, handler );
	}
	
	public function removeEventListener( type : String, handler ) : Void
	{
		super.removeEventListener( type, handler );
	}
	
	public function dispatchEvent( eventObj : Object ) : Void
	{
		super.dispatchEvent( eventObj );
	}
    
   /*
    * Return projected and transformed coordinate for a location.
    */
    public function locationCoordinate(location:Location):Coordinate
    {
        return __projection.locationCoordinate(location);
    }
    
   /*
    * Return untransformed and unprojected location for a coordinate.
    */
    public function coordinateLocation(coordinate:Coordinate):Location
    {
        return __projection.coordinateLocation(coordinate);
    }
}