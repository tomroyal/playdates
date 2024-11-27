-- day 10
-- puck man
-- pdc ./day10/Source/main.lua ./compiled/day10.pdx

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
local enemyDirections = {"l","r"} -- an array, as we may have multiple enemies in future
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


-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return( s .. '} ')
    else
       return (tostring(o))
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
    backgroundSprite:moveTo(topLeft, 0) -- center on screen
    backgroundSprite:setZIndex(-1) -- behind player sprite
    backgroundSprite:add()
end

function initPlayer(puckTable)
    -- Set up the player sprite - animated ghosty
    
    playerSprite = AnimatedSprite.new(puckTable)
    playerSprite:addState("l", 4, 6, {tickStep = 4, yoyo = true})
    playerSprite:addState("u", 7, 9, {tickStep = 4, yoyo = true}) 
    playerSprite:addState("r", 1, 3, {tickStep = 4, yoyo = true})
    playerSprite:addState("d", 10, 12, {tickStep = 4, yoyo = true}) 
    playerSprite:changeState("r")
    playerSprite:playAnimation()
    playerSprite:setCenter(0, 0)
    playerSprite:moveTo( (topLeft + 16), 16 )  
    playerSprite:setCollideRect( 0, 0, 16, 16 )
    playerSprite:add() 
end    

function initEnemy(ghostTable)
    -- Set up the enemy sprite - also an animated ghosty, for now!
    enemySprite = AnimatedSprite.new(ghostTable)
    enemySprite:playAnimation()
    enemySprite:setCenter(0, 0)
    enemySprite:moveTo( (topLeft + (9*16)), (7*16) )  
    enemySprite:setCollideRect( 0, 0, 16, 16 )
    enemySprite:add()
    table.insert(enemySprites,enemySprite)

    -- try another one as well?
    enemySprite2 = AnimatedSprite.new(ghostTable)
    enemySprite2:playAnimation()
    enemySprite2:setCenter(0, 0)
    enemySprite2:moveTo( (topLeft + (7*16)), (7*16) )  
    enemySprite2:setCollideRect( 0, 0, 16, 16 )
    enemySprite2:add()
    table.insert(enemySprites,enemySprite2)

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

function movePuck()
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
                        playerSprite:changeState(playerDirection)
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

                -- print("ghosty at "..mapRefX..","..mapRefY)

                -- check for collision with wall on current path
                if checkForOpenPath(mapRefX,mapRefY,v) == false then
                    enemyDirections[i] = chooseDirectionChange(i,v,mapRefX,mapRefY,true)
                    hasChanged = true
                else 
                    if checkForJunction(mapRefX,mapRefY,v) then
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

function checkForJunction(mapRefX,mapRefY,currentDir)
    local hasOption = false
    if currentDir == "u" or currentDir == "d" then
        if checkForOpenPath(mapRefX,mapRefY,"l") then
             hasOption = true
        elseif checkForOpenPath(mapRefX,mapRefY,"r") then     
             hasOption = true
        end    
    else 
        if checkForOpenPath(mapRefX,mapRefY,"u") then
            hasOption = true
        elseif checkForOpenPath(mapRefX,mapRefY,"d") then     
            hasOption = true
        end    
    end  
    return hasOption
end    

function chooseDirectionChange(enemyNo,currentDir,mapRefX,mapRefY,mandatory)

    -- Chase based AI

    -- calculate divergence from player sprite position
    local divergenceX = ((playerSprite.x-topLeft)/16)+1 - mapRefX
    local divergenceY = (playerSprite.y/16)+1 - mapRefY

    -- preference based on that
    local horizPrefs = {"l","r"}
    if divergenceX >= 0 then
        horizPrefs = {"r","l"}
    end   
    
    local vertPrefs = {"u","d"}
    if divergenceY >= 0 then
        vertPrefs = {"d","u"}
    end    

    divergenceX =  math.abs(divergenceX)
    divergenceY =  math.abs(divergenceY)

    -- choose an axis to prefer
    local directionBestFirst = {} -- directions in order
    if divergenceY == 0 or (divergenceY < divergenceX) then
       -- closer on Y, chase X
       directionBestFirst[1] = horizPrefs[1]
       directionBestFirst[2] = vertPrefs[1]
       directionBestFirst[3] = vertPrefs[2]
       directionBestFirst[4] = horizPrefs[2]
    else 
        -- closer on X, chase Y
       directionBestFirst[1] = vertPrefs[1]
       directionBestFirst[2] = horizPrefs[1]
       directionBestFirst[3] = horizPrefs[2]
       directionBestFirst[4] = vertPrefs[2]
    end    

    -- dump(directionBestFirst)

    -- check in turn, best first
    for i, v in ipairs(directionBestFirst) do
        -- checking direction v

        if v == currentDir and mandatory == true then 
            -- current direction, and turning due to collision, so ignore
        else     
            -- is it possible to go that way?
            if checkForOpenPath(mapRefX,mapRefY,v) then
                -- yes this direction is open
                return v
            end 
        end    
           
    end  

end    

function checkCollisions()

    -- v basic for now

    local collisions = playerSprite:overlappingSprites()
    if #collisions > 0 then
        print ('died!')
        return true
    end    

    return false

end    

-- sprite table
ghostTable = playdate.graphics.imagetable.new('Images/ghost')
assert( ghostTable )

puckTable = playdate.graphics.imagetable.new('Images/puck')
assert( puckTable )


initBg()
initPlayer(puckTable)
initEnemy(ghostTable)

local gameLive = true

function playdate.update()

    if gameLive == true then

        movePuck() 
        moveEnemy()
        gfx.sprite.update()

        if checkCollisions() == true then
            gameLive = false
        end 

    end
    
    -- playdate.timer.updateTimers()
end 