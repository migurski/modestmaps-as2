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
        return '(' + lat + ',' + lon + ')';
    }
}
