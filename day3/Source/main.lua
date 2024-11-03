-- day 3
-- background tile maps test
-- lots of help from:
-- https://devforum.play.date/t/has-anyone-posted-a-good-tutorial-for-tilemaps/4529/18

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local spritesheet = nil -- this will be the image table
local map = nil -- this is the tile map

-- I'm borrowing a sprite sheet from the examples for now:
-- /Developer/PlaydateSDK/Examples/Level 1-1/Source/img/bg-table-16-16.png

-- idea taken from that forum link - mock up a level by adding random tiles in the middle of a grid
-- in my case, from the top row of that image
-- finished level is 15x15 = 225
local myLevel = {}
-- arrays are 1 indexed because wtf?
local lineCounter = 0 -- used to track progress across the grid
for i = 1, 225 do
    lineCounter = lineCounter + 1
    if (lineCounter == 1) then
        table.insert(myLevel, 8)
    elseif (lineCounter == 15) then  
        table.insert(myLevel, 8)
        lineCounter = 0
    elseif (i < 16) then
        table.insert(myLevel, 8)
    elseif (i > 209) then  
        table.insert(myLevel, 8)
    else     
	    table.insert(myLevel, math.random(7))
    end       
end  

function init() 
    -- load spritesheet, and check it exists
    spritesheet = gfx.imagetable.new("Images/bg-table-16-16.png")
    assert( spritesheet )
    -- define map
    map = gfx.tilemap.new()
    -- assign images
    map:setImageTable(spritesheet)
    -- how many images in there? 8 by 8 for me
    map:setSize(15,15)
    -- build output from myLevel, 15 blocks across
    map:setTiles(myLevel, 15)
end

init()

function playdate.update()
	map:draw(80,0) -- draw the map in the middle of the display
    -- test updating one item in the map
    map:setTileAtPosition(15, 15, 1)
end 