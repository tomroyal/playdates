-- this is a comment
-- import core libraries

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil

-- A function to set up our game environment.

function myGameSetUp()

    -- Set up the player sprite.

    local playerImage = gfx.image.new("Images/white_happy.png")
    assert( playerImage ) -- make sure the image was where we thought

    playerSprite = gfx.sprite.new( playerImage )
    playerSprite:moveTo( 200, 120 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
    playerSprite:add() -- This is critical!

    local backgroundImage = gfx.image.new( "Images/back.png" )
    assert( backgroundImage )

    gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            -- x,y,width,height is the updated area in sprite-local coordinates
            -- The clip rect is already set to this area, so we don't need to set it ourselves
            backgroundImage:draw( 0, 0 )
        end
    )

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function movePlayer(byX,byY)

    -- check if at the edge. if not, move player
    
    if (playerSprite.x + byX >= 15) and (playerSprite.x + byX <= 385) and (playerSprite.y + byY >= 15) and (playerSprite.y + byY <= 225) then
        
        -- maybe use moveTo ?
        playerSprite:moveBy( byX, byY )

    end    
    -- log to console
    -- print (playerSprite.x..","..playerSprite.y)
end

function playdate.update()

    -- Poll the d-pad and move our player accordingly.

    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        movePlayer(0,-5)
    end
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        movePlayer(5,0)
    end
    if playdate.buttonIsPressed( playdate.kButtonDown ) then
        movePlayer(0,5)
    end
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        movePlayer(-5,0)
    end

    -- Call the functions below in playdate.update() to draw sprites and keep
    -- timers updated. (We aren't using timers in this example, but in most
    -- average-complexity games, you will.)

    gfx.sprite.update()
    playdate.timer.updateTimers()

end