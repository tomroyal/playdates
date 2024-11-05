-- day 5
-- a proper map, and a proper timer

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Animated sprite library
-- https://github.com/Whitebrim/AnimatedSprite
import "/Lib/AnimatedSprite.lua"

local gfx <const> = playdate.graphics

local bgSpriteSheet = nil -- this will be the image table
local map = nil -- this is the tile map-- temp

local testDirection = "r"

-- mock up basic level
-- real pacman is much bigger, but this will do for now
-- 1 = wall, 2 = blank, 3 = blob

local myLevel = {
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,1,
    1,3,1,1,1,1,3,1,3,1,1,1,1,3,1,
    1,3,1,3,3,3,3,1,3,3,3,3,1,3,1,
    1,3,1,3,1,1,1,1,1,1,1,3,1,3,1,
    1,3,1,3,3,3,3,3,3,3,3,3,1,3,1,
    1,3,3,3,1,1,1,2,1,1,1,3,3,3,1,
    1,3,1,3,1,2,2,2,2,2,1,3,1,3,1,
    1,3,1,3,1,1,1,1,1,1,1,3,1,3,1,
    1,3,1,3,3,3,3,3,3,3,3,3,1,3,1,
    1,3,1,1,1,3,1,3,1,3,1,1,1,3,1,
    1,3,3,3,3,3,1,3,1,3,3,3,3,3,1,
    1,3,1,1,1,1,1,3,1,1,1,1,1,3,1,
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
}

-- arrays are 1 indexed because wtf?



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

function moveGhosty()
        -- move the ghosty just to see..
        if testDirection == "r" then
            if playerSprite.x < 288 then
                playerSprite:moveBy( 4, 0 )
            else 
                testDirection = "l"
            end
        else    
            if playerSprite.x > 96 then
                playerSprite:moveBy( -4, 0 )
            else 
                testDirection = "r"
            end
        end  
end        

initBg()
initGhost()

-- init a timer for speed control
t = playdate.timer.new(1000) -- init a timer
t.repeats = true -- just in case..?
local ghostSpeed = 40 -- as a test

function playdate.update()
       
    if t.currentTime > ghostSpeed then
        moveGhosty()
        -- accelerate speed a bit
        if ghostSpeed > 0 then
            ghostSpeed = (ghostSpeed - 0.25)
        end
        t:reset()
    end    
    
    -- update sprite
    gfx.sprite.update()
    playdate.timer.updateTimers()
end 