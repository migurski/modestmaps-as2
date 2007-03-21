/*
 * vim:et sts=4 sw=4 cindent:
 */

import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Marker;
import com.modestmaps.core.Tile;
import com.modestmaps.core.TileGrid;

class com.modestmaps.core.MarkerSet
{
    private var lastZoom:Number;
    
    // markers hashed by id
    private var markers:Object;
    
    // marker lists hashed by containing tile id
    private var tileMarkers:Object;
    
    // tile id's hashed by marker id
    private var markerTiles:Object;
    
    // for finding which is visible
    private var grid:TileGrid;

    function MarkerSet(grid:TileGrid)
    {
        this.grid = grid;
        initializeIndex();
    }
    
    /**
     * Put a marker on the grid.
     */
    public function put(marker:Marker):Void
    {
        markers[marker.id] = marker;
        indexMarker(marker.id);
    }
    
    /**
     * Remove a marker added via put().
     */
    public function remove(marker:Marker):Void
    {
        unIndexMarker(marker.id);
        delete markers[marker.id];
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
        
        if(markerTiles[markerId] == undefined)
            markerTiles[markerId] = {};
            
        markerTiles[markerId][tileKey] = true;
        
        //trace('Marker '+markerId+' in '+tileKey);
    }

    /**
     * Remove a marker from the internal index.
     */
    private function unIndexMarker(markerId:String):Void
    {
        for (var tileKey:String in markerTiles[markerId])
        {
            delete tileMarkers[tileKey][markerId];
        }
        delete markerTiles[markerId];
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
        
        //trace('Touched markers: '+ids.toString());
        return touched;
    }
}
