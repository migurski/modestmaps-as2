import SampleMarker;
import com.bigspaceship.utils.Delegate;
import com.modestmaps.core.MapExtent;
import com.modestmaps.geo.Location;
import com.modestmaps.Map;
import com.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider;
import com.stamen.twisted.Reactor;
import flash.geom.Point;

class SampleClient1
{
	private static var __map:Map;
	private static var __navButtons:MovieClip;
	private static var __mapButtons:MovieClip;
	private static var __status:TextField;
	
    public static function main(clip:MovieClip):Void
    {
        Reactor.run(clip, 50);

        __map = Map(clip.attachMovie(Map.symbolName, 'map', clip.getNextHighestDepth()));
        __map.init(Stage.width-256, Stage.height-256, true, new MicrosoftRoadMapProvider());
        __map.addEventObserver(SampleClient1, Map.EVENT_ZOOMED_BY, "onZoomed");
        __map.addEventObserver(SampleClient1, Map.EVENT_STOP_ZOOMING, "onStopZoom");
        __map.addEventObserver(SampleClient1, Map.EVENT_PANNED_BY, "onPanned");
        __map.addEventObserver(SampleClient1, Map.EVENT_STOP_PANNING, "onStopPan");
        __map.addEventObserver(SampleClient1, Map.EVENT_RESIZED_TO, "onResized");
        
        __status = clip.createTextField('status', clip.getNextHighestDepth(), 0, 0, 600, 100);
        __status.selectable = false;
        __status.textColor = 0x000000;
        __status.text = '...';
        __status._height = __status.textHeight + 2;

        __map.setExtent(new MapExtent(37.829853, 37.700121, -122.212601, -122.514725));

        //Reactor.callLater(2000, Delegate.create(__map, __map.setNewCenter), new Location(37.811411, -122.360916), 14);
        
        __map.addEventObserver(SampleClient1, Map.EVENT_MARKER_ENTERS, "onMarkerEnters");
        __map.addEventObserver(SampleClient1, Map.EVENT_MARKER_LEAVES, "onMarkerLeaves");
        
        // Add a bunch of markers by attaching clips to the __map.markers movieclip:
        __map.putMarker('Rochdale',       new Location(37.865571, -122.259679), SampleMarker.symbolName);
        __map.putMarker('Parker Ave.',    new Location(37.780492, -122.453731), SampleMarker.symbolName);
        __map.putMarker('Pepper Dr.',     new Location(37.623443, -122.426577), SampleMarker.symbolName);
        __map.putMarker('3rd St.',        new Location(37.779297, -122.392877), SampleMarker.symbolName);
        __map.putMarker('Divisadero St.', new Location(37.771919, -122.437413), SampleMarker.symbolName);
        __map.putMarker('Market St.',     new Location(37.812734, -122.280064), SampleMarker.symbolName);
        __map.putMarker('17th St.',       new Location(37.804274, -122.262940), SampleMarker.symbolName);

        Stage.scaleMode = 'noScale';
        Stage.align = 'TL';
        Stage.addListener(SampleClient1);
        
        Reactor.callNextFrame(onResize);
        
        var buttons:Array = new Array();
        
        __navButtons = clip.createEmptyMovieClip("navButtons", clip.getNextHighestDepth());
        
        buttons.push(makeButton(__navButtons, 'plus', 'zoom in', Delegate.create(__map, __map.zoomIn)));
        buttons.push(makeButton(__navButtons, 'minus', 'zoom out', Delegate.create(__map, __map.zoomOut)));
        buttons.push(makeButton(__navButtons, 'left', 'pan left', Delegate.create(__map, __map.panLeft)));
        buttons.push(makeButton(__navButtons, 'up', 'pan up', Delegate.create(__map, __map.panUp)));
        buttons.push(makeButton(__navButtons, 'down', 'pan down', Delegate.create(__map, __map.panDown)));
        buttons.push(makeButton(__navButtons, 'left', 'pan right', Delegate.create(__map, __map.panRight)));

		//__navButtons._x = __navButtons._y = 50;
		
		var nextX:Number = 0;
		
		for(var i:Number = 0; i < buttons.length; i++) {
			buttons[i]._x = nextX;
			nextX += buttons[i]['label']._width + 5;	
		}

		// mapProvider buttons

		__mapButtons = clip.createEmptyMovieClip("mapButtons", clip.getNextHighestDepth());

        buttons = new Array();
		
		buttons.push(makeButton(__mapButtons, 'MICROSOFT_ROAD', 'ms road', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'MICROSOFT_AERIAL', 'ms aerial', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'MICROSOFT_HYBRID', 'ms hybrid', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));

		buttons.push(makeButton(__mapButtons, 'GOOGLE_ROAD', 'google road', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'GOOGLE_AERIAL', 'google aerial', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'GOOGLE_HYBRID', 'google hybrid', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));

		buttons.push(makeButton(__mapButtons, 'YAHOO_ROAD', 'yahoo road', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'YAHOO_AERIAL', 'yahoo aerial', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'YAHOO_HYBRID', 'yahoo hybrid', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));

        buttons.push(makeButton(__mapButtons, 'BLUE_MARBLE', 'blue marble', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));
        buttons.push(makeButton(__mapButtons, 'OPEN_STREET_MAP', 'open street map', Delegate.create(SampleClient1, SampleClient1.switchMapProvider)));

		var nextY : Number = 0;
		
		for(var i:Number = 0; i < buttons.length; i++) {
			buttons[i]._y = nextY;
			nextY += buttons[i]['label']._height + 5;
			buttons[i]._alpha = 60;
		}

        _root.createEmptyMovieClip('marks', _root.getNextHighestDepth());
    }
    
    
    private static function switchMapProvider(button:MovieClip):Void
    {
        switch(button._name) {
			case 'VANILLA':
				__map.setMapProvider(new com.modestmaps.mapproviders.VanillaMapProvider());
				break;

			case 'BLUE_MARBLE':
				__map.setMapProvider(new com.modestmaps.mapproviders.BlueMarbleMapProvider());
				break;

			case 'OPEN_STREET_MAP':
				__map.setMapProvider(new com.modestmaps.mapproviders.OpenStreetMapProvider());
				break;

			case 'MICROSOFT_ROAD':
				__map.setMapProvider(new com.modestmaps.mapproviders.microsoft.MicrosoftRoadMapProvider());
				break;

			case 'MICROSOFT_AERIAL':
				__map.setMapProvider(new com.modestmaps.mapproviders.microsoft.MicrosoftAerialMapProvider());
				break;

			case 'MICROSOFT_HYBRID':
				__map.setMapProvider(new com.modestmaps.mapproviders.microsoft.MicrosoftHybridMapProvider());
				break;
				
			case 'GOOGLE_ROAD':
				__map.setMapProvider(new com.modestmaps.mapproviders.google.GoogleRoadMapProvider());
				break;

			case 'GOOGLE_AERIAL':
				__map.setMapProvider(new com.modestmaps.mapproviders.google.GoogleAerialMapProvider());
				break;

			case 'GOOGLE_HYBRID':
				__map.setMapProvider(new com.modestmaps.mapproviders.google.GoogleHybridMapProvider());
				break;

			case 'YAHOO_ROAD':
				__map.setMapProvider(new com.modestmaps.mapproviders.yahoo.YahooRoadMapProvider());
				break;

			case 'YAHOO_AERIAL':
				__map.setMapProvider(new com.modestmaps.mapproviders.yahoo.YahooAerialMapProvider());
				break;

			case 'YAHOO_HYBRID':
				__map.setMapProvider(new com.modestmaps.mapproviders.yahoo.YahooHybridMapProvider());
				break;
        }
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
        	action.apply(SampleClient1, [button]);
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

		__navButtons._x = __map._x;
        __navButtons._y = __map._y - __navButtons._height - 10;

		__mapButtons._x = __map._x + (Stage.width - 2*__map._x) - __mapButtons._width - 10;
		__mapButtons._y = __map._y + 10;

		__status._width = __map.getSize()[0];
		__status._x = __map._x + 2;
		__status._y = __map._y + __map.getSize()[1];
	}
    
