local Screen = require('lib.Screen')

local RoomManager = {}

function RoomManager.new()
    local self = Screen.new()

    player.image:setFilter("linear")

    debugTimer = {t = 0, x = 0, y = 0}

    objects = {}

    function self:draw()

        if not (map and boundMap) then return end

        love.graphics.setBackgroundColor(0,0,0,1)
        love.graphics.push()

        -- scale up
        love.graphics.scale(worldScale,worldScale)

        -- translate so it's centered on the player
        local mapTranslateX = love.graphics.getWidth()/(worldScale*2) - player.x/worldScale
        local mapTranslateY = love.graphics.getHeight()/(worldScale*2) - player.y/worldScale
        local roundTo = 1
        love.graphics.translate(round(mapTranslateX, roundTo), round(mapTranslateY, roundTo))

        -- draw the map
        map:drawLayer(map.layers["floors"])
        map:drawLayer(map.layers["walls"])
    
        for i,val in ipairs(objects) do
            love.graphics.rectangle("line", val.x, val.y, val.w, val.h)
        end


        if debugTimer.t > 0 then
            love.graphics.rectangle("line", debugTimer.x, debugTimer.y, 32, 32)
        end

        -- reset map translation
        love.graphics.translate(-mapTranslateX,-mapTranslateY)

        --draw the player
        love.graphics.draw(player.image, love.graphics.getWidth()/(worldScale*2), love.graphics.getHeight()/(worldScale*2), -(player.rotation * math.pi)/2, 1, 1, player.w/2, player.h/2)

        love.graphics.pop()


    end


    bounds = {}

    function self:init(room)
        screenManager.push(room)
    end

    function self:update(dt)
        if debugTimer.t > 0 then
            debugTimer.t = debugTimer.t - dt
        end
    end

    function objectCheck()
        local playerRotation = -(player.rotation * math.pi)/2
        local xFace =  math.sin(playerRotation)
        local yFace = -math.cos(playerRotation)

        local checkXPosition = (player.x/worldScale - player.w/2)+(xFace*32)
        local checkYPosition = (player.y/worldScale - player.h/2)+(yFace*32)

        debugTimer.x = checkXPosition
        debugTimer.y = checkYPosition

        x, y = checkXPosition, checkYPosition
        w, h = 32, 32

        debugTimer.t = 1

        for i, obj in pairs(objects) do
            if checkIfTwoBoxesIntersecting(x, y, w, h, obj.x, obj.y, obj.w, obj.h) then
                obj.action(unpack(obj.arguments))
            end
        end
    end

    function switchRoom(room, ...)
        local args = (...)
        objects = {}
        print("destroy")
        for i, bound in pairs(bounds) do
            bound:destroy()
        end
        bounds = {}
        resetPlayer()
        screenManager.publish("roomExit")
        screenManager.pop()
        screenManager.push(room, args)
    end

    function self:receive(message)
        if message == "roomExit" or message == "exit" then
            for i, bound in pairs(bounds) do
                bound:destroy()
            end
        end

        if message == "exit" then
            -- do stuff
        end
    end

    return self
end


return RoomManager