/*
 * $Id$
 */

import com.modestmaps.geo.Location;

class com.modestmaps.core.MapExtent
{
    public var north:Number;
    public var south:Number;
    public var east:Number;
    public var west:Number;
    
    public function MapExtent(n:Number, s:Number, e:Number, w:Number)
    {
        north = n;
        south = s;
        east = e;
        west = w;
    }
    
    public function get northWest():Location
    {
        return new Location(north, west);
    }
    
    public function get southWest():Location
    {
        return new Location(south, west);
    }
    
    public function get northEast():Location
    {
        return new Location(north, east);
    }
    
    public function get southEast():Location
    {
        return new Location(south, east);
    }
    
    public function set northWest(NW:Location):Void
    {
        north = NW.lat;
        west = NW.lon;
    }
    
    public function set southWest(SW:Location):Void
    {
        south = SW.lat;
        west = SW.lon;
    }
    
    public function set northEast(NE:Location):Void
    {
        north = NE.lat;
        east = NE.lon;
    }
    
    public function set southEast(SE:Location):Void
    {
        south = SE.lat;
        east = SE.lon;
    }
}
