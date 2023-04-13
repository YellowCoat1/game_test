local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    local boundMap = sti("map/room1/room1.lua")
    local map = cartographer.load("map/room1/room1.lua")

    local debugTimer = {}

    local objects = {}
    table.insert(objects, {x = (16*4), y = (32*3), w = 32, h = 32, action = switch, arguments = {"room2"}})

    local function objectCheck(x, y, w, h)
        for i, obj in pairs(objects) do
            if checkIfTwoBoxesIntersecting(x, y, w, h obj.x, obj.y, obj.w, obj.h) then
                obj.action(unpack(obj.arguments))
            end
        end
    end

    function switch(room)
        screenManager.publish("exit")
        screenManager.switch(room)
    end

    player.rotation = 0

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

            love.graphics.rectangle("line", 32*3, 32*2, 32, 32)

            if debugTimer.t > 0 then
                love.graphics.rectangle(debugTimer.x, debugTimer.y, 32, 32)
            end
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
            print("check")
            local x, y = player.x, player.y
            local xFace = math.abs((player.rotation-1 % 4) - 2) - 1
            local yFace = math.abs((player.rotation % 4) - 2) - 1

            local checkXPosition = x+(xFace*32)
            local checkYPosition = y+(yFace*32)
            objectCheck(checkXPosition, checkYPosition, 32, 32)

            debugTimer.x = checkXPosition
            debugTimer.t = 1
        end
    end

    return self
end

return MainScreen