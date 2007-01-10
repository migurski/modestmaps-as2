import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;

class com.modestmaps.core.Tile extends MovieClip
{
    public var grid:TileGrid;

    public var row:Number = 0;
    public var column:Number = 0;
    public var zoom:Number = 0;

    public var width:Number;
    public var height:Number;
    
    private var label:TextField;
    public var origin:Boolean;

    public static var symbolName:String = '__Packages.com.modestmaps.core.Tile';
    public static var symbolOwner:Function = Tile;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function Tile()
    {
        redraw();
    }
    
    public function center():Point
    {
        return new Point(_x + width / 2, _y + height / 2);
    }
    
    public function zoomOut():Void
    {
        zoom += 1;
        column = Math.floor(column / 2);
        row = Math.floor(row / 2);
        redraw();
    }

    public function zoomInTopLeft():Void
    {
        zoom -= 1;
        column *= 2;
        row *= 2;
        redraw();
    }

    public function zoomInTopRight():Void
    {
        zoom -= 1;
        column *= 2;
        column += 1;
        row *= 2;
        redraw();
    }

    public function zoomInBottomLeft():Void
    {
        zoom -= 1;
        column *= 2;
        row *= 2;
        row += 1;
        redraw();
    }

    public function zoomInBottomRight():Void
    {
        zoom -= 1;
        column *= 2;
        column += 1;
        row *= 2;
        row += 1;
        redraw();
    }

    public function panUp(distance:Number):Void
    {
        row -= (distance ? distance : 1);
        redraw();
    }

    public function panRight(distance:Number):Void
    {
        column += (distance ? distance : 1);
        redraw();
    }

    public function panDown(distance:Number):Void
    {
        row += (distance ? distance : 1);
        redraw();
    }

    public function panLeft(distance:Number):Void
    {
        column -= (distance ? distance : 1);
        redraw();
    }

    public function toString():String
    {
        return row + ', ' + column + ' @' + zoom;
    }

    public function redraw():Void
    {
        clear();
        moveTo(0, 0);
        lineStyle(0, 0x0099FF, 100);
        beginFill(0x000000, 20);
        lineTo(0, height);
        lineTo(width, height);
        lineTo(width, 0);
        lineTo(0, 0);
        endFill();
        
        createTextField('label', 1, width/4, height/2, width/1.33, height/2);
        label.selectable = false;

        if(origin) {
            label.text = '! ' + toString();
        } else {
            label.text = toString();
        }
    }
}