    private static function onPanned( delta : Point ):Void
    {
        __status.text = 'Panned by '+ delta.toString() +', top left: '+__map.getExtent().northWest.toString()+', bottom right: '+__map.getExtent().southEast.toString();
    }
    
    private static function onStopPan():Void
    {
        __status.text = 'Stopped panning, top left: '+__map.getExtent().northWest.toString()+', center: '+__map.getCenterZoom()[0].toString()+', bottom right: '+__map.getExtent().southEast.toString()+', zoom: '+__map.getCenterZoom()[1];
    }
    
    private static function onZoomed( delta : Number ):Void
    {
        __status.text = 'Zoomed by '+delta.toString()+', top left: '+__map.getExtent().northWest.toString()+', bottom right: '+__map.getExtent().southEast.toString();
    }
    
    private static function onStopZoom( zoomLevel : Number ):Void
    {
        __status.text = 'Stopped zooming, top left: '+__map.getExtent().northWest.toString()+', center: '+__map.getCenterZoom()[0].toString()+', bottom right: '+__map.getExtent().southEast.toString()+', zoom: '+__map.getCenterZoom()[1];
    }
    
    private static function onResized( width : Number, height : Number ):Void
    {
        __status.text = 'Resized to: '+ width +' x '+ height;
    }
    
    private static function onMarkerEnters( id : String, location : Location ):Void
    {
        trace('+ '+id+' =)');
    }
    
    private static function onMarkerLeaves( id : String, location : Location ):Void
    {
        trace('- '+id+' =(');
    }
}
