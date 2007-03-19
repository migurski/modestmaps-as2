import org.casaframework.event.DispatchableInterface;
import org.casaframework.movieclip.DispatchableMovieClip;

import com.bigspaceship.utils.Delegate;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Point;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.TilePaintCall;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.stamen.twisted.Reactor;

class com.modestmaps.core.Tile 
extends DispatchableMovieClip
implements DispatchableInterface
{
	public static var EVENT_PAINT_COMPLETE : String = "onPaintComplete";
	
    public var grid:TileGrid;

    private var __coord : Coordinate;
    
    public var width:Number;
    public var height:Number;
    
    private var label:TextField;

	// Keeps track of all clips awaiting painting.
	private var __displayClips : Array;
	
	private var __paintCall : TilePaintCall;
	
	private var __active:Boolean;

    public static var symbolName:String = '__Packages.com.modestmaps.core.Tile';
    public static var symbolOwner:Function = Tile;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function Tile()
    {
    	__active = true;
    	__displayClips = new Array();  	
    }
   
    public function get coord() : Coordinate
    {
    	return __coord;	
    }
    public function set coord( coord : Coordinate ) : Void
    {
    	__coord = coord;
    	redraw();	
    }
    
    public function isActive():Boolean
    {
        return __active;
    }
        
    public function expire():Void
    {
        cancelDraw();
        __active = false;
    }
        
    public function center():Point
    {
        return new Point(_x + width / 2, _y + height / 2);
    }
    
    public function zoomOut():Void
    {
        coord = new Coordinate(Math.floor(coord.row / 2), Math.floor(coord.column / 2), coord.zoom + 1);
    }

    public function zoomInTopLeft():Void
    {
        coord = new Coordinate(coord.row * 2, coord.column * 2, coord.zoom - 1);
    }

    public function zoomInTopRight():Void
    {
        coord = new Coordinate(coord.row * 2, coord.column * 2 + 1, coord.zoom - 1);
    }

    public function zoomInBottomLeft():Void
    {
        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2, coord.zoom - 1);
    }

    public function zoomInBottomRight():Void
    {
        coord = new Coordinate(coord.row * 2 + 1, coord.column * 2 + 1, coord.zoom - 1);
    }

    public function panUp(distance:Number):Void
    {
        coord = coord.up(distance);
    }

    public function panRight(distance:Number):Void
    {
        coord = coord.right(distance);
    }

    public function panDown(distance:Number):Void
    {
        coord = coord.down(distance);
    }

    public function panLeft(distance:Number):Void
    {
        coord = coord.left(distance);
    }

    public function toString():String
    {
        return id();
    }

    public function id():String
    {
        return 'Tile' + coord.toString();
    }

    public function redraw():Void
    {
    	// any need to repeat ourselves?
    	if(__paintCall && __paintCall.match(grid.mapProvider, coord.copy()) && __paintCall.pending())
            return;
    	
        // are we even allowed to paint ourselves?
        if(!grid.paintingAllowed())
            return;
		
    	// cancel existing call, if any...
    	if(__paintCall)
    	    __paintCall.cancel();
    	
   		// hide all other displayClips to avoid weird "repaint" effect
   		var count:Number = __displayClips.length;
   		while(count--)
   			__displayClips[count].clip._visible = false;
   			
    	// fire up a new call for the next frame...
    	__paintCall = new TilePaintCall(Reactor.callNextFrame(Delegate.create(this, this.paint), grid.mapProvider, coord.copy()),
    	                                grid.mapProvider, coord.copy());
    }
    
    public function paint(mapProvider:IMapProvider, tileCoord:Coordinate):Void
    {
    	//grid.log("Painting tile: " + tileCoord.toString());
    	
    	// set up the proper clip to paint here
   		DispatchableInterface(grid.mapProvider).addEventObserver( this, AbstractMapProvider.EVENT_PAINT_COMPLETE, "onPaintComplete" );
    	
    	var clipId : Number = this.getNextHighestDepth();
    	var clip : MovieClip = this.createEmptyMovieClip( "display" + clipId, clipId );
   		
   		__displayClips.push ( { clip : clip, coord : tileCoord } );
   	
    	mapProvider.paint(clip, tileCoord);
    }
    
    public function cancelDraw():Void
    {
        __paintCall.cancel();
    }
    
    // Event Handlers
    
    private function onPaintComplete( clip : MovieClip, coord : Coordinate ) : Void
    {
    	if ( this.coord.equalTo( coord ) )
    	{
    		DispatchableInterface(grid.mapProvider).removeEventObserver( this, AbstractMapProvider.EVENT_PAINT_COMPLETE, "onPaintComplete" );
    		
    		// remove all other displayClips /below/ this clip   		
    		var dcCoord : Coordinate;
    		for ( var i : Number = 0; i < __displayClips.length; i++ )
    		{
    			dcCoord = Coordinate( __displayClips[i].coord );
    			    			
    			if ( dcCoord.equalTo( this.coord ) )
					break;
    			else
    			{
    				__displayClips[i].clip.removeMovieClip();
    				__displayClips.splice( i, 1 );
    				i--;
    			}
    		}
    		
	   		dispatchEvent( EVENT_PAINT_COMPLETE );
    	}   	
    }   
}