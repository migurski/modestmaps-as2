import org.casaframework.movieclip.DispatchableMovieClip;

import com.modestmaps.core.Point;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.TilePaintCall;
import com.modestmaps.core.TileGrid;
import com.modestmaps.mapproviders.IMapProvider;
import mx.utils.Delegate;
import com.stamen.twisted.*;
import com.modestmaps.events.IDispatchable;
import com.modestmaps.mapproviders.AbstractMapProvider;

class com.modestmaps.core.Tile 
extends DispatchableMovieClip
{
    public var grid:TileGrid;

    private var __coord : Coordinate;
    
    public var width:Number;
    public var height:Number;
    
    private var label:TextField;
    public var origin:Boolean;

	// Keeps track of all clips awaiting painting.
	private var __displayClips : Array;

	private var __paintCompleteDelegate : Function;
	
	private var __paintCall:TilePaintCall;

    public static var symbolName:String = '__Packages.com.modestmaps.core.Tile';
    public static var symbolOwner:Function = Tile;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function Tile()
    {
    	super();
    	
    	__displayClips = new Array();
    	
    	__paintCompleteDelegate = Delegate.create( this, this.onPaintComplete );   	
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
        return 'Tile' + coord.toString();
    }

    public function redraw():Void
    {
    	// any need to repeat ourselves?
    	if(__paintCall && __paintCall.match(grid.mapProvider, coord.copy()) && __paintCall.pending())
            return;
    	
    	IDispatchable(grid.mapProvider).addEventListener(AbstractMapProvider.EVENT_PAINT_COMPLETE, __paintCompleteDelegate);

    	// cancel existing call, if any...
    	if(__paintCall)
    	    __paintCall.cancel();
    	
    	// fire up a new call for the next frame...
    	__paintCall = new TilePaintCall(Reactor.callNextFrame(Delegate.create(this, this.paint), grid.mapProvider, coord.copy()),
    	                                grid.mapProvider, coord.copy());
    }
    
    public function paint(mapProvider:IMapProvider, tileCoord:Coordinate):Void
    {
    	grid.log("Painting tile: " + tileCoord.toString());
    	
    	// set up the proper clip to paint here
    	
    	var clipId : Number = this.getNextHighestDepth();
    	var clip : MovieClip = this.createEmptyMovieClip( "display" + clipId, clipId );
   		
   		// hide all other displayClips to avoid weird "repaint" effect
   		var count : Number = __displayClips.length;
   		while ( count-- )
   		{
   			__displayClips[count].clip._visible = false;
   		}

   		__displayClips.push ( { clip : clip, coord : tileCoord } );
   	
    	mapProvider.paint( clip, tileCoord );
    }
    
    // Event Handlers
    
    private function onPaintComplete( eventObj : Object ) : Void
    {
    	var coord : Coordinate = Coordinate( eventObj.coord );
    	
    	if ( this.coord.equalTo( coord ) )
    	{
    		IDispatchable( grid.mapProvider ).removeEventListener( AbstractMapProvider.EVENT_PAINT_COMPLETE, __paintCompleteDelegate );
    		
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
    	}   	
    }   
}