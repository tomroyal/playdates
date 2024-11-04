-- day 4
-- spooky ghosty on the map

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Animated sprite library
-- https://github.com/Whitebrim/AnimatedSprite
import "/Lib/AnimatedSprite.lua"

local gfx <const> = playdate.graphics

local bgSpriteSheet = nil -- this will be the image table
local map = nil -- this is the tile map

-- mock up basic level
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
	    table.insert(myLevel, 4) -- black so we can see
    end       
end  

function initBg() 
    -- load spritesheet, and check it exists
    bgSpriteSheet = gfx.imagetable.new("Images/bg-table-16-16.png")
    assert( bgSpriteSheet )
    -- define map
    map = gfx.tilemap.new()
    -- assign images
    map:setImageTable(bgSpriteSheet)
    -- def map size
    map:setSize(15,15)
    -- build output from myLevel, 15 blocks across
    map:setTiles(myLevel, 15)

    -- convert that map to a sprite for drawing
    backgroundSprite = gfx.sprite.new(map) -- map to sprite
    backgroundSprite:setCenter(0, 0)
    backgroundSprite:moveTo(80, 0) -- center on screen
    backgroundSprite:setZIndex(-1) -- behind player sprite
    backgroundSprite:add()
end

function initGhost()
    -- Set up the player sprite - animated ghosty
    ghostTable = playdate.graphics.imagetable.new('Images/ghost')
    assert( ghostTable )
    playerSprite = AnimatedSprite.new(ghostTable)
    playerSprite:playAnimation()
    playerSprite:setCenter(0, 0)
    playerSprite:moveTo( 96, 16 )  
    playerSprite:add() 
end    

initBg()
initGhost()

-- temp
local testDirection = "r"

function playdate.update()
    
    -- move the ghosty just to see..
    if testDirection == "r" then
        if playerSprite.x < 288 then
            playerSprite:moveBy( 4, 4 )
        else 
            testDirection = "l"
        end
    else    
        if playerSprite.x > 96 then
            playerSprite:moveBy( -4, -4 )
        else 
            testDirection = "r"
        end
    end    
    
    
    
    -- update sprite
    gfx.sprite.update()
   
end 