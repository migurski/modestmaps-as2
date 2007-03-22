/*
 * vim:et sts=4 sw=4 cindent:
 */

import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Marker;
import com.modestmaps.core.Tile;
import com.modestmaps.core.TileGrid;

class com.modestmaps.core.MarkerSet
{
    private var __lastZoom:Number;
    
    // markers hashed by id
    private var __markers:Object;
    
    // marker lists hashed by containing tile id
    private var __tileMarkers:Object;
    
    // tile id's hashed by marker id
    private var __markerTiles:Object;
    
    // for finding which is visible
    private var __grid:TileGrid;

    function MarkerSet(grid:TileGrid)
    {
        __grid = grid;
        initializeIndex();
    }
    
    /**
     * Put a marker on the grid.
     */
    public function put(marker:Marker):Void
    {
        __markers[marker.id] = marker;
        indexMarker(marker.id);
    }
    
    /**
     * Remove a marker added via put().
     */
    public function remove(marker:Marker):Void
    {
        unIndexMarker(marker.id);
        delete __markers[marker.id];
    }

    public function initializeIndex():Void
    {
        __lastZoom = 0;

        __markers = {};
        __tileMarkers = {};
        __markerTiles = {};
    }

    public function indexAtZoom(level:Number):Void
    {
        __lastZoom = level;
    
        for(var markerId:String in __markers)
            indexMarker(markerId);
    }

   /**
    * Add a new marker to the internal index.
    */
    private function indexMarker(markerId:String):Void
    {
        var tileKey:String = __markers[markerId].coord.zoomTo(__lastZoom).container().toString();
        
        if(__tileMarkers[tileKey] == undefined)
            __tileMarkers[tileKey] = {};
            
        __tileMarkers[tileKey][markerId] = true;
        
        if(__markerTiles[markerId] == undefined)
            __markerTiles[markerId] = {};
            
        __markerTiles[markerId][tileKey] = true;
        
        //trace('Marker '+markerId+' in '+tileKey);
    }

    /**
     * Remove a marker from the internal index.
     */
    private function unIndexMarker(markerId:String):Void
    {
        for(var tileKey:String in __markerTiles[markerId])
            delete __tileMarkers[tileKey][markerId];

        delete __markerTiles[markerId];
    }

   /**
    * Fetch a single marker by ID.
    */
    public function getMarker(id:String):Marker
    {
        return __markers[id];
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
            sourceCoord = __grid.getMapProvider().sourceCoordinate(tiles[i].coord);
        
            if(__tileMarkers[sourceCoord.toString()] != undefined)
                for(var markerId:String in __tileMarkers[sourceCoord.toString()]) {
                    ids.push(markerId);
                    touched.push(__markers[markerId]);
                }
        }
        
        //trace('Touched markers: '+ids.toString());
        return touched;
    }
}
