/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */
 
import flash.geom.Point;
import com.modestmaps.Map;
import com.modestmaps.geo.Location;
import com.modestmaps.core.MapExtent;

class com.modestmaps.core.MarkerClip
extends MovieClip
{
    private var __map:Map;
    private var __starting:Point;
    private var __names:Object;
    private var __locations:Object;
    private var __eventsObserved:Boolean;

    public static var symbolName:String = '__Packages.com.modestmaps.core.MarkerClip';
    public static var symbolOwner:Function = MarkerClip;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
    public function MarkerClip()
    {
        __names = {};
        __locations = {};
        __eventsObserved = false;
    }
    
    public function attachMarker(id:String, location:Location, symbol:String):MovieClip
    {
        if(!__eventsObserved) {
            __eventsObserved = true;

            __map.addEventObserver(this, Map.EVENT_MARKER_ENTERS, "onMapMarkerEnters");
            __map.addEventObserver(this, Map.EVENT_MARKER_LEAVES, "onMapMarkerLeaves");
            __map.addEventObserver(this, Map.EVENT_START_ZOOMING, "onMapStartZooming");
            __map.addEventObserver(this, Map.EVENT_STOP_ZOOMING, "onMapStopZooming");
            __map.addEventObserver(this, Map.EVENT_ZOOMED_BY, "onMapZoomedBy");
            __map.addEventObserver(this, Map.EVENT_START_PANNING, "onMapStartPanning");
            __map.addEventObserver(this, Map.EVENT_STOP_PANNING, "onMapStopPanning");
            __map.addEventObserver(this, Map.EVENT_PANNED_BY, "onMapPannedBy");
            __map.addEventObserver(this, Map.EVENT_RESIZED_TO, "onMapResizedTo");
            __map.addEventObserver(this, Map.EVENT_EXTENT_CHANGED, "onMapExtentChanged");
        }
        
        var clip:MovieClip = attachMovie(symbol, 'marker'+getNextHighestDepth().toString(), getNextHighestDepth());

        __names[id] = clip._name;
        __locations[id] = location;
        
        var point:Point = __map.locationPoint(location, this);
        clip._x = point.x;
        clip._y = point.y;
        
        return clip;
    }
    
    public function getMarker(id:String):MovieClip
    {
        if(__names[id] && this[__names[id]])
            return this[__names[id]];
            
        return undefined;
    }
    
    public function removeMarker(id:String):Void
    {
        if(__names[id]) {
            this[__names[id]].removeMovieClip();
            delete __names[id];
            delete __locations[id];
        }
    }
    
    public function setMap(map:Map):Void
    {
        __map = map;
    }
    
    private function updateClips():Void
    {
        for(var id:String in __names)
            if(this[__names[id]] && this[__names[id]]._visible)
                updateClip(id);
    }
    
    private function updateClip(id:String):Void
    {
        var location:Location = __locations[id];
        var name:String = __names[id];
        var clip:MovieClip = this[name];
        
        if(name && clip && location) {
            var point:Point = __map.locationPoint(location, this);
    
            clip._x = point.x;
            clip._y = point.y;
        }
    }
    
    public function onMapMarkerEnters(id:String, location:Location):Void
    {
        var name:String = __names[id];
        
        if(this[name]) {
            this[name]._visible = true;
            updateClip(id);
        }
    }
    
    public function onMapMarkerLeaves(id:String, location:Location):Void
    {
        var name:String = __names[id];
        
        if(this[name]) {
            this[name]._visible = false;
            updateClip(id);
        }
    }
    
    public function onMapStartZooming(level:Number):Void
    {
        updateClips();
    }
    
    public function onMapZoomedBy(delta:Number):Void
    {
        updateClips();
    }
    
    public function onMapStopZooming(level:Number):Void
    {
        updateClips();
    }
    
    public function onMapStartPanning():Void
    {
        __starting = new Point(_x, _y);
    }
    
    public function onMapPannedBy(delta:Point):Void
    {
        _x = __starting.x + delta.x;
        _y = __starting.y + delta.y;
    }
    
    public function onMapStopPanning():Void
    {
        this._x = __starting.x;
        this._y = __starting.y;

        updateClips();
    }
    
    public function onMapResizedTo(width:Number, height:Number):Void
    {
        _x = width/2;
        _y = height/2;

        updateClips();
    }
    
    public function onMapExtentChanged(extent:MapExtent):Void
    {
        updateClips();
    }
}
