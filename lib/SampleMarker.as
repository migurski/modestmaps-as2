class SampleMarker
extends MovieClip
{
    public static var symbolName:String = '__Packages.SampleMarker';
    public static var symbolOwner:Function = SampleMarker;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);
    
    public function SampleMarker()
    {
        moveTo(-6, -6);
        lineStyle(1, 0xFFFFFF, 100);
        lineTo(-6, 6);
        lineTo(6, 6);
        lineTo(6, -6);
        lineTo(-6, -6);
        endFill();

        moveTo(-5, -5);
        lineStyle(1, 0x000000, 100);
        lineTo(-5, 5);
        lineTo(5, 5);
        lineTo(5, -5);
        lineTo(-5, -5);
        endFill();
    }
}