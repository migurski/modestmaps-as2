/*
 * vim:et sts=4 sw=4 cindent:
 * $Id$
 */

import com.bigspaceship.utils.Delegate;
import com.modestmaps.core.Bounds;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Marker;
import com.modestmaps.core.MarkerSet;
import com.modestmaps.core.Point;
import com.modestmaps.core.Tile;
import com.modestmaps.geo.Location;
import com.modestmaps.Map;
import com.modestmaps.mapproviders.IMapProvider;
import com.stamen.twisted.DelayedCall;
import com.stamen.twisted.Reactor;

class com.modestmaps.core.TileGrid extends MovieClip
{
    // Real maps use 256.
    public static var TILE_WIDTH:Number = 256;
    public static var TILE_HEIGHT:Number = 256;

    private var __map:Map;

    private var __width:Number;
    private var __height:Number;
    private var __draggable:Boolean;

    // Row and column counts are kept up-to-date.
    private var __rows:Number;
    private var __columns:Number;
    private var __tiles:/*Tile*/Array;
    
    // overlay markers
    private var markers:MarkerSet;
    
    // Markers overlapping the currently-included set of tiles, hash of booleans
    private var __overlappingMarkers:Object;

    // Allow (true) or prevent (false) tiles to paint themselves.
    private var __paintingAllowed:Boolean;
    
    // Starting point for the very first tile
    private var __initTilePoint:Point;
    private var __initTileCoord:Coordinate;
    
    // the currently-native zoom level
    public var zoomLevel:Number;
    
    // some limits on scrolling distance, initially set to none
    private var topLeftOutLimit:Coordinate;
    private var bottomRightInLimit:Coordinate;
    
    private var __startingWellPosition:Point;

    // Tiles attach to the well.
    private var __well:MovieClip;
    
    // Mask clip to hide outside edges of tiles.
    private var __mask:MovieClip;

    // Active when the well is being dragged on the stage.
    private var __wellDragTask:DelayedCall;
    
    // Defines a ring of extra, masked-out tiles around
    // the edges of the well, acting as a pre-fetching cache.
    // High tileBuffer may hurt performance.
    private var __tileBuffer:Number = 0;

    // Who do we get our Map graphics from?
    private var __mapProvider:IMapProvider;

    public static var symbolName:String = '__Packages.com.modestmaps.core.TileGrid';
    public static var symbolOwner:Function = TileGrid;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function init(width:Number, height:Number, draggable:Boolean, provider:IMapProvider, map:Map):Void
    {
        if(!Reactor.running())
            throw new Error('com.modestmaps.core.TileGrid.init(): com.stamen.Twisted.Reactor really ought to be running at this point. Seriously.');

        __map = map;
        __width = width;
        __height = height;
        __draggable = draggable;
        __mapProvider = provider;
    
        buildWell();
        buildMask();
        allowPainting(true);
        redraw();   
        
        __overlappingMarkers = {};
        markers = new MarkerSet(this);
        
        Reactor.callNextFrame(Delegate.create(this, this.initializeTiles));
    }
    
   /**
    * Set initTileCoord and initTilePoint for use by initializeTiles().
    */
    public function setInitialTile(coord:Coordinate, point:Point):Void
    {
        __initTileCoord = coord;
        __initTilePoint = point;
    }
    
   /**
    * Reset tile grid with a new initial tile, and expire old tiles in the background.
    */
    public function resetTiles(coord:Coordinate, point:Point):Void
    {
        if(!__tiles) {
            setInitialTile(coord, point);
            return;
        }
    
        var initTile:Tile;
        var condemnedTiles:/*Tile*/Array = activeTiles();

        for(var i:Number = 0; i < condemnedTiles.length; i += 1)
            condemnedTiles[i].expire();

        Reactor.callLater(condemnationDelay(), Delegate.create(this, this.destroyTiles), condemnedTiles);

        // initial tile
        initTile = createTile(TILE_WIDTH, TILE_HEIGHT, coord);
                                                                  
        centerWell(true);
        initTile._x = point.x;
        initTile._y = point.y;

        __rows = 1;
        __columns = 1;

        allocateTiles();
    }
    
