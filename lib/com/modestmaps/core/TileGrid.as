import com.modestmaps.geo.Location;
import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Bounds;
import com.modestmaps.core.MarkerSet;
import com.modestmaps.core.Marker;
import com.modestmaps.core.Point;
import com.modestmaps.core.Tile;
import com.modestmaps.mapproviders.IMapProvider;

import mx.utils.Delegate;
import com.stamen.twisted.*;

class com.modestmaps.core.TileGrid extends MovieClip
{
    private var width:Number;
    private var height:Number;

    // Row and column counts are kept up-to-date.
    private var rows:Number;
    private var columns:Number;
    private var tiles:/*Tile*/Array;
    
    // overlay markers
    private var markers:MarkerSet;
    
    // Markers overlapping the currently-included set of tiles, hash of booleans
    private var __overlappingMarkers:Object;

    // Real maps use 256.
    public var tileWidth:Number = 256;
    public var tileHeight:Number = 256;
    
    // Allow (true) or prevent (false) tiles to paint themselves.
    private var __paintingAllowed:Boolean;
    
    // Starting point for the very first tile
    private var initTilePoint:Point;
    private var initTileCoord:Coordinate;
    
    // the currently-native zoom level
    private var zoomLevel:Number;
    
    // some limits on scrolling distance, initially set to none
    private var topLeftOutLimit:Coordinate;
    private var bottomRightInLimit:Coordinate;

    // Tiles attach to the well.
    private var well:MovieClip;
    
    // Mask clip to hide outside edges of tiles.
    private var mask:MovieClip;
    
    // For testing purposes.
    public var labelContainer:MovieClip;
    public var label:TextField;
    
    // Active when the well is being dragged on the stage.
    private var wellDragTask:DelayedCall;
    
    // Defines a ring of extra, masked-out tiles around
    // the edges of the well, acting as a pre-fetching cache.
    // High tileBuffer may hurt performance.
    private var tileBuffer:Number = 0;

    // Who do we get our Map graphics from?
    private var __mapProvider:IMapProvider;

    public static var symbolName:String = '__Packages.com.modestmaps.core.TileGrid';
    public static var symbolOwner:Function = TileGrid;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function TileGrid()
    {
        this.createEmptyMovieClip( "labelContainer", getNextHighestDepth() );
        labelContainer.createTextField('label', 1, 10, 10, width-20, height-20);
        label = labelContainer["label"];
        label.selectable = false;
        label.textColor = 0xFF6600;
                
        log('FUCK YEAH '+width+'x'+height);
        
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
        initTileCoord = coord;
        initTilePoint = point;
    }
    
   /**
    * Reset tile grid with a new initial tile, and expire old tiles in the background.
    */
    public function resetTiles(coord:Coordinate, point:Point):Void
    {
        var initTile:Tile;
        var condemnedTiles:/*Tile*/Array = activeTiles();

        for(var i:Number = 0; i < condemnedTiles.length; i += 1)
            condemnedTiles[i].expire();

        Reactor.callLater(condemnationDelay(), Delegate.create(this, this.destroyTiles), condemnedTiles);

        // initial tile
        var initObj:Object =
        { 
            grid: this, 
            width: tileWidth, 
            height: tileHeight,
            coord: coord
        };

        initTile = createTile(initObj);
                                                                  
        centerWell(true);
        initTile._x = point.x;
        initTile._y = point.y;

        rows = 1;
        columns = 1;

        allocateTiles();
    }
    
   /**
    * Create the first tiles, based on initTileCoord and initTilePoint.
    */
    private function initializeTiles():Void
    {
        var initTile:Tile;
        
        // impose some limits
        zoomLevel = initTileCoord.zoom;
        topLeftOutLimit = mapProvider.outerLimits()[0];
        bottomRightInLimit = mapProvider.outerLimits()[1];
        
        // initial tile
        var initObj:Object =
        { 
            grid: this, 
            width: tileWidth, 
            height: tileHeight,
            coord: initTileCoord
        };
        
        tiles = [];
        initTile = createTile(initObj);
                                                                  
        centerWell(false);
        initTile._x = initTilePoint.x;
        initTile._y = initTilePoint.y;

        rows = 1;
        columns = 1;
        
        // buffer must not be negative!
        tileBuffer = Math.max(0, tileBuffer);
        
        allocateTiles();
        
        labelContainer.swapDepths( getNextHighestDepth() );    

        // let 'em know we're coming
        markers.indexAtZoom(zoomLevel);
        
        updateMarkers();
    }
    
