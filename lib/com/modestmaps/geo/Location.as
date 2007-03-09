class com.modestmaps.geo.Location
{
    // Latitude, longitude, _IN DEGREES_.
    var lat:Number, lon:Number;

    function Location(lat:Number, lon:Number)
    {
        this.lat = lat;
        this.lon = lon;
    }
    
    public function toString():String
    {
        var roundLat:Number = Math.round(lat * 10000) / 10000;
        var roundLon:Number = Math.round(lon * 10000) / 10000;

        return '('+roundLat+','+roundLon+')';
    }
}
