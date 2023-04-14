local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    local boundMap = sti("map/room2/room2.lua")
    local map = cartographer.load("map/room2/room2.lua")

    local debugTimer = {t = 0, x = 0, y = 0}

    local objects = {}
    table.insert(objects, {x = (32*3), y = (32*5) + 16, w = 32, h = 16, action = switchRoom, arguments = {"room1", "door1"}})

    local function objectCheck(x, y, w, h)
        for i, obj in pairs(objects) do
            if checkIfTwoBoxesIntersecting(x, y, w, h, obj.x, obj.y, obj.w, obj.h) then
                obj.action(unpack(obj.arguments))
            end
        end
    end

    function self:init(startPos)
        if startPos then
            if startPos == "door1" then
                player.collider:setPosition(32*3 + player.w/2, 32*4 + player.h/2)
                player.x, player.y = 32*2 + player.w/2, 32*2
                player.rotation = 0
            end
        else
            player.collider:setPosition(100,100)
            player.x, player.y = 100,100
            player.rotation = 0
        end
    end

    local bounds = {}
    if boundMap.layers["bounds"] then
        for i, obj in pairs(boundMap.layers["bounds"].objects) do
            local bound = world:newRectangleCollider(obj.x,obj.y,obj.width,obj.height)
            bound:setType("static")
            table.insert(bounds, bound)
        end
    end

    function self:update(dt)
        map:update(dt)
        world:update(dt)
        boundMap:update(dt)

        if debugTimer.t > 0 then
            debugTimer.t = debugTimer.t - dt
        end
    end

    function self:draw()

        love.graphics.setBackgroundColor(0,0,0,1)
        cam:attach()
            map:draw()
            love.graphics.draw(player.image, player.x, player.y, -(player.rotation * math.pi)/2, 1, 1, player.w/2, player.h/2)

            -- for i,val in ipairs(objects) do
            --     love.graphics.rectangle("line", val.x, val.y, val.w, val.h)
            -- end

            -- if debugTimer.t > 0 then
            --     love.graphics.rectangle("line", debugTimer.x, debugTimer.y, 32, 32)
            -- end
        cam:detach()
    end

    function self:receive(message)
        if message == "exit" then

            for i, bound in pairs(bounds) do
                bound:destroy()
            end

        end
    end

    function self:keypressed(key)
        if key == "escape" then
            menuToggle()
        end
        if key == "e" then
            local x, y = player.x, player.y
            local xFace = -(math.abs(math.abs((player.rotation-1 % 4)) - 2) - 1)
            local yFace = -(math.abs((player.rotation % 4) - 2) - 1)

            local checkXPosition = (player.x - player.w/2)+(xFace*32)
            local checkYPosition = (player.y - player.h/2)+(yFace*32)

            objectCheck(checkXPosition, checkYPosition, 32, 32)

            debugTimer.x = checkXPosition
            debugTimer.y = checkYPosition

            debugTimer.t = 1
        end
    end

    return self
end

return MainScreen