   /**
    * Create the first tiles, based on initTileCoord and initTilePoint.
    */
    private function initializeTiles():Void
    {
        var initTile:Tile;
        
        // impose some limits
        zoomLevel = __initTileCoord.zoom;
        topLeftOutLimit = __mapProvider.outerLimits()[0];
        bottomRightInLimit = __mapProvider.outerLimits()[1];
        
        // initial tile
        __tiles = [];
        initTile = createTile(TILE_WIDTH, TILE_HEIGHT, __initTileCoord);
                                                                  
        centerWell(false);
        initTile._x = __initTilePoint.x;
        initTile._y = __initTilePoint.y;

        __rows = 1;
        __columns = 1;
        
        // buffer must not be negative!
        __tileBuffer = Math.max(0, __tileBuffer);
        
        allocateTiles();
        
        // let 'em know we're coming
        markers.indexAtZoom(zoomLevel);
        
        updateMarkers();
    }
    
    public function putMarker(id:String, coord:Coordinate, location:Location):Marker
    {
        var marker:Marker = new Marker(id, coord, location);
        //trace('Marker '+id+': '+coord.toString());
        markers.put(marker);

        updateMarkers();
        return marker;
    }

    public function removeMarker(id:String):Void
    {
        var marker:Marker = markers.getMarker(id);
        if(marker)
            markers.remove(marker);
    }
	
   /**
    * Create the well clip, assign event handlers.
    */
    private function buildWell():Void
    {
        __well = createEmptyMovieClip('well', 1);
        
        if(__draggable) {
            __well.onPress = Delegate.create(this, this.startWellDrag);
            __well.onRelease = Delegate.create(this, this.stopWellDrag);
            __well.onReleaseOutside = Delegate.create(this, this.stopWellDrag);
        }

        centerWell(false);
    }
    
   /**
    * Create the mask clip.
    */
    private function buildMask():Void
    {
        __mask = createEmptyMovieClip('mask', getNextHighestDepth());
        __well.setMask(__mask);
    }
    
    
    public function getMapProvider():IMapProvider
    {
        return __mapProvider; 
    }

    public function setMapProvider(mapProvider:IMapProvider):Void
    {
        var previousGeometry:String = __mapProvider.geometry();

        __mapProvider = mapProvider; 
        topLeftOutLimit = __mapProvider.outerLimits()[0];
        bottomRightInLimit = __mapProvider.outerLimits()[1];

        if(__mapProvider.geometry() != previousGeometry) {
            markers.initializeIndex();
            markers.indexAtZoom(zoomLevel);
            updateMarkers();
        }
    }
    
    
   /**
    * Create a new tile, add it to __tiles array, and return it.
    */
    private function createTile(width:Number, height:Number, coord:Coordinate):Tile
    {
        var tile:Tile;

        tile = Tile(__well.attachMovie(Tile.symbolName, 'tile'+__well.getNextHighestDepth(), __well.getNextHighestDepth()));
        tile.init(width, height, coord, this);
        __tiles.push(tile);
        
        //trace('Created tile: '+tile.toString());
        return tile;
    }

   /**
    * Remove an old tile from the __tiles array, then destroy it.
    */
    private function destroyTile(tile:Tile):Void
    {
        //trace('Destroying tile: '+tile.toString());
        __tiles.splice(tileIndex(tile), 1);
        tile.cancelDraw();
        tile.removeMovieClip();
    }
    
   /*
    * Slowly mete out destruction to a list of tiles.
    */
    private function destroyTiles(tiles:/*Tile*/Array):Void
    {
        if(tiles.length) {
            destroyTile(Tile(tiles.shift()));
            Reactor.callLater(0, Delegate.create(this, this.destroyTiles), tiles);
        }
    }

   /*
    * Reposition tiles and schedule a recursive call for the next frame.
    */
    private function onWellDrag(previousPosition:Point):Void
    {
        if(positionTiles())
            updateMarkers();

        if(previousPosition.x != __well._x || previousPosition.y != __well._y)
            __map.onPanned(new Point(__well._x - __startingWellPosition.x, __well._y - __startingWellPosition.y));
        
        __wellDragTask = Reactor.callNextFrame(Delegate.create(this, this.onWellDrag), new Point(__well._x, __well._y));
    }
    
