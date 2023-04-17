local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    local boundMap = sti("map/room1/room1.lua")
    local map = sti("map/room1/room1.lua")


    player.image:setFilter("linear")

    local debugTimer = {t = 0, x = 0, y = 0}

    local objects = {}
    table.insert(objects, {x = (32*2), y = (32*1), w = 32, h = 16, action = switchRoom, arguments = {"room2", "door1"}})

    local function objectCheck(x, y, w, h)
        for i, obj in pairs(objects) do
            if checkIfTwoBoxesIntersecting(x, y, w, h, obj.x, obj.y, obj.w, obj.h) then
                obj.action(unpack(obj.arguments))
            end
        end
    end

    local bounds = {}
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
            local playerRotation = -(player.rotation * math.pi)/2
            local xFace =  math.sin(playerRotation)
            local yFace = -math.cos(playerRotation)

            local checkXPosition = (player.x/worldScale - player.w/2)+(xFace*32)
            local checkYPosition = (player.y/worldScale - player.h/2)+(yFace*32)

            objectCheck(checkXPosition, checkYPosition, 32, 32)

            debugTimer.x = checkXPosition
            debugTimer.y = checkYPosition

            debugTimer.t = 1
        end
    end

    return self
end

return MainScreen