/*
 * $Id$
 */

import org.casaframework.event.DispatchableInterface;
import org.casaframework.movieclip.DispatchableMovieClip;

import com.bigspaceship.utils.Delegate;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.TileGrid;
import com.modestmaps.core.TilePaintCall;
import com.modestmaps.mapproviders.AbstractMapProvider;
import com.modestmaps.mapproviders.IMapProvider;
import com.stamen.twisted.Reactor;
import flash.geom.Point;

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
   
    public function init(w:Number, h:Number, c:Coordinate, g:TileGrid):Void
    {
        grid = g;
        width = w;
        height = h;
        setCoord(c);
    }
   
    public function getCoord():Coordinate
    {
    	return __coord;	
    }

    public function setCoord(coord:Coordinate):Void
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
        setCoord(new Coordinate(Math.floor(__coord.row / 2), Math.floor(__coord.column / 2), __coord.zoom + 1));
    }

    public function zoomInTopLeft():Void
    {
        setCoord(new Coordinate(__coord.row * 2, __coord.column * 2, __coord.zoom - 1));
    }

    public function zoomInTopRight():Void
    {
        setCoord(new Coordinate(__coord.row * 2, __coord.column * 2 + 1, __coord.zoom - 1));
    }

    public function zoomInBottomLeft():Void
    {
        setCoord(new Coordinate(__coord.row * 2 + 1, __coord.column * 2, __coord.zoom - 1));
    }

    public function zoomInBottomRight():Void
    {
        setCoord(new Coordinate(__coord.row * 2 + 1, __coord.column * 2 + 1, __coord.zoom - 1));
    }

    public function panUp(distance:Number):Void
    {
        setCoord(__coord.up(distance));
    }

    public function panRight(distance:Number):Void
    {
        setCoord(__coord.right(distance));
    }

    public function panDown(distance:Number):Void
    {
        setCoord(__coord.down(distance));
    }

    public function panLeft(distance:Number):Void
    {
        setCoord(__coord.left(distance));
    }

    public function toString():String
    {
        return id();
    }

    public function id():String
    {
        return 'Tile' + __coord.toString();
    }

    public function redraw():Void
    {
    	// any need to repeat ourselves?
    	if(__paintCall && __paintCall.match(grid.getMapProvider(), __coord.copy()) && __paintCall.pending())
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
    	__paintCall = new TilePaintCall(Reactor.callNextFrame(Delegate.create(this, this.paint), grid.getMapProvider(), __coord.copy()),
    	                                grid.getMapProvider(), __coord.copy());
    }
    
    public function paint(mapProvider:IMapProvider, tileCoord:Coordinate):Void
    {
    	//trace("Painting tile: " + tileCoord.toString());
    	
    	// set up the proper clip to paint here
   		DispatchableInterface(grid.getMapProvider()).addEventObserver( this, AbstractMapProvider.EVENT_PAINT_COMPLETE, "onPaintComplete" );
    	
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
    	if ( __coord.equalTo( coord ) )
    	{
    		DispatchableInterface(grid.getMapProvider()).removeEventObserver( this, AbstractMapProvider.EVENT_PAINT_COMPLETE, "onPaintComplete" );
    		
    		// remove all other displayClips /below/ this clip   		
    		var dcCoord : Coordinate;
    		for ( var i : Number = 0; i < __displayClips.length; i++ )
    		{
    			dcCoord = Coordinate( __displayClips[i].coord );
    			    			
    			if ( dcCoord.equalTo( __coord ) )
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