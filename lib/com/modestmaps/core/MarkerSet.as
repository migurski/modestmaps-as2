import mx.utils.Delegate;
import com.stamen.twisted.*;

import com.modestmaps.core.Tile;
import com.modestmaps.core.Marker;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.MarkerSet
{
    private var lastZoom:Number;
    
    // markers hashed by name
    private var markers:Object;
    
    // marker lists hashed by containing tile id
    private var tileMarkers:Object;
    
    /*
    // tile id's hashed by marker name
    private var markerTiles:Object;
    */
    
    // for use of TileGrid.log()
    private var grid:TileGrid;

    function MarkerSet(grid:TileGrid)
    {
        this.grid = grid;
        initializeIndex();
    }
    
    public function put(name:String, marker:Marker):Void
    {
        markers[name] = marker;
        indexMarker(name);
    }
    
    public function initializeIndex():Void
    {
        lastZoom = 0;

        markers = {};
        tileMarkers = {};
        /*markerTiles = {};*/
    }

    public function indexAtZoom(level:Number):Void
    {
        lastZoom = level;
    
        for(var markerName:String in markers)
            indexMarker(markerName);
    }

    private function indexMarker(markerName:String):Void
    {
        var tileKey:String = markers[markerName].coord.zoomTo(lastZoom).container().toString();
        
        if(tileMarkers[tileKey] == undefined)
            tileMarkers[tileKey] = {};
            
        tileMarkers[tileKey][markerName] = true;
        
        /*
        if(markerTiles[markerName] == undefined)
            markerTiles[markerName] = {};
            
        markerTiles[markerName][tileKey] = true;
        */
        
        grid.log('Marker '+markerName+' in '+tileKey);
    }
    
    public function overlapping(tiles:/*Tile*/Array):/*Marker*/Array
    {
        var names:Array = [];
        var touched:/*Marker*/Array = [];
        
        for(var i:Number = 0; i < tiles.length; i += 1)
            if(tileMarkers[tiles[i].coord.toString()] != undefined)
                for(var markerName:String in tileMarkers[tiles[i].coord.toString()]) {
                    names.push(markerName);
                    touched.push(markers[markerName]);
                }
        
        grid.log('Touched markers: '+names.toString());
        return touched;
    }
}
