-- day 6
-- getting the munchies

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
local topLeft = 80 -- how far offset from left of screen is the map?
local gameScore = 0 -- everyone loves a score
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
    backgroundSprite:moveTo(topLeft, 0) -- center on screen
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
    playerSprite:moveTo( (topLeft + 16), 16 )  
    playerSprite:add() 
end    

function isMultipleOf(testThis,divideBy)
    if (testThis/divideBy == math.floor(testThis/divideBy)) then 
        return true
    else
        return false
    end    
end

function updateScore(incBy)
    gameScore = gameScore + incBy
    -- todo update on screen
    print('Score update: '..gameScore)
end    

function checkForEat(gridX,gridY)
    -- check: is there a dot there? If so, we eat it

    gridX = math.floor(gridX) -- cast to int in an ugly way
    gridY = math.floor(gridY) -- cast to int in an ugly way

    if map:getTileAtPosition(gridX,gridY) == 3 then   
        -- on a dot! chompy time
        updateScore(100)
        -- remove it
        map:setTileAtPosition(gridX, gridY, 2)
    end    
end    

function moveGhosty()
        -- move the ghosty just to see..
        if testDirection == "r" then
            if playerSprite.x < (208+topLeft) then
                playerSprite:moveBy( 4, 0 )
            else 
                testDirection = "l"
            end
        else    
            if playerSprite.x > (16+topLeft) then
                playerSprite:moveBy( -4, 0 )
            else 
                testDirection = "r"
            end
        end  

        -- are we on a new square?
        if isMultipleOf(playerSprite.x - topLeft,16) then
            if isMultipleOf(playerSprite.y,16) then
                -- exactly on a square
                checkForEat(((playerSprite.x-topLeft)/16)+1,(playerSprite.y/16)+1)
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
        moveGhosty();
    end    
    
    -- update sprite
    gfx.sprite.update()
    playdate.timer.updateTimers()
end 