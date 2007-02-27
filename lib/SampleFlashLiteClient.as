import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.geo.Map;
import com.modestmaps.geo.Location;
import com.modestmaps.mapproviders.MapProviders;
import com.modestmaps.mapproviders.MapProviderFactory;

class SampleFlashLiteClient 
{
	private static var __map:Map;
	
	public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, null, 50);

    	clip._focusRect = false;
    	
        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(),
                                     {mapProvider: MapProviderFactory.getInstance().getMapProvider(MapProviders.MICROSOFT_AERIAL),
                                      _x: 0, _y: 0, width: Stage.width, height: Stage.height,
                                      draggable: true}));
        

        var extent:/*Location*/Array = [new Location(37.829853, -122.514725),
                                        new Location(37.700121, -122.212601)];
        
        __map.setInitialExtent(extent);
        
   		// Set up key listeners. 
   		// TODO: Ghetto. Make this much cleaner.
    	
    	var map:Map = __map;

    	var myListener:Object = new Object();
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
        Stage.addListener(SampleFlashLiteClient);
    }
    
    private static function onResize() : Void
    {
        __map.setSize(Stage.width, Stage.height);
	}
}