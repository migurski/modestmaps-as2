import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.geo.Map;
import com.modestmaps.core.TileGrid;
import com.modestmaps.mapproviders.MapProviders;
import com.modestmaps.geo.Location;

class SampleClient
{
	private static var __map : Map;
	
    public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, null, 50);

		var initObj : Object =
		{
			mapProviderType: MapProviders.MICROSOFT_ROAD, 
			_x: 128, 
			_y: 128, 
			width: Stage.width - 256, 
			height: Stage.height - 256
		};

        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(), initObj ));
        
        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(__map); 
        
        var buttons : Array = new Array();
        
        buttons.push( makeButton(clip, 'plus', 'zoom in', Delegate.create(__map, __map.zoomIn)));
        buttons.push( makeButton(clip, 'minus', 'zoom out', Delegate.create(__map, __map.zoomOut)));
        buttons.push( makeButton(clip, 'clear', 'clear log', Delegate.create(__map.grid, __map.grid.clearLog)));

        buttons.push( makeButton(clip, 'road', 'road', Delegate.create(SampleClient, SampleClient.showRoad)));
        buttons.push( makeButton(clip, 'aerial', 'aerial', Delegate.create(SampleClient, SampleClient.showAerial)));
        buttons.push( makeButton(clip, 'hybrid', 'hybrid', Delegate.create(SampleClient, SampleClient.showHybrid)));

		var nextX : Number = __map._x;
		var nextY : Number = __map._y - buttons[0]['label']._height - 10;
		
		for ( var i : Number = 0; i < buttons.length; i++ )
		{
			buttons[i]._x = nextX;
			buttons[i]._y = nextY;
			nextX += buttons[i]['label']._width + 5;	
		}

        Reactor.callNextFrame(Delegate.create(__map, __map.nagAboutBoundsForever));
    }
    
    
    private static function showRoad() : Void
    {
    	__map.setMapProvider( MapProviders.MICROSOFT_ROAD );
    }
 
    private static function showAerial() : Void
    {
    	__map.setMapProvider( MapProviders.MICROSOFT_AERIAL );
    }
 
    private static function showHybrid() : Void
    {
    	__map.setMapProvider( MapProviders.MICROSOFT_HYBRID );
    }
    
    
    public static function makeButton(clip:MovieClip, name:String, label:String, action:Function):MovieClip
    {
        var button:MovieClip = clip.createEmptyMovieClip(name, clip.getNextHighestDepth());
        
        button.createTextField('label', button.getNextHighestDepth(), 0, 0, 100, 100);
        button['label'].selectable = false;
        button['label'].textColor = 0xFFFFFF;
        button['label'].text = label;
        button['label']._width = button['label'].textWidth + 4;
        button['label']._height = button['label'].textHeight + 2;
        
        button.moveTo(0, 0);
        button.beginFill(0x000000, 100);
        button.lineTo(0, button['label']._height);
        button.lineTo(button['label']._width, button['label']._height);
        button.lineTo(button['label']._width, 0);
        button.lineTo(0, 0);
        button.endFill(0, 0);
        
        button.onRelease = action;
        
        return button;
    }
    
    public static function output( str : String ) : Void
    {
    	trace( str );	
    }
    
}
