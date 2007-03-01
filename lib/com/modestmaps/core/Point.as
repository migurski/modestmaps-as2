class com.modestmaps.core.Point
{
    var x:Number, y:Number;

    function Point(x:Number, y:Number)
    {
        this.x = x;
        this.y = y;
    }
    
    public function copy():Point
    {
        return new Point(x, y);
    }
    
    public function toString():String
    {
        return '(' + x + ',' + y + ')';
    }
}
