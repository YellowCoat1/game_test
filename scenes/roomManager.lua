local Screen = require('lib.Screen')

local RoomManager = {}

function RoomManager.new()
    local self = Screen.new()

    player.image:setFilter("linear")

    debugTimer = {t = 0, x = 0, y = 0}

    objects = {}
    entrances = {}

    function self:draw()

        if not map then return end

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

        local vx = 0
        local vy = 0

        if not inMenu then
            if love.keyboard.isDown("right") then
                vx = 100*worldScale
                player.rotation = 3
            end
            if love.keyboard.isDown("left") then
                vx = -100*worldScale
                player.rotation = 1
            end
            if love.keyboard.isDown("up") then
                vy = -100*worldScale
                player.rotation = 0
            end
            if love.keyboard.isDown("down") then
                vy = 100*worldScale
                player.rotation = 2
            end
        end

        local s = 1
        player.collider:setLinearVelocity(vx*s, vy*s)

        --cam:lookAt(player.x, player.y)
        player.x = player.collider:getX()
        player.y = player.collider:getY()
            
        if map then
            map:update(dt)
        end

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
        entrances = {}

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
            map = nil
            objects = {}
            entrances = {}
            debugTimer.t = 0
        end

        if message == "room_enter" then

            if map.layers["bounds"] then
                for i, obj in pairs(map.layers["bounds"].objects) do
                    local bound = world:newRectangleCollider(obj.x*worldScale,obj.y*worldScale,obj.width*worldScale,obj.height*worldScale)
                    bound:setType("static")
                    table.insert(bounds, bound)
                end
            end


            if map.layers["doors"] then
                for _,obj in pairs(map.layers["doors"].objects) do
                    table.insert(objects, {x = obj.x, y = obj.y, w = obj.width, h = obj.height, action = switchRoom, arguments = {obj.properties.roomExit, obj.properties.roomExitDoorName}})
                end
            end

            if map.layers["entrances"] then 
                print("testA\n")
                for _,obj in pairs(map.layers["entrances"].objects) do
                    print("testB " .. obj.name .."\n")
                    local entranceRotation = obj.properties.playerEnterRotation or 0
                    if obj.name == "standardEnter" then print("test") end
                    table.insert(entrances, {x = obj.x*worldScale, y = obj.y*worldScale, rotation = entranceRotation, name = obj.name})
                end
            end

        end

    end

    return self
end


return RoomManager