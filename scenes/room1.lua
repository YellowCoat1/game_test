local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    boundMap = sti("map/room1/room1.lua")
    map = sti("map/room1/room1.lua")


    table.insert(objects, {x = (32*2), y = (32*1), w = 32, h = 16, action = switchRoom, arguments = {"room2", "door1"}})

    if boundMap.layers["bounds"] then
        for i, obj in pairs(boundMap.layers["bounds"].objects) do
            local bound = world:newRectangleCollider(obj.x*worldScale,obj.y*worldScale,obj.width*worldScale,obj.height*worldScale)
            bound:setType("static")
            table.insert(bounds, bound)
        end
    end

    function self:init(startPos)
        if startPos then
            if startPos == "door1" then
                player.collider:setPosition(32*worldScale*2 + player.w*worldScale/2, 32*worldScale*2)
                player.x, player.y = 32*worldScale*2 + player.w/2, 32*worldScale*2
                player.rotation = 2
            end
        else
            player.collider:setPosition(100*worldScale,100*worldScale)
            player.x, player.y = 100*worldScale,100*worldScale
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