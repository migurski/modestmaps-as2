import com.modestmaps.geo.Location;
import com.modestmaps.Map;
import com.modestmaps.mapproviders.MapProviderFactory;
import com.modestmaps.mapproviders.MapProviders;
import com.stamen.twisted.Reactor;

class SampleFlashLiteClient 
{
	private static var __map:Map;
	
	public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, null, 50);

    	clip._focusRect = false;
    	
        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(),
                                     {_x: 0, _y: 0}));
        
        __map.init(Stage.width, Stage.height, true, MapProviderFactory.getInstance().getMapProvider(MapProviders.MICROSOFT_AERIAL)); 

        var extent:/*Location*/Array = [new Location(37.829853, -122.514725),
                                        new Location(37.700121, -122.212601)];
        
        __map.setExtent(extent);
        
   		// Set up key listeners. 
   		// TODO: Ghetto. Make this much cleaner.
    	
    	var map:Map = __map;

    	var myListener:Object = new Object();
		myListener.onKeyDown = function() 
		{
			switch ( Key.getCode() )
			{
				case Key.RIGHT:
					map.panRight();
					break;	
				
				case Key.LEFT:
					map.panLeft();
					break;

				case Key.UP:
					map.panUp();
					break;	
				
				case Key.DOWN:
					map.panDown();
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