   /*
    * Return the point position of a tile with the given coordinate in the
    * context of the given movie clip.
    *
    * Respect infinite rows or columns, to bind movement on one (or no) axis.
    */
    public function coordinatePoint(coord:Coordinate, context:MovieClip, fearBigNumbers:Boolean):Point
    {
        // pick a reference tile, an arbitrary choice
        // but known to exist regardless of grid size.
        var tile:Tile = activeTiles()[0];
    
        // get the position of the reference tile.
        var point:Point = new Point(tile._x, tile._y);
        
        // make sure coord is using the same zoom level
        coord = coord.zoomTo(tile.getCoord().zoom);
        
        // store the infinite
        var force:Point = new Point(0, 0);
        
        if(coord.column == Number.POSITIVE_INFINITY || coord.column == Number.NEGATIVE_INFINITY) {
            force.x = coord.column;
            
        } else {
            point.x += TILE_WIDTH * (coord.column - tile.getCoord().column);
        
        }
        
        if(coord.row == Number.POSITIVE_INFINITY || coord.row == Number.NEGATIVE_INFINITY) {
            force.y = coord.row;
            
        } else {
            point.y += TILE_HEIGHT * (coord.row - tile.getCoord().row);

        }
        
        if(fearBigNumbers) {
            if(point.x < -1e6)
                force.x = Number.NEGATIVE_INFINITY;
            
            if(point.x > 1e6)
                force.x = Number.POSITIVE_INFINITY;
            
            if(point.y < -1e6)
                force.y = Number.NEGATIVE_INFINITY;
            
            if(point.y > 1e6)
                force.y = Number.POSITIVE_INFINITY;
        }
        
        __well.localToGlobal(point);
        context.globalToLocal(point);

        if(force.x)
            point.x = force.x;
        
        if(force.y)
            point.y = force.y;
            
        return point;
    }
    
