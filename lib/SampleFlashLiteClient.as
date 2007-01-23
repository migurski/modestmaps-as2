import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.geo.Map;
import com.modestmaps.core.mapproviders.MapProviders;

class SampleFlashLiteClient 
{
	public static function main(clip:MovieClip):Void
    {
    	clip._focusRect = false;
    	
        var map:Map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(),
                                           {mapProviderType: MapProviders.MICROSOFT_AERIAL, _x: 0, _y: 0, width: Stage.width, height: Stage.height}))
        

   		// Set up key listeners. 
   		// TODO: Ghetto. Make this much cleaner.
    	
    	var myListener:Object = new Object();
    	myListener.map = map;
		myListener.onKeyDown = function() 
		{
			switch ( Key.getCode() )
			{
				case Key.RIGHT:
					map.panEast( Stage.width );
					break;	
				
				case Key.LEFT:
					map.panWest( Stage.width );
					break;

				case Key.UP:
					map.panNorth( Stage.height );
					break;	
				
				case Key.DOWN:
					map.panSouth( Stage.height );
					break;
			}
		};
		Key.addListener(myListener);


        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(map);
        
        Reactor.run(clip, null, 50);
    }
}