-- day 2
-- import core libraries

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

local playerSprite = nil

-- vars for pacman-like control
local playerDirection = "n" -- none, up, down, left, right, initially n for none
local timerSpeed = 15 -- control the timer. start with 2x per second (updates every 30)
local playerSpeed = 16 -- how much does the player move on each action? in pixels
local timerControl = 0 -- will inc this on the loop

-- A function to set up our game environment.

function myGameSetUp()

    -- Set up the player sprite.
    local playerImage = gfx.image.new("Images/white_happy.png")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!


end

function movePlayer(byX,byY)

    -- check if at the edge. if not, move player
    if (playerSprite.x + byX >= 15) and (playerSprite.x + byX <= 385) and (playerSprite.y + byY >= 15) and (playerSprite.y + byY <= 225) then
        -- maybe use moveTo ?
        playerSprite:moveBy( byX, byY )
    else
        playerDirection = "n" -- stop direction as hit edge   
    end    

end

-- call init
myGameSetUp()

-- main loop
function playdate.update()

    -- change direction if controller is pressed
    -- would need to check for walls etc, but for now
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        playerDirection = "u" 
    elseif playdate.buttonIsPressed( playdate.kButtonRight ) then
            playerDirection = "r" 
    elseif playdate.buttonIsPressed( playdate.kButtonDown ) then
        playerDirection = "d" 
    elseif playdate.buttonIsPressed( playdate.kButtonLeft ) then
            playerDirection = "l" 
    end        

    -- check timer control
    timerControl = timerControl + 1
    
    if (timerControl == timerSpeed) then
        -- action
        -- reset timerControl
        timerControl = 0

        -- move sprite
        -- this could be done much more nicely with an array of direction to move co-ords, but for now, urgh:
        if playerDirection == "u" then
            movePlayer(0,(0-playerSpeed))        
        elseif playerDirection == "r" then
            movePlayer(playerSpeed,0)
        elseif playerDirection == "d" then
            movePlayer(0,playerSpeed)
        elseif playerDirection == "l" then
            movePlayer((0-playerSpeed),0)
        end

        -- update sprite
        gfx.sprite.update()

    end

    -- should probably use this instead of my own timer?    
    playdate.timer.updateTimers()

end