local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    map = sti("map/room2/room2.lua")

    screenManager.publish("room_enter")

    function self:init(startPos)
        if startPos then
            if startPos == "door1" then
                player.collider:setPosition(32*3*worldScale + player.w*worldScale/2, 32*4*worldScale + player.h*worldScale/2)
                player.x, player.y = 32*2 + player.w/2, 32*2
                player.rotation = 0
            end
        else
            player.collider:setPosition(100,100)
            player.x, player.y = 100,100
            player.rotation = 0
        end
    end

    function self:keypressed(key)
        if key == "escape" then
            menuToggle()
        end
        if key == "e" then
            objectCheck()
        end
    end

    return self
end

return MainScreen