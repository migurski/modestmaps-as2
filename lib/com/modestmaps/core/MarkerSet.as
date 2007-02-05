import mx.utils.Delegate;
import com.stamen.twisted.*;

import com.modestmaps.core.Marker;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.Coordinate;

class com.modestmaps.core.MarkerSet
{
    private var set:Object;
    private var grid:TileGrid;

    function MarkerSet(grid:TileGrid)
    {
        this.grid = grid;
        set = {};
    }
    
    public function put(name:String, marker:Marker):Void
    {
        set[name] = marker;
    }
    
    public function remove(name:String):Void
    {
        delete set[name];
    }

    private function inBounds(topLeft:Coordinate, bottomRight:Coordinate):/*Marker*/Array
    {
        var coord:Coordinate;
        var contained:/*Marker*/Array = [];
        
        for(var name:String in set) {
            coord = set[name].coord.zoomTo(topLeft.zoom);
            
            if(coord.row >= topLeft.row && coord.column >= topLeft.column && coord.row <= bottomRight.row && coord.column <= bottomRight.column)
                contained.push(set[name]);
        }
        
        return contained;
    }

    public function updateActive(topLeft:Coordinate, bottomRight:Coordinate):Void
    {
        grid.log('Active markers: '+inBounds(topLeft, bottomRight).length);
    }

    public function updateVisible(topLeft:Coordinate, bottomRight:Coordinate):Void
    {
        grid.log('Visible markers: '+inBounds(topLeft, bottomRight).length);
    }
}