    public function putMarker(name:String, coord:Coordinate, location:Location):Void
    {
        //log('Marker '+name+': '+coord.toString());
        markers.put(new Marker(name, coord, location));

        updateMarkers();
    }
    
   /**
    * Create the well clip, assign event handlers.
    */
    private function buildWell():Void
    {
        well = createEmptyMovieClip('well', 1);
        well.onPress = Delegate.create(this, this.startWellDrag);
        well.onRelease = Delegate.create(this, this.stopWellDrag);
        well.onReleaseOutside = Delegate.create(this, this.stopWellDrag);

        centerWell(false);
        
        /*
        // So the log is visible...
        var c:Color = new Color(well);
        var t:Object = c.getTransform();
        t.ra = 20;
        t.rb = 204;
        t.ga = 20;
        t.gb = 204;
        t.ba = 20;
        t.bb = 204;
        c.setTransform(t);
        */
    }
    
   /**
    * Create the mask clip.
    */
    private function buildMask():Void
    {
        mask = createEmptyMovieClip('mask', getNextHighestDepth());
        well.setMask(mask);
    }
    
    
    public function get mapProvider():IMapProvider
    {
        return __mapProvider; 
    }

    public function set mapProvider(mapProvider:IMapProvider):Void
    {
        var previousGeometry:String = __mapProvider.geometry();

        __mapProvider = mapProvider; 

        if(__mapProvider.geometry() != previousGeometry) {
            markers.initializeIndex();
            markers.indexAtZoom(zoomLevel);
            updateMarkers();
        }
    }
    
    
   /**
    * Create a new tile, add it to tiles array, and return it.
    */
    private function createTile(tileParams:Object):Tile
    {
        var tile:Tile;

        tile = Tile(well.attachMovie(Tile.symbolName, 'tile'+well.getNextHighestDepth(), well.getNextHighestDepth(), tileParams));
        tile.redraw();
        tiles.push(tile);
        
        //log('Created tile: '+tile.toString());
        return tile;
    }

   /**
    * Remove an old tile from the tiles array, then destroy it.
    */
    private function destroyTile(tile:Tile):Void
    {
        //log('Destroying tile: '+tile.toString());
        tiles.splice(tileIndex(tile), 1);
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
    
    public function log(msg:String):Void
    {
        label.text += msg + '\n';
        label.scroll = label.maxscroll;
    }
    
    public function clearLog():Void
    {
        label.text = '';
    }
    
   /*
    * Reposition tiles and schedule a recursive call for the next frame.
    */
    private function onWellDrag():Void
    {
        if(positionTiles())
            updateMarkers();

        wellDragTask = Reactor.callNextFrame(Delegate.create(this, this.onWellDrag));
    }
    
   /*
    * Return the point position of a tile with the given coordinate in the
    * context of the given movie clip.
    *
    * Respect infinite rows or columns, to bind movement on one (or no) axis.
    */
    private function coordinatePoint(coord:Coordinate, context:MovieClip):Point
    {
        // pick a reference tile, an arbitrary choice
        // but known to exist regardless of grid size.
        var tile:Tile = activeTiles()[0];
    
        // get the position of the reference tile.
        var point:Point = new Point(tile._x, tile._y);
        
        // make sure coord is using the same zoom level
        coord = coord.zoomTo(tile.coord.zoom);
        
        // store the infinite
        var force:Point = new Point(0, 0);
        
        if(coord.column == Number.POSITIVE_INFINITY || coord.column == Number.NEGATIVE_INFINITY) {
            force.x = coord.column;
            
        } else {
            point.x += tileWidth * (coord.column - tile.coord.column);
        
        }
        
        if(coord.row == Number.POSITIVE_INFINITY || coord.row == Number.NEGATIVE_INFINITY) {
            force.y = coord.row;
            
        } else {
            point.y += tileHeight * (coord.row - tile.coord.row);

        }
        
        well.localToGlobal(point);
        context.globalToLocal(point);
        
        if(force.x)
            point.x = force.x;
        
        if(force.y)
            point.y = force.y;
            
        return point;
    }
    
    private function pointCoordinate(point:Point):Coordinate
    {
        var tile:Tile;
        var tileCoord:Coordinate;
        var pointCoord:Coordinate;
        
        // point is assumed to be in tile grid local coordinates
        localToGlobal(point);
        well.globalToLocal(point);

        // an arbitrary reference tile, zoomed to the maximum
        tile = activeTiles()[0];
        tileCoord = tile.coord.copy();
        tileCoord = tileCoord.zoomTo(Coordinate.MAX_ZOOM);
        
        // distance in tile widths from reference tile to point
        var xTiles:Number = (point.x - tile._x) / tileWidth;
        var yTiles:Number = (point.y - tile._y) / tileHeight;

        // distance in rows & columns at maximum zoom
        var xDistance:Number = xTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.coord.zoom));
        var yDistance:Number = yTiles * Math.pow(2, (Coordinate.MAX_ZOOM - tile.coord.zoom));
        
