import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.geo.Map;
import com.modestmaps.core.TileGrid;
import com.modestmaps.mapproviders.MapProviders;
import com.modestmaps.mapproviders.MapProviderFactory;
import com.modestmaps.geo.Location;

class SampleClient
{
	private static var __map : Map;
	
	private static var __mpButtons : MovieClip;
	
    public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, null, 50);

		var initObj : Object =
		{
			mapProvider: MapProviderFactory.getInstance().getMapProvider(MapProviders.GOOGLE_ROAD), 
			_x: 128, 
			_y: 128, 
			width: Stage.width - 256, 
			height: Stage.height - 256,
			draggable: true
		};

        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth(), initObj ));

        var extent:/*Location*/Array = [new Location(37.829853, -122.514725),
                                        new Location(37.700121, -122.212601)];
        
        __map.setInitialExtent(extent);
        
        __map.putMarker('Rochdale', new Location(37.865571, -122.259679));
        __map.putMarker('Parker Ave.', new Location(37.780492, -122.453731));
        __map.putMarker('Pepper Dr.', new Location(37.623443, -122.426577));
        __map.putMarker('3rd St.', new Location(37.779297, -122.392877));
        __map.putMarker('Divisadero St.', new Location(37.771919, -122.437413));
        __map.putMarker('Market St.', new Location(37.812734, -122.280064));
        __map.putMarker('17th St.', new Location(37.804274, -122.262940));
        
        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(__map); 
        Stage.addListener( SampleClient );
        
        var buttons : Array = new Array();
        
        buttons.push( makeButton(clip, 'plus', 'zoom in', Delegate.create(__map, __map.zoomIn)));
        buttons.push( makeButton(clip, 'minus', 'zoom out', Delegate.create(__map, __map.zoomOut)));
        buttons.push( makeButton(clip, 'clear', 'clear log', Delegate.create(__map.grid, __map.grid.clearLog)));

		var nextX : Number = __map._x;
		var nextY : Number = __map._y - buttons[0]['label']._height - 10;
		
		for ( var i : Number = 0; i < buttons.length; i++ )
		{
			buttons[i]._x = nextX;
			buttons[i]._y = nextY;
			nextX += buttons[i]['label']._width + 5;	
		}


		// mapProvider buttons

		__mpButtons = clip.createEmptyMovieClip( "mpButtons", clip.getNextHighestDepth() );

        buttons = new Array();
		
		buttons.push( makeButton(__mpButtons, 'MICROSOFT_ROAD', 'ms road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'MICROSOFT_AERIAL', 'ms aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'MICROSOFT_HYBRID', 'ms hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		buttons.push( makeButton(__mpButtons, 'GOOGLE_ROAD', 'google road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'GOOGLE_AERIAL', 'google aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'GOOGLE_HYBRID', 'google hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		buttons.push( makeButton(__mpButtons, 'YAHOO_ROAD', 'yahoo road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'YAHOO_AERIAL', 'yahoo aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'YAHOO_HYBRID', 'yahoo hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

        buttons.push( makeButton(__mpButtons, 'BLUE_MARBLE', 'blue marble', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push( makeButton(__mpButtons, 'OPEN_STREET_MAP', 'open street map', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		__mpButtons._x = 128 + __map._x + __map._width;
		__mpButtons._y = __map._y + 10;
		
		nextY = 0;
		
		for ( var i : Number = 0; i < buttons.length; i++ )
		{
			buttons[i]._y = nextY;
			nextY += buttons[i]['label']._height + 5;
			buttons[i]._alpha = 60;
		}
		

        Reactor.callNextFrame(Delegate.create(__map, __map.nagAboutBoundsForever));
        
        _root.createEmptyMovieClip('marks', _root.getNextHighestDepth());
    }
    
    
    private static function switchMapProvider( button : MovieClip ) : Void
    {
    	__map.setMapProvider(MapProviderFactory.getInstance().getMapProvider(MapProviders[button._name]));
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
        
        button.onRelease = function()
        {
        	action.apply( SampleClient, [button] );
        };
        
        return button;
    }
    
    public static function output( str : String ) : Void
    {
    	trace( str );	
    }
    
    // Event Handlers
    
    private static function onResize() : Void
    {
		__mpButtons._x = __map._x + __map._width - __mpButtons._width - 10;    
	}
    
}
