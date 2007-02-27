import mx.utils.Delegate;
import com.stamen.twisted.*;

import com.modestmaps.core.Tile;
import com.modestmaps.core.Marker;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.MarkerSet
{
    private var lastZoom:Number;
    
    // markers hashed by id
    private var markers:Object;
    
    // marker lists hashed by containing tile id
    private var tileMarkers:Object;
    
    /*
    // tile id's hashed by marker id
    private var markerTiles:Object;
    */
    
    // for use of TileGrid.log()
    private var grid:TileGrid;

    function MarkerSet(grid:TileGrid)
    {
        this.grid = grid;
        initializeIndex();
    }
    
    public function put(marker:Marker):Void
    {
        markers[marker.id] = marker;
        indexMarker(marker.id);
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
    
        for(var markerId:String in markers)
            indexMarker(markerId);
    }

   /**
    * Add a new marker to the internal index.
    */
    private function indexMarker(markerId:String):Void
    {
        var tileKey:String = markers[markerId].coord.zoomTo(lastZoom).container().toString();
        
        if(tileMarkers[tileKey] == undefined)
            tileMarkers[tileKey] = {};
            
        tileMarkers[tileKey][markerId] = true;
        
        /*
        if(markerTiles[markerId] == undefined)
            markerTiles[markerId] = {};
            
        markerTiles[markerId][tileKey] = true;
        */
        
        //grid.log('Marker '+markerId+' in '+tileKey);
    }

   /**
    * Fetch a single marker by ID.
    */
    public function getMarker(id:String):Marker
    {
        return markers[id];
    }

   /**
    * Fetch a list of markers within currently-visible tiles.
    */
    public function overlapping(tiles:/*Tile*/Array):/*Marker*/Array
    {
        var ids:Array = [];
        var touched:/*Marker*/Array = [];
        var sourceCoord:Coordinate;
        
        for(var i:Number = 0; i < tiles.length; i += 1) {
            sourceCoord = grid.mapProvider.sourceCoordinate(tiles[i].coord);
        
            if(tileMarkers[sourceCoord.toString()] != undefined)
                for(var markerId:String in tileMarkers[sourceCoord.toString()]) {
                    ids.push(markerId);
                    touched.push(markers[markerId]);
                }
        }
        
        //grid.log('Touched markers: '+ids.toString());
        return touched;
    }
}
