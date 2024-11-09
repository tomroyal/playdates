-- day 7
-- pdc ./day7/Source/main.lua ./compiled/day7.pdx

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
-- import "CoreLibs/timer"

-- Animated sprite library
-- https://github.com/Whitebrim/AnimatedSprite
import "/Lib/AnimatedSprite.lua"

local gfx <const> = playdate.graphics

local bgSpriteSheet = nil -- this will be the image table
local map = nil -- this is the tile map-- temp
local topLeft = 80 -- how far offset from left of screen is the map?
local gameScore = 0 -- everyone loves a score
local playerDirection = "n" -- none, or u/d/l/r

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
    -- utility function to find "is sprite exactly on a grid tile"
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

function readInput()
    -- read the D pad
    local inputDirection = "n"
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        inputDirection = "u" 
    elseif playdate.buttonIsPressed( playdate.kButtonRight ) then
        inputDirection = "r" 
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
        inputDirection = "d" 
    elseif playdate.buttonIsPressed( playdate.kButtonLeft ) then
        inputDirection = "l" 
    end  
    return inputDirection
end    

function checkForOpenPath(mapRefX,mapRefY,requestedDir) 
    -- calculate the grid ref targeted by the requested direction
    -- then check if it is possible to move into that space
    local targetRefX = mapRefX
    local targetRefY = mapRefY
    if requestedDir == "l" then
        targetRefX = targetRefX - 1
    elseif requestedDir == "r" then
        targetRefX = targetRefX + 1
    elseif requestedDir == "u" then
        targetRefY = targetRefY - 1
    elseif requestedDir == "d" then
        targetRefY = targetRefY + 1
    end
    -- check for edge of grid
    if (targetRefX < 1 or targetRefX > 15 or targetRefY < 1 or targetRefY > 15) then
        -- target out of bounds
        return false
    end    
    -- check for wall
    if map:getTileAtPosition(targetRefX,targetRefY) == 1 then
        -- target is a wall
        return false
    end      
    return true
end


function moveGhosty()
        -- called once per loop
        -- are we on a new square?
        if isMultipleOf(playerSprite.x - topLeft,16) then
            if isMultipleOf(playerSprite.y,16) then
                -- exactly on a square!

                -- calculate the grid ref of where we are
                local mapRefX = ((playerSprite.x-topLeft)/16)+1
                local mapRefY = (playerSprite.y/16)+1

                -- check if we need to eat, and maybe do that
                checkForEat(mapRefX,mapRefY)

                -- check for collision with wall on current path
                if checkForOpenPath(mapRefX,mapRefY,playerDirection) then
                    -- how the honking fuck do you do "if false"?
                    -- anyhow nothing to see here
                else    
                    -- stop!
                    playerDirection = "n"
                end    

                -- check if we need to change direction, and maybe do that
                local requestedDir = readInput()
                if (playerDirection ~= requestedDir and requestedDir ~= "n") then                    
                    -- != is  ~= for some reason?
                    -- change direction requested, but is that possible?
                    if checkForOpenPath(mapRefX,mapRefY,requestedDir) then
                        -- yup change direction
                        playerDirection = requestedDir
                    end    
                end                
            end    
        end 
        
        -- finally, move!
        local moveSpeed = 1 -- how many pixels per cycle?

        local moveByX = 0
        local moveByY = 0
        if playerDirection == "u" then
            moveByY  = 0 - moveSpeed
        elseif playerDirection == "d" then
            moveByY = moveSpeed
        elseif playerDirection == "l" then
            moveByX = 0 - moveSpeed
        elseif playerDirection == "r" then
            moveByX = moveSpeed
        end    

        playerSprite:moveBy(moveByX, moveByY )

end        

initBg()
initGhost()

function playdate.update()
    moveGhosty(); 
    
    -- update sprite
    gfx.sprite.update()
    -- playdate.timer.updateTimers()
end 