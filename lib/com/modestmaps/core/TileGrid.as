import com.modestmaps.core.Coordinate;
import com.modestmaps.core.Bounds;
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

    // Real maps use 256.
    private var tileWidth:Number = 256;
    private var tileHeight:Number = 256;
    
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
    public var mapProvider:IMapProvider;

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
        
        // impose some limits
        zoomLevel = 11;
        topLeftOutLimit = new Coordinate(Number.NEGATIVE_INFINITY, Number.NEGATIVE_INFINITY, 0);
        bottomRightInLimit = new Coordinate(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, Coordinate.MAX_ZOOM);
        
        // initial tile centers the map on the SF Bay Area
        var initObj : Object =
        { 
            origin: true, 
            grid: this, 
            width: tileWidth, 
            height: tileHeight,
            coord: new Coordinate(791, 328, zoomLevel)
        };
        
        tiles = [createTile(initObj)];
                                                                  
        rows = 1;
        columns = 1;
        
        // buffer must not be negative!
        tileBuffer = Math.max(0, tileBuffer);
        
        allocateTiles();
        redraw();   
        
        labelContainer.swapDepths( getNextHighestDepth() );    
    }
    
   /**
    * Create the well clip, assign event handlers.
    */
    public function buildWell():Void
    {
        well = createEmptyMovieClip('well', 1);
        well.onPress = Delegate.create(this, this.startWellDrag);
        well.onRelease = Delegate.create(this, this.stopWellDrag);
        well.onReleaseOutside = Delegate.create(this, this.stopWellDrag);
        
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
    public function buildMask():Void
    {
        mask = createEmptyMovieClip('mask', getNextHighestDepth());
        well.setMask(mask);
    }
    
   /**
    * Create a new tile and return it, but don't add it to tiles array.
    */
    private function createTile(tileParams:Object):Tile
    {
        var tile:Tile;

        tile = Tile(well.attachMovie(Tile.symbolName, 'tile'+well.getNextHighestDepth(), well.getNextHighestDepth(), tileParams));
        tile.redraw();
        
        return tile;
    }
    
   /**
    * Destroy an old tile, but don't remove it from tiles array.
    */
    private function destroyTile(tile:Tile):Void
    {
        tile.destroy();
        tile.removeMovieClip();
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
        positionTiles();
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
        var tile:Tile = tiles[0];
    
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
        
        // an arbitrary reference tile, zoomed to the maximum
        tile = tiles[0];
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
        
        localToGlobal(point);
        well.globalToLocal(point);
        
        return pointCoordinate(point);
    }
    
    public function bottomRightCoordinate():Coordinate
    {
        var point:Point = new Point(width, height);
        
        localToGlobal(point);
        well.globalToLocal(point);
        
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
        positionTiles();
        centerWell(true);
    }
    
    public function zoomIn(amount:Number):Void
    {
        if(zoomLevel >= bottomRightInLimit.zoom && Math.round(well._xscale) >= 100)
            return;
    
        well._xscale *= Math.pow(2, amount);
        well._yscale *= Math.pow(2, amount);
        
        normalizeWell();
        allocateTiles();
        positionTiles();
        
        log('New well scale: '+well._xscale.toString());
    }
    
    public function zoomOut(amount:Number):Void
    {
        if(zoomLevel <= topLeftOutLimit.zoom && Math.round(well._xscale) <= 100)
            return;
    
        well._xscale /= Math.pow(2, amount);
        well._yscale /= Math.pow(2, amount);
        
        normalizeWell();
        allocateTiles();
        positionTiles();
        
        log('New well scale: '+well._xscale.toString());
    }

    public function resizeTo(bottomLeft:Point):Void
    {
        width = bottomLeft.x;
        height = bottomLeft.y;

        centerWell(false);
        allocateTiles();
        positionTiles();
        redraw();
    }
    
    public function panRight(pixels:Number):Void
    {
        well._x -= pixels;
        positionTiles();
        centerWell(true);
    }
 
    public function panLeft(pixels:Number):Void
    {
        well._x += pixels;
        positionTiles();
        centerWell(true);
    } 
 
    public function panUp(pixels:Number):Void
    {
        well._y += pixels;
        positionTiles();
        centerWell(true);
    }      
    
    public function panDown(pixels:Number):Void
    {
        well._y -= pixels;
        positionTiles();
        centerWell(true);
    }

   /**
    * Find out whether a tile is at the grid's native zoom level.
    */
    private function nativeZoom(tile:Tile):Boolean
    {
        return (tile.coord.zoom == zoomLevel);
    }

   /**
    * Determine the number of tiles needed to cover the current grid,
    * and add rows and columns if necessary.
    */
    private function allocateTiles():Void
    {
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
        var zoomAdjust:Number, scaleAdjust:Number;
        
        // just in case?
        centerWell(true);

        if(Math.abs(well._xscale - 100) < 1) {
            // set to 100% if within 99% - 101%
            well._xscale = well._yscale = 100;
            
            tiles.sort(compareTileRowColumn);
            
            // lock the tiles back to round-pixel positions
            tiles[0]._x = Math.round(tiles[0]._x);
            tiles[0]._y = Math.round(tiles[0]._y);
            
            for(var i:Number = 1; i < tiles.length; i += 1) {
                tiles[i]._x = tiles[0]._x + (tiles[i].coord.column - tiles[0].coord.column) * tileWidth;
                tiles[i]._y = tiles[0]._y + (tiles[i].coord.row    - tiles[0].coord.row)    * tileHeight;
            
                log(tiles[i].toString()+' at '+tiles[i]._x+', '+tiles[i]._y+' vs. '+tiles[0].toString());
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
        }
    }
    
   /**
    * Do a 1-to-4 tile split: for every tile in the well, add four
    * new tiles at a higher zoom level, and remove the original.
    * Double the row & column count.
    */
    private function splitTiles():Void
    {
        var oldTile:Tile;
        var newTile:Tile;
        var xOffset:Number, yOffset:Number;
        
        for(var i:Number = tiles.length - 1; i >= 0; i -= 1) {
            oldTile = tiles[i];
            
            if(nativeZoom(oldTile)) {
                for(var q:Number = 0; q < 4; q += 1) {
                    // two-bit value into two one-bit values
                    xOffset = q & 1;
                    yOffset = (q >> 1) & 1;
                    
                    newTile = createTile(oldTile);
                    newTile.coord = newTile.coord.zoomBy(1);
                    
                    if(xOffset)
                        newTile.coord = newTile.coord.right();
                    
                    if(yOffset)
                        newTile.coord = newTile.coord.down();
    
                    newTile._x = oldTile._x + (xOffset * tileWidth / 2);
                    newTile._y = oldTile._y + (yOffset * tileHeight / 2);
    
                    newTile._xscale = newTile._yscale = oldTile._xscale / 2;
                    newTile.redraw();

                    // add newTile
                    tiles.push(newTile);
                }

                // remove oldTile
                tiles.splice(i, 1);
                destroyTile(oldTile);
            }
        }
        
        rows *= 2;
        columns *= 2;
    }
    
    private function mergeTiles():Void
    {
        var oldTile:Tile;
        var newTile:Tile;
        var rowsMerged:Number, columnsMerged:Number;
    
        tiles.sort(compareTileRowColumn);

        if(tiles[0].coord.zoomBy(-1).isRowEdge()) {
            rowsMerged = Math.ceil(rows / 2);
            
        } else {
            rowsMerged = Math.floor(rows / 2);
            
        }
        
        if(tiles[0].coord.zoomBy(-1).isColumnEdge()) {
            columnsMerged = Math.ceil(columns / 2);
            
        } else {
            columnsMerged = Math.floor(columns / 2);
            
        }

        for(var i:Number = tiles.length - 1; i >= 0; i -= 1) {
            oldTile = tiles[i];
            
            if(nativeZoom(oldTile)) {
                if(oldTile.coord.zoomBy(-1).isEdge()) {
                    // we are only interested in tiles that are edges for this zoom
                    newTile = createTile(oldTile);
                    newTile.coord = newTile.coord.zoomBy(-1);
                    
                    newTile._x = oldTile._x;
                    newTile._y = oldTile._y;
    
                    newTile._xscale = newTile._yscale = oldTile._xscale * 2;
                    newTile.redraw();

                    // add newTile
                    tiles.push(newTile);
                }

                // remove oldTile
                tiles.splice(i, 1);
                destroyTile(oldTile);
            }
        }
        
        rows = rowsMerged;
        columns = columnsMerged;
    }
    
   /**
    * Determine if any tiles have wandered too far to the right, left,
    * top, or bottom, and shunt them to the opposite side if needed.
    */
    private function positionTiles():Void
    {
        var tile:Tile;
        var point:Point;
        
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
        
        for(var i:Number = 0; i < tiles.length; i += 1) {
        
            tile = tiles[i];
            
            // only interested in moving tiles at the current zoom level
            if(!nativeZoom(tile))
                break;
            
            if(tile._y < yMin) {
                // too far up
                tile.panDown(rows);
                tile._y += rows * tileHeight;

            } else if(tile._y > yMax) {
                // too far down
                if((tile._y - rows * tileHeight) > yMin) {
                    // moving up wouldn't put us too far
                    tile.panUp(rows);
                    tile._y -= rows * tileHeight;
                }
            }
            
            if(tile._x < xMin) {
                // too far left
                tile.panRight(columns);
                tile._x += columns * tileWidth;

            } else if(tile._x > xMax) {
                // too far right
                if((tile._x - columns * tileWidth) > xMin) {
                    // moving left wouldn't put us too far
                    tile.panLeft(columns);
                    tile._x -= columns * tileWidth;
                }
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
        
        tiles.sort(compareTileRowColumn);
        
        for(var i:Number = tiles.length - columns; i < rows * columns; i += 1) {
        
            lastTile = tiles[i];
        
            newTileParams = {grid:  lastTile.grid,  coord:  lastTile.coord.down(),
                             _x:    lastTile._x,    _y:     lastTile._y + lastTile.height,
                             width: tileWidth,      height: tileHeight};

            tiles.push(createTile(newTileParams));
        }
        
        rows += 1;
    }

   /**
    * Remove a row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function popTileRow():Void
    {
        tiles.sort(compareTileRowColumn);

        while(tiles.length > columns * (rows - 1)) {
            destroyTile(Tile(tiles.pop()));
        }
                                         
        rows -= 1;
    }

   /**
    * Add a new column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function pushTileColumn():Void
    {
        var lastTile:Tile;
        var newTileParams:Object;
        
        tiles.sort(compareTileColumnRow);
        
        for(var i:Number = tiles.length - rows; i < rows * columns; i += 1) {
        
            lastTile = tiles[i];
        
            newTileParams = {grid:  lastTile.grid,                  coord:  lastTile.coord.right(),
                             _x:    lastTile._x + lastTile.width,   _y:     lastTile._y,
                             width: tileWidth,                      height: tileHeight};

            tiles.push(createTile(newTileParams));
        }
        
        columns += 1;
    }

   /**
    * Remove a column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function popTileColumn():Void
    {
        tiles.sort(compareTileColumnRow);

        while(tiles.length > rows * (columns - 1)) {
            destroyTile(Tile(tiles.pop()));
        }

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
    
    private function redraw()
    {
        clear();
        moveTo(0, 0);
        lineStyle(2, 0x990099, 100);
        lineTo(0, height);
        lineTo(width, height);
        lineTo(width, 0);
        lineTo(0, 0);
        
        mask.clear();
        mask.moveTo(0, 0);
        mask.lineStyle(2, 0x990099, 100);
        mask.beginFill(0x000000, 0);
        mask.lineTo(0, height);
        mask.lineTo(width, height);
        mask.lineTo(width, 0);
        mask.lineTo(0, 0);
        mask.endFill();
        
        label.textColor = 0xFF6600;
        label._width = width - 20;
        label._height = height - 20;
    }
}