        // new point coordinate reflecting that distance
        pointCoord = new Coordinate(Math.round(tileCoord.row + yDistance),
                                    Math.round(tileCoord.column + xDistance),
                                    tileCoord.zoom);
        
        return pointCoord.zoomTo(tile.coord.zoom);
    }
    
    public function topLeftCoordinate():Coordinate
    {
        var point:Point = new Point(0, 0);
        return pointCoordinate(point);
    }
    
    public function bottomRightCoordinate():Coordinate
    {
        var point:Point = new Point(width, height);
        return pointCoordinate(point);
    }
    
   /*
    * Start dragging the well with the mouse.
    * Calls onWellDrag().
    */
    private function getWellBounds():Bounds
    {
        var min:Point, max:Point;

        // "min" = furthest well position left & up,
        // use the location of the bottom-right limit
        min = coordinatePoint(bottomRightInLimit, this);
        min.x = well._x - min.x + width;
        min.y = well._y - min.y + height;
        
        // "max" = furthest well position right & down,
        // use the location of the top-left limit
        max = coordinatePoint(topLeftOutLimit, this);
        max.x = well._x - max.x;
        max.y = well._y - max.y;
        
        //log('min/max for drag: '+min+', '+max+' ('+topLeftOutLimit+', '+bottomRightInLimit+')');
        
        // weird negative edge conditions, limit all movement on an axis
        if(min.x > max.x)
            min.x = max.x = well._x;

        if(min.y > max.y)
            min.y = max.y = well._y;
            
        return new Bounds(min, max);
    }
    
   /*
    * Start dragging the well with the mouse.
    * Calls onWellDrag().
    */
    private function startWellDrag():Void
    {
        var bounds:Bounds = getWellBounds();
        
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
                                
        //log('Drag bounds would be: '+xMin+', '+yMin+', '+xMax+', '+yMax);
        
        well.startDrag(false, xMin, yMin, xMax, yMax);
        onWellDrag();
    }
    
   /*
    * Stop dragging the well with the mouse.
    * Halts wellDragTask.
    */
    private function stopWellDrag():Void
    {
        wellDragTask.cancel();
        well.stopDrag();

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }
    
    public function zoomBy(amount:Number, redraw:Boolean):Void
    {
        if(!tiles)
            return;
        
        if(amount > 0 && zoomLevel >= bottomRightInLimit.zoom && Math.round(well._xscale) >= 100)
            return;
    
        if(amount < 0 && zoomLevel <= topLeftOutLimit.zoom && Math.round(well._xscale) <= 100)
            return;
    
        well._xscale *= Math.pow(2, amount);
        well._yscale *= Math.pow(2, amount);
        
        if(redraw) {
            normalizeWell();
            allocateTiles();
            log('New well scale: '+well._xscale.toString());
        }
    }
    
    public function resizeTo(bottomRight:Point):Void
    {
        width = bottomRight.x;
        height = bottomRight.y;

        redraw();

        if(!tiles)
            return;
        
        centerWell(false);
        allocateTiles();
    }
    
    public function panRight(pixels:Number):Void
    {
        if(!tiles)
            return;
        
        well._x -= pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }
 
    public function panLeft(pixels:Number):Void
    {
        if(!tiles)
            return;
        
        well._x += pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    } 
 
    public function panUp(pixels:Number):Void
    {
        if(!tiles)
            return;
        
        well._y += pixels;

        if(positionTiles())
            updateMarkers();

        centerWell(true);
    }      
    
    public function panDown(pixels:Number):Void
    {
        if(!tiles)
            return;
        
        well._y -= pixels;

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
        
        for(var i:Number = 0; i < tiles.length; i += 1)
            if(tiles[i].isActive())
                matches.push(tiles[i]);

        return matches;
    }

   /**
    * Find the given tile in the tiles array.
    */
    private function tileIndex(tile:Tile):Number
    {
        for(var i:Number = 0; i < tiles.length; i += 1)
            if(tiles[i] == tile)
                return i;

        return -1;
    }

   /**
    * Determine the number of tiles needed to cover the current grid,
    * and add rows and columns if necessary. Finally, position new tiles.
    */
    private function allocateTiles():Void
    {
        if(!tiles)
            return;
        
        // internal pixel dimensions of well, compensating for scale
        var wellWidth:Number  = (100 / well._xscale) * width;
        var wellHeight:Number = (100 / well._yscale) * height;

        var targetCols:Number = Math.ceil(wellWidth  / tileWidth)  + 1 + 2 * tileBuffer;
        var targetRows:Number = Math.ceil(wellHeight / tileHeight) + 1 + 2 * tileBuffer;

        // grid can't drop below 1 x 1
        targetCols = Math.max(1, targetCols);
        targetRows = Math.max(1, targetRows);

        // change column count to match target
        while(columns != targetCols) {
            if(columns < targetCols) {
                pushTileColumn();

            } else if(columns > targetCols) {
                popTileColumn();

            }
        }

        // change row count to match target
        while(rows != targetRows) {
            if(rows < targetRows) {
                pushTileRow();

            } else if(rows > targetRows) {
                popTileRow();

            }
        }

        if(positionTiles())
            updateMarkers();
    }
    
   /**
    * Adjust position of the well, so it stays in the center.
    * Optionally, compensate tile positions to prevent
    * visual discontinuity.
    */
    private function centerWell(adjustTiles:Boolean):Void
    {
        var center:Point = new Point((width/2), (height/2));
        
        var xAdjustment:Number = well._x - center.x;
        var yAdjustment:Number = well._y - center.y;

        well._x -= xAdjustment;
        well._y -= yAdjustment;
        
        if(!tiles)
            return;
        
        if(adjustTiles) {
            for(var i:Number = 0; i < tiles.length; i += 1) {
                tiles[i]._x += xAdjustment * 100 / well._xscale;
                tiles[i]._y += yAdjustment * 100 / well._xscale;
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
        if(!tiles)
            return;
        
        var zoomAdjust:Number, scaleAdjust:Number;
        var active:/*Tile*/Array;
        
        // just in case?
        centerWell(true);

        if(Math.abs(well._xscale - 100) < 1) {
            active = activeTiles();
        
            // set to 100% if within 99% - 101%
            well._xscale = well._yscale = 100;
            
            active.sort(compareTileRowColumn);
            
            // lock the tiles back to round-pixel positions
            active[0]._x = Math.round(active[0]._x);
            active[0]._y = Math.round(active[0]._y);
            
            for(var i:Number = 1; i < active.length; i += 1) {
                active[i]._x = active[0]._x + (active[i].coord.column - active[0].coord.column) * tileWidth;
                active[i]._y = active[0]._y + (active[i].coord.row    - active[0].coord.row)    * tileHeight;
            
                //log(active[i].toString()+' at '+active[i]._x+', '+active[i]._y+' vs. '+active[0].toString());
            }

        } else if(Math.floor(well._xscale) <= 60 || Math.ceil(well._xscale) >= 165) {
            // split or merge tiles if outside of 60% - 165%

            // zoom adjust: base-2 logarithm of the scale
            // see http://mathworld.wolfram.com/Logarithm.html (15)
            zoomAdjust = Math.round(Math.log(well._xscale / 100) / Math.log(2));
            scaleAdjust = Math.pow(2, zoomAdjust);
        
            log('This is where we scale the whole well by '+zoomAdjust+' zoom levels: '+(100 / scaleAdjust)+'%');

            for(var i:Number = 0; i < zoomAdjust; i += 1) {
                splitTiles();
                zoomLevel += 1;
            }
                
            for(var i:Number = 0; i > zoomAdjust; i -= 1) {
                mergeTiles();
                zoomLevel -= 1;
            }
                
            well._xscale /= scaleAdjust;
            well._yscale /= scaleAdjust;
            
            for(var i:Number = 0; i < tiles.length; i += 1) {
                tiles[i]._x *= scaleAdjust;
                tiles[i]._y *= scaleAdjust;

                tiles[i]._xscale *= scaleAdjust;
                tiles[i]._yscale *= scaleAdjust;
            }
        
            log('Scaled to '+zoomLevel+', '+well._xscale+'%');
            markers.indexAtZoom(zoomLevel);
        }
    }
    
   /**
    * How many milliseconds before condemned tiles are destroyed?
    */
    private function condemnationDelay():Number
    {
        // half a second for each tile, plus five seconds overhead
        return (5 + .5 * rows * columns) * 1000;
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
        
        for(var i:Number = tiles.length - 1; i >= 0; i -= 1) {
            if(tiles[i].isActive()) {
                // remove old tile
                tiles[i].expire();
                condemnedTiles.push(tiles[i]);

                // save for later (you only need one)
                referenceTile = tiles[i];
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
            
            newTile = createTile(referenceTile);
            newTile.coord = newTile.coord.zoomBy(1);
            
            if(xOffset)
                newTile.coord = newTile.coord.right();
            
            if(yOffset)
                newTile.coord = newTile.coord.down();

            newTile._x = referenceTile._x + (xOffset * tileWidth / 2);
            newTile._y = referenceTile._y + (yOffset * tileHeight / 2);

            newTile._xscale = newTile._yscale = referenceTile._xscale / 2;
            newTile.redraw();
        }

        // The remaining tiles get taken care of later
        rows = 2;
        columns = 2;
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
    
        tiles.sort(compareTileRowColumn);

        for(var i:Number = tiles.length - 1; i >= 0; i -= 1) {
            if(tiles[i].isActive()) {
                // remove old tile
                tiles[i].expire();
                condemnedTiles.push(tiles[i]);

                if(tiles[i].coord.zoomBy(-1).isEdge()) {
                    // save for later (you only need one)
                    referenceTile = tiles[i];
                }
            }
        }

        Reactor.callLater(condemnationDelay(), Delegate.create(this, this.destroyTiles), condemnedTiles);
    
        // this should never happen
        if(!referenceTile)
            return;

        // we are only interested in tiles that are edges for this zoom
        newTile = createTile(referenceTile);
        newTile.coord = newTile.coord.zoomBy(-1);
        
        newTile._x = referenceTile._x;
        newTile._y = referenceTile._y;

        newTile._xscale = newTile._yscale = referenceTile._xscale * 2;
        newTile.redraw();

        // The remaining tiles get taken care of later
        rows = 1;
        columns = 1;
    }
    
   /**
    * Determine if any tiles have wandered too far to the right, left,
    * top, or bottom, and shunt them to the opposite side if needed.
    * Return true if any tiles have been repositioned.
    */
    private function positionTiles():Boolean
    {
        if(!tiles)
            return false;
        
        var tile:Tile;
        var point:Point;
        var active:/*Tile*/Array = activeTiles();
        
        // if any tile is moved...
        var touched:Boolean = false;
        
        point = new Point(0, 0);
        this.localToGlobal(point);
        well.globalToLocal(point); // all tiles are attached to well
        
        var xMin:Number = point.x - (1 + tileBuffer) * tileWidth;
        var yMin:Number = point.y - (1 + tileBuffer) * tileHeight;
        
        point = new Point(width, height);
        this.localToGlobal(point);
        well.globalToLocal(point); // all tiles are attached to well
        
        var xMax:Number = point.x + (0 + tileBuffer) * tileWidth;
        var yMax:Number = point.y + (0 + tileBuffer) * tileHeight;
        
        for(var i:Number = 0; i < active.length; i += 1) {
        
            tile = active[i];
            
            // only interested in moving active tiles
            if(!tile.isActive())
                break;
            
            if(tile._y < yMin) {
                // too far up
                tile.panDown(rows);
                tile._y += rows * tileHeight;
                touched = true;

            } else if(tile._y > yMax) {
                // too far down
                if((tile._y - rows * tileHeight) > yMin) {
                    // moving up wouldn't put us too far
                    tile.panUp(rows);
                    tile._y -= rows * tileHeight;
                    touched = true;
                }
            }
            
            if(tile._x < xMin) {
                // too far left
                tile.panRight(columns);
                tile._x += columns * tileWidth;
                touched = true;

            } else if(tile._x > xMax) {
                // too far right
                if((tile._x - columns * tileWidth) > xMin) {
                    // moving left wouldn't put us too far
                    tile.panLeft(columns);
                    tile._x -= columns * tileWidth;
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
                /*
                TODO:
                Throw an event here indicating that newOverlappingMarkers[id]
                now overlaps the tile grid, and should be tracked externally.
                */
                __overlappingMarkers[id] = true;
            }
        }
        
        for(var id:String in __overlappingMarkers) {
            if(!newOverlappingMarkers[id] && __overlappingMarkers[id]) {
                /*
                TODO:
                Throw an event here indicating that newOverlappingMarkers[id]
                no longer overlaps the tile grid, and should be ignored.
                */
                delete __overlappingMarkers[id];
            }
        }
    }
    
   /**
    * Add a new row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function pushTileRow():Void
    {
        var lastTile:Tile;
        var newTileParams:Object;
        var active:/*Tile*/Array = activeTiles();
        
        active.sort(compareTileRowColumn);
        
        for(var i:Number = active.length - columns; i < rows * columns; i += 1) {
        
            lastTile = active[i];
        
            newTileParams = {grid:  lastTile.grid,  coord:  lastTile.coord.down(),
                             _x:    lastTile._x,    _y:     lastTile._y + lastTile.height,
                             width: tileWidth,      height: tileHeight};

            createTile(newTileParams);
        }
        
        rows += 1;
    }

   /**
    * Remove a row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function popTileRow():Void
    {
        var active:/*Tile*/Array = activeTiles();

        active.sort(compareTileRowColumn);

        while(active.length > columns * (rows - 1))
            destroyTile(Tile(active.pop()));
                                         
        rows -= 1;
    }

   /**
    * Add a new column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function pushTileColumn():Void
    {
        var lastTile:Tile;
        var newTileParams:Object;
        var active:/*Tile*/Array = activeTiles();
        
        active.sort(compareTileColumnRow);
        
        for(var i:Number = active.length - rows; i < rows * columns; i += 1) {
        
            lastTile = active[i];
        
            newTileParams = {grid:  lastTile.grid,                  coord:  lastTile.coord.right(),
                             _x:    lastTile._x + lastTile.width,   _y:     lastTile._y,
                             width: tileWidth,                      height: tileHeight};

            createTile(newTileParams);
        }
        
        columns += 1;
    }

   /**
    * Remove a column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function popTileColumn():Void
    {
        var active:/*Tile*/Array = activeTiles();

        active.sort(compareTileColumnRow);

        while(active.length > rows * (columns - 1))
            destroyTile(Tile(active.pop()));

        columns -= 1;
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
        if(a.coord.row == b.coord.row) {
            return a.coord.column - b.coord.column;
            
        } else {
            return a.coord.row - b.coord.row;
            
        }
    }
    
   /**
    * Comparison function for sorting tiles by column, then row, i.e. vertically.
    */
    private static function compareTileColumnRow(a:Tile, b:Tile):Number
    {
        if(a.coord.column == b.coord.column) {
            return a.coord.row - b.coord.row;
            
        } else {
            return a.coord.column - b.coord.column;
            
        }
    }
    
    public function repaintTiles():Void
    {
        var active:/*Tile*/Array = activeTiles();
        
        for(var i:Number = 0; i < active.length; i += 1)
            active[i].paint(mapProvider, active[i].coord);
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
        moveTo(0, 0);
        lineStyle(2, 0x990099, 100);
        beginFill(0x666666, 100);
        lineTo(0, height);
        lineTo(width, height);
        lineTo(width, 0);
        lineTo(0, 0);
        endFill();
        
        mask.clear();
        mask.moveTo(0, 0);
        mask.lineStyle(2, 0x990099, 100);
        mask.beginFill(0x000000, 0);
        mask.lineTo(0, height);
        mask.lineTo(width, height);
        mask.lineTo(width, 0);
        mask.lineTo(0, 0);
        mask.endFill();
        
        // note that well (0, 0) is grid center.
        well.clear();
        well.moveTo(width/-2, height/-2);
        well.lineStyle();
        well.beginFill(0x666666, 100);
        well.lineTo(width/-2, height/2);
        well.lineTo(width/2, height/2);
        well.lineTo(width/2, height/-2);
        well.lineTo(width/-2, height/-2);
        well.endFill();
        
        label.textColor = 0xFF6600;
        label._width = width - 20;
        label._height = height - 20;
    }
}
