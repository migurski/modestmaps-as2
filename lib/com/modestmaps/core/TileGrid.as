import com.modestmaps.core.Bounds;
import com.modestmaps.core.Point;
import com.modestmaps.core.Tile;

import mx.utils.Delegate;
import com.stamen.twisted.*;

class com.modestmaps.core.TileGrid extends MovieClip
{
    private var width:Number;
    private var height:Number;

    // Row and column counts are kept up-to-date, though they
    // could just as easily be read directly from the tiles array.
    private var rows:Number;
    private var columns:Number;
    private var tiles:Array;

    // TODO:
    // Real maps use 256.
    private var tileWidth:Number = 128;
    private var tileHeight:Number = 128;
    
    // some limits on scrolling distance, initially set to none
    private var rowTop:Number = -Infinity;
    private var rowBottom:Number = Infinity;
    private var columnLeft:Number = -Infinity;
    private var columnRight:Number = Infinity;

    // Tiles attach to the well.
    private var well:MovieClip;
    
    // Mask clip to hide outside edges of tiles.
    private var mask:MovieClip;
    
    // For testing purposes.
    public var label:TextField;
    
    // Active when the well is being dragged on the stage.
    private var wellDragTask:DelayedCall;
    
    // Active when the well is being zoomed on the stage.
    private var wellZoomTask:DelayedCall;
    
    // *sigh*
    private var wellCount:Number = 0;
    
    // Defines a ring of extra, masked-out tiles around
    // the edges of the well, acting as a pre-fetching cache.
    // High tileBuffer may hurt performance.
    private var tileBuffer:Number = 0;

    public static var symbolName:String = '__Packages.com.modestmaps.core.TileGrid';
    public static var symbolOwner:Function = TileGrid;
    public static var symbolLink:Boolean = Object.registerClass(symbolName, symbolOwner);

    public function TileGrid()
    {
        buildWell();
        buildMask();
        
        tiles = [[well.attachMovie(Tile.symbolName, 'tile'+well.getNextHighestDepth(), well.getNextHighestDepth(),
                                   {origin: true, grid: this, width: tileWidth, height: tileHeight})]];
                                   
        rows = 1;
        columns = 1;

        // buffer must not be negative!
        tileBuffer = Math.max(0, tileBuffer);
        
        allocateTiles();
        redraw();

        createTextField('label', getNextHighestDepth(), 10, 10, width-20, height-20);
        label.selectable = false;
        
        log('FUCK YEAH '+width+'x'+height);
        
        // TODO:
        // Figure out why positionTiles() doesn't seem to work
        // when called from here, even on a delay via the Reactor.
    }
    
   /**
    * Create the well clip, assign event handlers.
    */
    public function buildWell():Void
    {
        wellCount += 1;
        well = createEmptyMovieClip('well'+wellCount, 1);
        well.onPress = Delegate.create(this, this.startWellDrag);
        well.onRelease = Delegate.create(this, this.stopWellDrag);
        well.onReleaseOutside = Delegate.create(this, this.stopWellDrag);
    }
    
   /**
    * Create the mask clip.
    */
    public function buildMask():Void
    {
        mask = createEmptyMovieClip('mask', getNextHighestDepth());
        well.setMask(mask);
    }
    
    public function replaceTiles(newWell:MovieClip, newTiles:Array):Void
    {
        // replace old well
        newWell.swapDepths(well);
        well.removeMovieClip();
        well = newWell;
        
        // correct properties
        well.onPress = Delegate.create(this, this.startWellDrag);
        well.onRelease = Delegate.create(this, this.stopWellDrag);
        well.onReleaseOutside = Delegate.create(this, this.stopWellDrag);
        well.setMask(mask);

        tiles = newTiles;
        columns = tiles[0].length;
        rows = tiles.length;

        allocateTiles();
        positionTiles();
        
        log('Rows? '+rows+', columns? '+columns+', well? '+well._xscale+' - '+well._x);

        for(var row:Number = 0; row < rows; row += 1) {
            for(var col:Number = 0; col < columns; col += 1) {
                //log(row+', '+col+': '+tiles[row][col].toString());
            }
        }
    }
    
