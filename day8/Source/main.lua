-- day 8
-- ghosty AI, wooo
-- pdc ./day8/Source/main.lua ./compiled/day8.pdx

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
local enemyDirections = {"l"} -- an array, as we may have multiple enemies in future
local enemySprites = {}

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

function initPlayer(ghostTable)
    -- Set up the player sprite - animated ghosty
    
    playerSprite = AnimatedSprite.new(ghostTable)
    playerSprite:playAnimation()
    playerSprite:setCenter(0, 0)
    playerSprite:moveTo( (topLeft + 16), 16 )  
    playerSprite:add() 
end    

function initEnemy(ghostTable)
    -- Set up the enemy sprite - also an animated ghosty, for now!
    enemySprite = AnimatedSprite.new(ghostTable)
    enemySprite:playAnimation()
    enemySprite:setCenter(0, 0)
    enemySprite:moveTo( (topLeft + (9*16)), (7*16) )  
    enemySprite:add()
    table.insert(enemySprites,enemySprite)
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
    -- print(map:getTileAtPosition(targetRefX,targetRefY))
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

function moveEnemy()
    -- iterate enemies
    local hasChanged = false
    for i, v in ipairs(enemyDirections) do
        -- print ("do enemy "..i)
        -- referring to enemy sprite i
        -- check if on a grid square
        if isMultipleOf(enemySprites[i].x - topLeft,16) then
            if isMultipleOf(enemySprites[i].y,16) then
                -- enemy i is on a square
                -- get grid ref
                local mapRefX = ((enemySprites[i].x-topLeft)/16)+1
                local mapRefY = (enemySprites[i].y/16)+1

                print("ghosty at "..mapRefX..","..mapRefY)

                -- check for collision with wall on current path
                if checkForOpenPath(mapRefX,mapRefY,v) == false then
                    enemyDirections[i] = chooseDirectionChange(i,v,mapRefX,mapRefY,true)
                    hasChanged = true
                end  

                -- consider a random change
                if hasChanged == false then
                    -- has not changed due to collision, consider a change anyhow?
                    local rng = math.random(0, 10)
                    if rng > 4 then
                        enemyDirections[i] = chooseDirectionChange(i,v,mapRefX,mapRefY,false)
                    end    
                end

            end    -- on square
        end -- on line

        local moveSpeed = 1 -- how many pixels per cycle?

        -- TODO the below to a function call, used twice
        local moveByX = 0
        local moveByY = 0
        if enemyDirections[i] == "u" then
            moveByY  = 0 - moveSpeed
        elseif enemyDirections[i] == "d" then
            moveByY = moveSpeed
        elseif enemyDirections[i] == "l" then
            moveByX = 0 - moveSpeed
        elseif enemyDirections[i] == "r" then
            moveByX = moveSpeed
        end    

        enemySprites[i]:moveBy(moveByX, moveByY )

    end -- iterate enemies

end    

function chooseDirectionChange(enemyNo,currentDir,mapRefX,mapRefY,mandatory)
    -- find best direction open for enemy enemyNo, at mapRefX mapRefY
    -- define an array of possible directions - not current, not backward, but the other two
    local availableDirs = {}
    if currentDir == "u" then
         availableDirs = {"l","r"}
    elseif currentDir == "d" then
         availableDirs = {"l","r"}
    elseif currentDir == "l" then
         availableDirs = {"u","d"}
    elseif currentDir == "r" then
         availableDirs = {"u","d"}
    end

    -- simple movement, no attempt to chase yet
    -- iterate that array, check for possibility, check for result
    for i, v in ipairs(availableDirs) do
        -- checking direction v
        if checkForOpenPath(mapRefX,mapRefY,v) then
            -- yes this direction is open
            return v
        end    
    end  
    
    -- what if we hit a wall and nowhere to go? Back up, back up
    if mandatory == true then 
        if currentDir == "u" then
            return "d"
       elseif currentDir == "d" then
            return "u"
       elseif currentDir == "l" then
            return "r"
       elseif currentDir == "r" then
            return "l"
       end
    end    

    -- no options?
    return currentDir;

end    

-- sprite table
ghostTable = playdate.graphics.imagetable.new('Images/ghost')
assert( ghostTable )

initBg()
initPlayer(ghostTable)
initEnemy(ghostTable)

function playdate.update()
    moveGhosty(); 
    moveEnemy();
    
    -- update sprite
    gfx.sprite.update()
    -- playdate.timer.updateTimers()
end 