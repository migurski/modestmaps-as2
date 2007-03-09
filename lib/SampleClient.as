import mx.utils.Delegate;
import com.stamen.twisted.Reactor;
import com.modestmaps.Map;
import com.modestmaps.core.TileGrid;
import com.modestmaps.mapproviders.MapProviders;
import com.modestmaps.mapproviders.MapProviderFactory;
import com.modestmaps.geo.Location;

class SampleClient
{
	private static var __map:Map;
	private static var __mapButtons:MovieClip;
	private static var __status:TextField;
	
    public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, null, 50);

        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth()));
        __map.init(Stage.width-256, Stage.height-256, true, MapProviderFactory.getInstance().getMapProvider(MapProviders.GOOGLE_ROAD));
        __map.addEventListener(Map.EVENT_ZOOMED_BY, onZoomed);
        __map.addEventListener(Map.EVENT_STOP_ZOOMING, onStopZoom);
        __map.addEventListener(Map.EVENT_PANNED_BY, onPanned);
        __map.addEventListener(Map.EVENT_STOP_PANNING, onStopPan);
        __map.addEventListener(Map.EVENT_RESIZED_TO, onResized);
        
        __status = clip.createTextField('status', clip.getNextHighestDepth(), 0, 0, 600, 100);
        __status.selectable = false;
        __status.textColor = 0x000000;
        __status.text = '...';
        __status._height = __status.textHeight + 2;

        var extent:/*Location*/Array = [new Location(37.829853, -122.514725),
                                        new Location(37.700121, -122.212601)];
        
        __map.setExtent(extent);

        //Reactor.callLater(2000, Delegate.create(__map, __map.setNewCenter), new Location(37.811411, -122.360916), 14);
        
        __map.addEventListener(Map.EVENT_MARKER_ENTERS, onMarkerEnters);
        __map.addEventListener(Map.EVENT_MARKER_LEAVES, onMarkerLeaves);
        
        __map.putMarker('Rochdale', new Location(37.865571, -122.259679));
        __map.putMarker('Parker Ave.', new Location(37.780492, -122.453731));
        __map.putMarker('Pepper Dr.', new Location(37.623443, -122.426577));
        __map.putMarker('3rd St.', new Location(37.779297, -122.392877));
        __map.putMarker('Divisadero St.', new Location(37.771919, -122.437413));
        __map.putMarker('Market St.', new Location(37.812734, -122.280064));
        __map.putMarker('17th St.', new Location(37.804274, -122.262940));
        
        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(SampleClient);
        onResize();
        
        var buttons:Array = new Array();
        
        buttons.push(makeButton(clip, 'plus', 'zoom in', Delegate.create(__map, __map.zoomIn)));
        buttons.push(makeButton(clip, 'minus', 'zoom out', Delegate.create(__map, __map.zoomOut)));
        buttons.push(makeButton(clip, 'left', 'pan left', Delegate.create(__map, __map.panLeft)));
        buttons.push(makeButton(clip, 'up', 'pan up', Delegate.create(__map, __map.panUp)));
        buttons.push(makeButton(clip, 'down', 'pan down', Delegate.create(__map, __map.panDown)));
        buttons.push(makeButton(clip, 'left', 'pan right', Delegate.create(__map, __map.panRight)));
        buttons.push(makeButton(clip, 'clear', 'clear log', Delegate.create(__map.grid, __map.grid.clearLog)));

		var nextX:Number = __map._x;
		var nextY:Number = __map._y - buttons[0]['label']._height - 10;
		
		for(var i:Number = 0; i < buttons.length; i++) {
			buttons[i]._x = nextX;
			buttons[i]._y = nextY;
			nextX += buttons[i]['label']._width + 5;	
		}

		// mapProvider buttons

		__mapButtons = clip.createEmptyMovieClip("mpButtons", clip.getNextHighestDepth());

        buttons = new Array();
		
		buttons.push(makeButton(__mapButtons, 'MICROSOFT_ROAD', 'ms road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'MICROSOFT_AERIAL', 'ms aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'MICROSOFT_HYBRID', 'ms hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		buttons.push(makeButton(__mapButtons, 'GOOGLE_ROAD', 'google road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'GOOGLE_AERIAL', 'google aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'GOOGLE_HYBRID', 'google hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		buttons.push(makeButton(__mapButtons, 'YAHOO_ROAD', 'yahoo road', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'YAHOO_AERIAL', 'yahoo aerial', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'YAHOO_HYBRID', 'yahoo hybrid', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

        buttons.push(makeButton(__mapButtons, 'BLUE_MARBLE', 'blue marble', Delegate.create(SampleClient, SampleClient.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'OPEN_STREET_MAP', 'open street map', Delegate.create(SampleClient, SampleClient.switchMapProvider)));

		nextY = 0;
		
		for(var i:Number = 0; i < buttons.length; i++) {
			buttons[i]._y = nextY;
			nextY += buttons[i]['label']._height + 5;
			buttons[i]._alpha = 60;
		}

        _root.createEmptyMovieClip('marks', _root.getNextHighestDepth());
    }
    
    
    private static function switchMapProvider(button:MovieClip):Void
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
        	action.apply(SampleClient, [button]);
        };
        
        return button;
    }
    
    public static function output(str:String):Void
    {
    	trace(str);	
    }
    
    // Event Handlers
    
    private static function onResize():Void
    {
        __map._x = __map._y = 50;
        __map.setSize(Stage.width - 2*__map._x, Stage.height - 2*__map._y);

		__mapButtons._x = __map._x + (Stage.width - 2*__map._x) - __mapButtons._width - 10;
		__mapButtons._y = __map._y + 10;

		__status._width = __map.getSize()[0];
		__status._x = __map._x + 2;
		__status._y = __map._y + __map.getSize()[1];
	}
    
    private static function onPanned(event:Object):Void
    {
        __status.text = 'Panned by '+event.delta.toString()+', top left: '+__map.getExtent()[0].toString()+', bottom right: '+__map.getExtent()[3].toString();
    }
    
    private static function onStopPan(event:Object):Void
    {
        __status.text = 'Stopped panning, top left: '+__map.getExtent()[0].toString()+', center: '+__map.getCenterZoom()[0].toString()+', bottom right: '+__map.getExtent()[3].toString()+', zoom: '+__map.getCenterZoom()[1];
    }
    
    private static function onZoomed(event:Object):Void
    {
        __status.text = 'Zoomed by '+event.delta.toString()+', top left: '+__map.getExtent()[0].toString()+', bottom right: '+__map.getExtent()[3].toString();
    }
    
    private static function onStopZoom(event:Object):Void
    {
        __status.text = 'Stopped zooming, top left: '+__map.getExtent()[0].toString()+', center: '+__map.getCenterZoom()[0].toString()+', bottom right: '+__map.getExtent()[3].toString()+', zoom: '+__map.getCenterZoom()[1];
    }
    
    private static function onResized(event:Object):Void
    {
        __status.text = 'Resized to: '+event.width+' x '+event.height;
    }
    
    private static function onMarkerEnters(event:Object):Void
    {
        __map.grid.log('+ '+event.id+' =)');
    }
    
    private static function onMarkerLeaves(event:Object):Void
    {
        __map.grid.log('- '+event.id+' =(');
    }
}