    public function pointCoordinate(point:Point, context:MovieClip):Coordinate
    {
        var tile:Tile;
        var tileCoord:Coordinate;
        var pointCoord:Coordinate;
        
        context.localToGlobal(point);
        __well.globalToLocal(point);

        // an arbitrary reference tile, zoomed to the maximum
        tile = activeTiles()[0];
        tileCoord = tile.getCoord().copy();
        tileCoord = tileCoord.zoomTo(Coordinate.MAX_ZOOM);
        
        // distance in tile widths from reference tile to point
        var xTiles:Number = (point.x - tile._x) / TILE_WIDTH;
        var yTiles:Number = (point.y - tile._y) / TILE_HEIGHT;

        // distance in rows & columns at maximum zoom
        var xDistance:Number = xTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.getCoord().zoom));
        var yDistance:Number = yTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.getCoord().zoom));
        
        // new point coordinate reflecting that distance
        pointCoord = new Coordinate(Math.round(tileCoord.row + yDistance),
                                    Math.round(tileCoord.column + xDistance),
                                    tileCoord.zoom);
        
        return pointCoord.zoomTo(tile.getCoord().zoom);
    }
    
    public function topLeftCoordinate():Coordinate
    {
        var point:Point = new Point(0, 0);
        return pointCoordinate(point, this);
    }
    
    public function centerCoordinate():Coordinate
    {
        var point:Point = new Point(__width/2, __height/2);
        return pointCoordinate(point, this);
    }
    
    public function bottomRightCoordinate():Coordinate
    {
        var point:Point = new Point(__width, __height);
        return pointCoordinate(point, this);
    }
    
   /*
    * Start dragging the well with the mouse.
    * Calls onWellDrag().
    */
    private function getWellBounds(fearBigNumbers:Boolean):Bounds
    {
        var min:Point, max:Point;

        // "min" = furthest well position left & up,
        // use the location of the bottom-right limit
        min = coordinatePoint(bottomRightInLimit, this, fearBigNumbers);
        min.x = __well._x - min.x + __width;
        min.y = __well._y - min.y + __height;
        
        // "max" = furthest well position right & down,
        // use the location of the top-left limit
        max = coordinatePoint(topLeftOutLimit, this, fearBigNumbers);
        max.x = __well._x - max.x;
        max.y = __well._y - max.y;
        
        //trace('min/max for drag: '+min+', '+max+' ('+topLeftOutLimit+', '+bottomRightInLimit+')');
        
        // weird negative edge conditions, limit all movement on an axis
        if(min.x > max.x)
            min.x = max.x = __well._x;

        if(min.y > max.y)
            min.y = max.y = __well._y;
            
        return new Bounds(min, max);
    }
    
   /*
    * Start dragging the well with the mouse.
    * Calls onWellDrag().
    */
    public function startWellDrag():Void
    {
        var bounds:Bounds = getWellBounds(true);
        
        // MovieClip.startDrag seems to hate the infinities,
        // so we'll fudge it with some implausibly large numbers.
        
        var xMin:Number = (bounds.min.x == Number.POSITIVE_INFINITY)
                            ? 100000
                            : ((bounds.min.x == Number.NEGATIVE_INFINITY)
                                ? -100000
                                : bounds.min.x);
        
        var yMin:Number = (bounds.min.y == Number.POSITIVE_INFINITY)
                            ? 100000
                            : ((bounds.min.y == Number.NEGATIVE_INFINITY)
                                ? -100000
                                : bounds.min.y);
        
        var xMax:Number = (bounds.max.x == Number.POSITIVE_INFINITY)
                            ? 100000
                            : ((bounds.max.x == Number.NEGATIVE_INFINITY)
                                ? -100000
                                : bounds.max.x);
        
        var yMax:Number = (bounds.max.y == Number.POSITIVE_INFINITY)
                            ? 100000
                            : ((bounds.max.y == Number.NEGATIVE_INFINITY)
                                ? -100000
                                : bounds.max.y);
                                
        //trace('Drag bounds would be: '+xMin+', '+yMin+', '+xMax+', '+yMax);
        
        __startingWellPosition = new Point(__well._x, __well._y);
        //trace('Starting well position: '+__startingWellPosition.toString());
        
        __map.onStartPan();
        __well.startDrag(false, xMin, yMin, xMax, yMax);
        onWellDrag(__startingWellPosition.copy());
    }
    
   /*
    * Stop dragging the well with the mouse.
    * Halts __wellDragTask.
    */
    public function stopWellDrag():Void
    {
        __map.onStopPan();
        __wellDragTask.cancel();
        __well.stopDrag();

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }
    
    public function zoomBy(amount:Number, redraw:Boolean):Void
    {
        if(!__tiles)
            return;
        
        if(amount > 0 && zoomLevel >= bottomRightInLimit.zoom && Math.round(__well._xscale) >= 100)
            return;
    
        if(amount < 0 && zoomLevel <= topLeftOutLimit.zoom && Math.round(__well._xscale) <= 100)
            return;
    
        __well._xscale *= Math.pow(2, amount);
        __well._yscale *= Math.pow(2, amount);
        
        boundWell();
        
        if(redraw) {
            normalizeWell();
            allocateTiles();
            //trace('New well scale: '+__well._xscale.toString());
        }
    }
    
    public function resizeTo(bottomRight:Point):Void
    {
        __width = bottomRight.x;
        __height = bottomRight.y;

        redraw();

        if(!__tiles)
            return;
        
        centerWell(false);
        allocateTiles();
    }
    
    public function panRight(pixels:Number):Void
    {
        if(!__tiles)
            return;
        
        __well._x -= pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }
 
    public function panLeft(pixels:Number):Void
    {
        if(!__tiles)
            return;
        
        __well._x += pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    } 
 
    public function panUp(pixels:Number):Void
    {
        if(!__tiles)
            return;
        
        __well._y += pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }      
    
    public function panDown(pixels:Number):Void
    {
        if(!__tiles)
            return;
        
        __well._y -= pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }

   /**
    * Get the subset of still-active tiles.
    */
    private function activeTiles():/*Tile*/Array
    {
        var matches:/*Tile*/Array = [];
        
        for(var i:Number = 0; i < __tiles.length; i += 1)
            if(__tiles[i].isActive())
                matches.push(__tiles[i]);

        return matches;
    }

   /**
    * Find the given tile in the tiles array.
    */
    private function tileIndex(tile:Tile):Number
    {
        for(var i:Number = 0; i < __tiles.length; i += 1)
            if(__tiles[i] == tile)
                return i;

        return -1;
    }

   /**
    * Determine the number of tiles needed to cover the current grid,
    * and add rows and columns if necessary. Finally, position new tiles.
    */
    private function allocateTiles():Void
    {
        if(!__tiles)
            return;
        
        // internal pixel dimensions of well, compensating for scale
        var wellWidth:Number  = (100 / __well._xscale) * __width;
        var wellHeight:Number = (100 / __well._yscale) * __height;

        var targetCols:Number = Math.ceil(wellWidth  / TILE_WIDTH)  + 1 + 2 * __tileBuffer;
        var targetRows:Number = Math.ceil(wellHeight / TILE_HEIGHT) + 1 + 2 * __tileBuffer;

        // grid can't drop below 1 x 1
        targetCols = Math.max(1, targetCols);
        targetRows = Math.max(1, targetRows);

        // change column count to match target
        while(__columns != targetCols) {
            if(__columns < targetCols) {
                pushTileColumn();

            } else if(__columns > targetCols) {
                popTileColumn();

            }
        }

        // change row count to match target
        while(__rows != targetRows) {
            if(__rows < targetRows) {
                pushTileRow();

            } else if(__rows > targetRows) {
                popTileRow();

            }
        }

        if(positionTiles())
            updateMarkers();
    }
    
   /**
    * Adjust position of the well, so it does not stray outside the provider boundaries.
    */
    private function boundWell():Void
    {
        var bounds:Bounds = getWellBounds(true);
        
        __well._x = Math.min(bounds.max.x, Math.max(bounds.min.x, __well._x));
        __well._y = Math.min(bounds.max.y, Math.max(bounds.min.y, __well._y));
    }
    
   /**
    * Adjust position of the well, so it stays in the center.
    * Optionally, compensate tile positions to prevent
    * visual discontinuity.
    */
    private function centerWell(adjustTiles:Boolean):Void
    {
        var center:Point = new Point(__width/2, __height/2);
        
        var xAdjustment:Number = __well._x - center.x;
        var yAdjustment:Number = __well._y - center.y;

        __well._x -= xAdjustment;
        __well._y -= yAdjustment;
        
        if(!__tiles)
            return;
        
        if(adjustTiles) {
            for(var i:Number = 0; i < __tiles.length; i += 1) {
                __tiles[i]._x += xAdjustment * 100 / __well._xscale;
                __tiles[i]._y += yAdjustment * 100 / __well._xscale;
            }
        }
    }
    
   /**
    * Adjust position and scale of the well, so it stays
    * in the center and within reason.  Compensate tile
    * zoom and positions to prevent visual discontinuity.
    */
    private function normalizeWell():Void
    {
        if(!__tiles)
            return;
        
        var zoomAdjust:Number, scaleAdjust:Number;
        var active:/*Tile*/Array;
        
        // just in case?
        centerWell(true);

        if(Math.abs(__well._xscale - 100) < 1) {
            active = activeTiles();
        
            // set to 100% if within 99% - 101%
            __well._xscale = __well._yscale = 100;
            
            active.sort(compareTileRowColumn);
            
            // lock the tiles back to round-pixel positions
            active[0]._x = Math.round(active[0]._x);
            active[0]._y = Math.round(active[0]._y);
            
            for(var i:Number = 1; i < active.length; i += 1) {
                active[i]._x = active[0]._x + (active[i].getCoord().column - active[0].getCoord().column) * TILE_WIDTH;
                active[i]._y = active[0]._y + (active[i].getCoord().row    - active[0].getCoord().row)    * TILE_HEIGHT;
            
                //trace(active[i].toString()+' at '+active[i]._x+', '+active[i]._y+' vs. '+active[0].toString());
            }

        } else if(Math.floor(__well._xscale) <= 60 || Math.ceil(__well._xscale) >= 165) {
            // split or merge tiles if outside of 60% - 165%

            // zoom adjust: base-2 logarithm of the scale
            // see http://mathworld.wolfram.com/Logarithm.html (15)
            zoomAdjust = Math.round(Math.log(__well._xscale / 100) / Math.log(2));
            scaleAdjust = Math.pow(2, zoomAdjust);
        
            //trace('This is where we scale the whole well by '+zoomAdjust+' zoom levels: '+(100 / scaleAdjust)+'%');

            for(var i:Number = 0; i < zoomAdjust; i += 1) {
                splitTiles();
                zoomLevel += 1;
            }
                
            for(var i:Number = 0; i > zoomAdjust; i -= 1) {
                mergeTiles();
                zoomLevel -= 1;
            }

            __well._xscale = Math.round(__well._xscale / scaleAdjust);
            __well._yscale = Math.round(__well._yscale / scaleAdjust);

            for(var i:Number = 0; i < __tiles.length; i += 1) {
                __tiles[i]._x = Math.round(__tiles[i]._x * scaleAdjust);
                __tiles[i]._y = Math.round(__tiles[i]._y * scaleAdjust);

                __tiles[i]._xscale = Math.round(__tiles[i]._xscale * scaleAdjust);
                __tiles[i]._yscale = Math.round(__tiles[i]._yscale * scaleAdjust);
            }
        
            //trace('Scaled to '+zoomLevel+', '+__well._xscale+'%');
            markers.indexAtZoom(zoomLevel);
        }
    }
    
   /**
    * How many milliseconds before condemned tiles are destroyed?
    */
    private function condemnationDelay():Number
    {
        // half a second for each tile, plus five seconds overhead
        return (5 + .5 * __rows * __columns) * 1000;
    }
    
   /**
    * Do a 1-to-4 tile split: pick a reference tile and use it
    * as a position for four new tiles at a higher zoom level.
    * Expire all existing tiles, and trust that allocateTiles() and
    * positionTiles() will take care of filling the remaining space.
    */
    private function splitTiles():Void
    {
        var condemnedTiles:/*Tile*/Array = [];
        var referenceTile:Tile, newTile:Tile;
        var xOffset:Number, yOffset:Number;
        
        for(var i:Number = __tiles.length - 1; i >= 0; i -= 1) {
            if(__tiles[i].isActive()) {
                // remove old tile
                __tiles[i].expire();
                condemnedTiles.push(__tiles[i]);

                // save for later (you only need one)
                referenceTile = __tiles[i];
            }
        }

        Reactor.callLater(condemnationDelay(), Delegate.create(this, this.destroyTiles), condemnedTiles);
    
        // this should never happen
        if(!referenceTile)
            return;

        for(var q:Number = 0; q < 4; q += 1) {
            // two-bit value into two one-bit values
            xOffset = q & 1;
            yOffset = (q >> 1) & 1;
            
            newTile = createTile(referenceTile.width, referenceTile.height, referenceTile.getCoord());
            newTile.setCoord(newTile.getCoord().zoomBy(1));
            
            if(xOffset)
                newTile.setCoord(newTile.getCoord().right());
            
            if(yOffset)
                newTile.setCoord(newTile.getCoord().down());

            newTile._x = referenceTile._x + (xOffset * TILE_WIDTH / 2);
            newTile._y = referenceTile._y + (yOffset * TILE_HEIGHT / 2);

            newTile._xscale = newTile._yscale = referenceTile._xscale / 2;
            newTile.redraw();
        }

        // The remaining tiles get taken care of later
        __rows = 2;
        __columns = 2;
    }
    
   /**
    * Do a 4-to-1 tile merge: pick a reference tile and use it
    * as a position for the upper-left-hand corder of one new tile
    * at a higher zoom level. Expire all existing tiles, and trust
    * that allocateTiles() and positionTiles() will take care of
    * filling the remaining space.
    */
    private function mergeTiles():Void
    {
        var condemnedTiles:/*Tile*/Array = [];
        var referenceTile:Tile, newTile:Tile;
    
        __tiles.sort(compareTileRowColumn);

        for(var i:Number = __tiles.length - 1; i >= 0; i -= 1) {
            if(__tiles[i].isActive()) {
                // remove old tile
                __tiles[i].expire();
                condemnedTiles.push(__tiles[i]);

                if(__tiles[i].getCoord().zoomBy(-1).isEdge()) {
                    // save for later (you only need one)
                    referenceTile = __tiles[i];
                }
            }
        }

        Reactor.callLater(condemnationDelay(), Delegate.create(this, this.destroyTiles), condemnedTiles);
    
        // this should never happen
        if(!referenceTile)
            return;

        // we are only interested in tiles that are edges for this zoom
        newTile = createTile(referenceTile.width, referenceTile.height, referenceTile.getCoord());
        newTile.setCoord(newTile.getCoord().zoomBy(-1));
        
        newTile._x = referenceTile._x;
        newTile._y = referenceTile._y;

        newTile._xscale = newTile._yscale = referenceTile._xscale * 2;
        newTile.redraw();

        // The remaining tiles get taken care of later
        __rows = 1;
        __columns = 1;
    }
    
   /**
    * Determine if any tiles have wandered too far to the right, left,
    * top, or bottom, and shunt them to the opposite side if needed.
    * Return true if any tiles have been repositioned.
    */
    private function positionTiles():Boolean
    {
        if(!__tiles)
            return false;
        
        var tile:Tile;
        var point:Point;
        var active:/*Tile*/Array = activeTiles();
        
        // if any tile is moved...
        var touched:Boolean = false;
        
        point = new Point(0, 0);
        this.localToGlobal(point);
        __well.globalToLocal(point); // all tiles are attached to well
        
        var xMin:Number = point.x - (1 + __tileBuffer) * TILE_WIDTH;
        var yMin:Number = point.y - (1 + __tileBuffer) * TILE_HEIGHT;
        
        point = new Point(__width, __height);
        this.localToGlobal(point);
        __well.globalToLocal(point); // all tiles are attached to well
        
        var xMax:Number = point.x + (0 + __tileBuffer) * TILE_WIDTH;
        var yMax:Number = point.y + (0 + __tileBuffer) * TILE_HEIGHT;
        
        for(var i:Number = 0; i < active.length; i += 1) {
        
            tile = active[i];
            
            // only interested in moving active tiles
            if(!tile.isActive())
                break;
            
            if(tile._y < yMin) {
                // too far up
                tile.panDown(__rows);
                tile._y += __rows * TILE_HEIGHT;
                touched = true;

            } else if(tile._y > yMax) {
                // too far down
                if((tile._y - __rows * TILE_HEIGHT) > yMin) {
                    // moving up wouldn't put us too far
                    tile.panUp(__rows);
                    tile._y -= __rows * TILE_HEIGHT;
                    touched = true;
                }
            }
            
            if(tile._x < xMin) {
                // too far left
                tile.panRight(__columns);
                tile._x += __columns * TILE_WIDTH;
                touched = true;

            } else if(tile._x > xMax) {
                // too far right
                if((tile._x - __columns * TILE_WIDTH) > xMin) {
                    // moving left wouldn't put us too far
                    tile.panLeft(__columns);
                    tile._x -= __columns * TILE_WIDTH;
                    touched = true;
                }
            }
        }
        
        return touched;
    }
    
    private function updateMarkers():Void
    {
        var visible:/*Marker*/Array = markers.overlapping(activeTiles());
        var newOverlappingMarkers:Object = {};
        
        for(var i:Number = 0; i < visible.length; i += 1)
            newOverlappingMarkers[visible[i].id] = visible[i];

        // check for newly-visible markers
        for(var id:String in newOverlappingMarkers) {
            if(newOverlappingMarkers[id] && !__overlappingMarkers[id]) {
                __map.onMarkerEnters(id, markers.getMarker(id).location);
                __overlappingMarkers[id] = true;
            }
        }
        
        for(var id:String in __overlappingMarkers) {
            if(!newOverlappingMarkers[id] && __overlappingMarkers[id]) {
                __map.onMarkerLeaves(id, markers.getMarker(id).location);
                delete __overlappingMarkers[id];
            }
        }
    }
    
   /**
    * Add a new row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function pushTileRow():Void
    {
        var lastTile:Tile, newTile:Tile;
        var active:/*Tile*/Array = activeTiles();
        
        active.sort(compareTileRowColumn);
        
        for(var i:Number = active.length - __columns; i < __rows * __columns; i += 1) {
        
            lastTile = active[i];
        
            newTile = createTile(TILE_WIDTH, TILE_HEIGHT, lastTile.getCoord().down());
            newTile._x = lastTile._x;
            newTile._y = lastTile._y + lastTile.height;
        }
        
        __rows += 1;
    }

   /**
    * Remove a row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function popTileRow():Void
    {
        var active:/*Tile*/Array = activeTiles();

        active.sort(compareTileRowColumn);

        while(active.length > __columns * (__rows - 1))
            destroyTile(Tile(active.pop()));
                                         
        __rows -= 1;
    }

   /**
    * Add a new column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function pushTileColumn():Void
    {
        var lastTile:Tile, newTile:Tile;
        var active:/*Tile*/Array = activeTiles();
        
        active.sort(compareTileColumnRow);
        
        for(var i:Number = active.length - __rows; i < __rows * __columns; i += 1) {
        
            lastTile = active[i];
        
            newTile = createTile(TILE_WIDTH, TILE_HEIGHT, lastTile.getCoord().right());
            newTile._x = lastTile._x + lastTile.width;
            newTile._y = lastTile._y;
        }
        
        __columns += 1;
    }

   /**
    * Remove a column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function popTileColumn():Void
    {
        var active:/*Tile*/Array = activeTiles();

        active.sort(compareTileColumnRow);

        while(active.length > __rows * (__columns - 1))
            destroyTile(Tile(active.pop()));

        __columns -= 1;
    }
    
   /**
    * Comparison function for sorting tiles by distance from a point.
    */
    private static function compareTileDistanceFrom(p:Point):Function
    {
        return function(a:Tile, b:Tile):Number
        {
            var aDist:Number = Math.sqrt(Math.pow(a.center().x - p.x, 2) + Math.pow(a.center().y - p.y, 2));
            var bDist:Number = Math.sqrt(Math.pow(b.center().x - p.x, 2) + Math.pow(b.center().y - p.y, 2));
            return aDist - bDist;
        };
    }
    
   /**
    * Comparison function for sorting tiles by row, then column, i.e. horizontally.
    */
    private static function compareTileRowColumn(a:Tile, b:Tile):Number
    {
        if(a.getCoord().row == b.getCoord().row) {
            return a.getCoord().column - b.getCoord().column;
            
        } else {
            return a.getCoord().row - b.getCoord().row;
            
        }
    }
    
   /**
    * Comparison function for sorting tiles by column, then row, i.e. vertically.
    */
    private static function compareTileColumnRow(a:Tile, b:Tile):Number
    {
        if(a.getCoord().column == b.getCoord().column) {
            return a.getCoord().row - b.getCoord().row;
            
        } else {
            return a.getCoord().column - b.getCoord().column;
            
        }
    }
    
    public function repaintTiles():Void
    {
        var active:/*Tile*/Array = activeTiles();
        
        for(var i:Number = 0; i < active.length; i += 1)
            active[i].paint(__mapProvider, active[i].getCoord());
    }
    
   /**
    * Allow (true) or prevent (false) tiles to paint themselves.
    * See Tile.redraw().
    */
    public function allowPainting(allow:Boolean):Void
    {
        __paintingAllowed = allow;
    }
    
   /**
    * Can tiles paint themselves? See Tile.redraw().
    */
    public function paintingAllowed():Boolean
    {
        return __paintingAllowed;
    }
    
    private function redraw()
    {
        clear();
        /*
        moveTo(0, 0);
        lineStyle(2, 0x990099, 100);
        beginFill(0x666666, 100);
        lineTo(0, __height);
        lineTo(__width, __height);
        lineTo(__width, 0);
        lineTo(0, 0);
        endFill();
        */
        
        __mask.clear();
        __mask.moveTo(0, 0);
        __mask.lineStyle(2, 0x990099, 100);
        __mask.beginFill(0x000000, 0);
        __mask.lineTo(0, __height);
        __mask.lineTo(__width, __height);
        __mask.lineTo(__width, 0);
        __mask.lineTo(0, 0);
        __mask.endFill();
        
        // note that __well (0, 0) is grid center.
        __well.clear();
        __well.moveTo(__width/-2, __height/-2);
        __well.lineStyle();
        __well.beginFill(0x666666, 100);
        __well.lineTo(__width/-2, __height/2);
        __well.lineTo(__width/2, __height/2);
        __well.lineTo(__width/2, __height/-2);
        __well.lineTo(__width/-2, __height/-2);
        __well.endFill();
    }
}