    public function log(msg:String):Void
    {
        label.text += msg + '\n';
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
    * Return the x, y position of a tile with the given row and column at the
    * current zoom level (whether it exists on the stage or not) in the context
    * of the given movie clip.
    *
    * Respect infinite rows or columns, to bind movement on one (or no) axis.
    */
    private function tilePosition(row:Number, column:Number, context:MovieClip):Point
    {
        // get the position of the first tile, an arbitrary
        // choice but known to exist regardless of grid size.
        var point:Point = new Point(tiles[0][0]._x, tiles[0][0]._y);
        
        // store the infinite
        var force:Point = new Point(0, 0);
        
        if(column == Infinity || column == -Infinity) {
            force.x = column;
            
        } else {
            point.x += tileWidth * (column - tiles[0][0].column);
        
        }
        
        if(row == Infinity || row == -Infinity) {
            force.y = row;
            
        } else {
            point.y += tileHeight * (row - tiles[0][0].row);

        }
        
        well.localToGlobal(point);
        context.globalToLocal(point);
        
        if(force.x)
            point.x = force.x;
        
        if(force.y)
            point.y = force.y;
            
        return point;
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
        min = tilePosition(rowBottom, columnRight, this);
        min.x = well._x - min.x + width - tileWidth;
        min.y = well._y - min.y + height - tileHeight;

        // "max" = furthest well position right & down,
        // use the location of the top-left limit
        max = tilePosition(rowTop, columnLeft, this);
        max.x = well._x - max.x;
        max.y = well._y - max.y;
        
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
        
        var xMin:Number = (bounds.min.x == Infinity)
                            ? 100000
                            : ((bounds.min.x == -Infinity)
                                ? -100000
                                : bounds.min.x);
        
        var yMin:Number = (bounds.min.y == Infinity)
                            ? 100000
                            : ((bounds.min.y == -Infinity)
                                ? -100000
                                : bounds.min.y);
        
        var xMax:Number = (bounds.max.x == Infinity)
                            ? 100000
                            : ((bounds.max.x == -Infinity)
                                ? -100000
                                : bounds.max.x);
        
        var yMax:Number = (bounds.max.y == Infinity)
                            ? 100000
                            : ((bounds.max.y == -Infinity)
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

   /*
    * TODO:
    * Size relative to stage is currently hard-coded, but shouldn't be.
    */
    public function onResize():Void
    {
        width = Stage.width - 2 * _x;
        height = Stage.height - 2 * _y;

        centerWell(false);
        allocateTiles();
        positionTiles();
        redraw();
    }
    
   /**
    * Determine the number of tiles needed to cover the current grid,
    * and add rows and columns if necessary.
    */
    private function allocateTiles():Void
    {
        // grid can't drop below 1 x 1
        var targetCols:Number = Math.max(1, Math.ceil(width / tileWidth) + 1 + 2 * tileBuffer);
        var targetRows:Number = Math.max(1, Math.ceil(height / tileHeight) + 1 + 2 * tileBuffer);

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
    * Optionally, compensate tile positions to prevent visual
    * discontinuity with respect to upper-left hand corner.
    */
    private function centerWell(adjustTiles:Boolean):Void
    {
        var center:Point = new Point((width/2), (height/2));
        
        var xAdjustment:Number = well._x - center.x;
        var yAdjustment:Number = well._y - center.y;
        
        well._x -= xAdjustment;
        well._y -= yAdjustment;
        
        if(adjustTiles) {
            for(var row:Number = 0; row < rows; row += 1) {
                for(var col:Number = 0; col < columns; col += 1) {
                    tiles[row][col]._x += xAdjustment;
                    tiles[row][col]._y += yAdjustment;
                }
            }
        }
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
        
        for(var row:Number = 0; row < rows; row += 1) {
            for(var col:Number = 0; col < columns; col += 1) {

                tile = Tile(tiles[row][col]);
                
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
    }
    
   /**
    * Add a new row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function pushTileRow():Void
    {
        var lastTile:Tile;
        var wrappedTile:Tile;
        var newTileParams:Object;
        var newTile:Tile;

        var newRow:Array = [];
        var lastRow:Array = Array(tiles[tiles.length - 1]);

        tiles.push(newRow);
        rows += 1;

        for(var col:Number = 0; col < columns; col += 1) {
            lastTile = Tile(lastRow[col]);
            
            newTileParams = {grid:  lastTile.grid,      zoom:   lastTile.zoom,
                             row:   lastTile.row + 1,   column: lastTile.column,
                             _x:    lastTile._x,        _y:     lastTile._y + lastTile.height,
                             width: tileWidth,          height: tileHeight};
            
            newTile = Tile(well.attachMovie(Tile.symbolName, 'tile'+well.getNextHighestDepth(), well.getNextHighestDepth(), newTileParams));

            newRow.push(newTile);
            
            // shunt conflicting tiles down in this column, if necessary
            for(var row:Number = 0; row < tiles.length; row += 1) {
                wrappedTile = Tile(tiles[row][col]);
                
                if(wrappedTile.row < newTile.row) {
                    break;
                }
                
                wrappedTile.row += 1;
                wrappedTile._y += newTile.height;
                wrappedTile.redraw();
            }
        }
    }

   /**
    * Remove a row of tiles, adjust other rows so that visual transition is seamless.
    */
    private function popTileRow():Void
    {
        var wrappedTile:Tile;
        var oldTile:Tile;
                                         
        var oldRow:Array = Array(tiles.pop());
        rows -= 1;
        
        for(var col:Number = 0; col < columns; col += 1) {
            oldTile = Tile(oldRow[col]);
            
            // shunt stranded tiles up in this column, if necessary
            for(var row:Number = 0; row < tiles.length; row += 1) {
                wrappedTile = Tile(tiles[row][col]);
                
                if(wrappedTile.row < oldTile.row) {
                    break;
                }
                
                wrappedTile.row -= 1;
                wrappedTile._y -= oldTile.height;
                wrappedTile.redraw();
            }

            oldTile.removeMovieClip();
        }
    }

   /**
    * Add a new column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function pushTileColumn():Void
    {
        var lastTile:Tile;
        var wrappedTile:Tile;
        var newTileParams:Object;
        var newTile:Tile;

        var currentRow:Array;
        columns += 1;
    
        for(var row:Number = 0; row < rows; row += 1) {
            currentRow = tiles[row];
            lastTile = Tile(currentRow[currentRow.length - 1]);
        
            newTileParams = {grid:  lastTile.grid,                  zoom:   lastTile.zoom,
                             row:   lastTile.row,                   column: lastTile.column + 1,
                             _x:    lastTile._x + lastTile.width,   _y:     lastTile._y,
                             width: tileWidth,                      height: tileHeight};

            newTile = Tile(well.attachMovie(Tile.symbolName, 'tile'+well.getNextHighestDepth(), well.getNextHighestDepth(), newTileParams));
            
            currentRow.push(newTile);
            
            // shunt conflicting tiles to the right in this row, if necessary
            for(var col:Number = 0; col < currentRow.length; col += 1) {
                wrappedTile = Tile(currentRow[col]);
            
                if(wrappedTile.column < newTile.column) {
                    break;
                }

                wrappedTile.column += 1;
                wrappedTile._x += newTile.width;
                wrappedTile.redraw();
            }
        }
    }

   /**
    * Remove a column of tiles, adjust other columns so that visual transition is seamless.
    */
    private function popTileColumn():Void
    {
        var wrappedTile:Tile;
        var currentRow:Array;
        var oldTile:Tile;
        
        columns -= 1;

        for(var row:Number = 0; row < rows; row += 1) {
            currentRow = tiles[row];
            oldTile = Tile(currentRow.pop());
            
            // shunt stranded tiles to the left in this row, if necessary
            for(var col:Number = 0; col < currentRow.length; col += 1) {
                wrappedTile = Tile(currentRow[col]);
            
                if(wrappedTile.column < oldTile.column) {
                    break;
                }

                wrappedTile.column -= 1;
                wrappedTile._x -= oldTile.width;
                wrappedTile.redraw();
            }

            oldTile.removeMovieClip();
        }
    }
    
    private static function compareDistanceFrom(p:Point):Function
    {
        return function(a:Tile, b:Tile):Number
        {
            var aDist:Number = Math.sqrt(Math.pow(a.center().x - p.x, 2) + Math.pow(a.center().y - p.y, 2));
            var bDist:Number = Math.sqrt(Math.pow(b.center().x - p.x, 2) + Math.pow(b.center().y - p.y, 2));
            return aDist - bDist;
        }
    }
    
    private static function compareRowColumn(a:Tile, b:Tile):Number
    {
        if(a.row == b.row) {
            return a.column - b.column;
            
        } else {
            return a.row - b.row;
            
        }
    }
    
   /**
    * Return a flat array of all tiles, ordered by distance from center of well.
    */
    private function tilesFromCenter():/*Tile*/Array
    {
        var tiles:/*Tile*/Array = [];
        
        for(var row:Number = 0; row < rows; row += 1)
            for(var col:Number = 0; col < columns; col += 1)
                tiles.push(this.tiles[row][col]);
                
        tiles.sort(compareDistanceFrom(new Point(0, 0)));
        
        return tiles;
    }
    
   /**
    * Return a flat array of all tiles, ordered by row, column.
    */
    private function tilesByRowColumn():/*Tile*/Array
    {
        var tiles:/*Tile*/Array = [];
        
        for(var row:Number = 0; row < rows; row += 1)
            for(var col:Number = 0; col < columns; col += 1)
                tiles.push(this.tiles[row][col]);
                
        tiles.sort(compareRowColumn);
        
        return tiles;
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
        
        label._width = width - 20;
        label._height = height - 20;
    }
}
