local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    map = sti("map/room2/room2.lua")

    screenManager.publish("room_enter")

    function self:init(startPos)
    
        startPos = startPos or "standardEnter"
        for i,entrance in ipairs(entrances) do
            if entrance.name == startPos then
                player.collider:setPosition(entrance.x, entrance.y)
                player.x, player.y = entrance.x, entrance.y
                player.rotation = entrance.rotation
            end
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