local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    local boundMap = sti("map/room1/room1.lua")
    local map = cartographer.load("map/room1/room1.lua")

    local debugTimer = 0
    local checkedObjectPoint = {0, 0}

    local objects = {}
    table.insert(objects, {x = (16*3), y = 0, w = 0, h = 0, action = switch, arguments = {"room2"}})

    local function objectCheck(x, y)
        for i, obj in pairs(objects) do
            if checkIfPointInBox(x, y, obj.x, obj.y, obj.w, obj.h) then
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

        if debugTimer > 0 then
            debugTimer = debugTimer - dt
        end
    end

    function self:draw()
        
        love.graphics.setBackgroundColor(0,0,0,1)
        cam:attach()
            map:draw()
            love.graphics.draw(player.image, player.x, player.y, -(player.rotation * math.pi)/2, 1, 1, player.w/2, player.h/2)

            love.graphics.rectangle("line", 32*3, 32*2, 32, 32)

            if debugTimer > 0 then
                love.graphics.rectangle(checkedObjectPoint[1]-1.5, checkedObjectPoint[2]-1.5, 3, 3)
            end
        cam:detach()
    end

    function self:receive(message)
        if message == "exit" then
            -- destroy bounds
            for i, bound in pairs(bounds) do
                bound:destroy()
            end

            -- reset player rotation
            player.rotation = 0
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
            checkedObjectPoint = {x + (xFace * 10), y + (yFace * 10)}
            objectCheck(x + (xFace * 10), y + (yFace * 10))
            debugTimer = 1
        end
    end

    return self
end

return MainScreen