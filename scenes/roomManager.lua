local Screen = require('lib.Screen')

local RoomManager = {}

function RoomManager.new()
    local self = Screen.new()

    debugTimer = {t = 0, x = 0, y = 0}

    isScreenFadeGoingUp = true
    screenFade = -1

    objects = {}
    entrances = {}
    eventTriggers = {}

    entities = {}

    screenFadeRoomLocation = {}

    

    function self:draw()

        if not map then return end

        
        love.graphics.setBackgroundColor(47/255,40/255,58/255,1)
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

        if roomDraw then
            roomDraw()
        end
    
        if debug then

            love.graphics.setColor(0, 0, 1)
            for i,bound in ipairs(bounds) do
                love.graphics.rectangle("line", bound.x/worldScale, bound.y/worldScale, bound.w/worldScale, bound.h/worldScale)
            end

            love.graphics.setColor(0,1,0)
            for i,val in ipairs(objects) do
                love.graphics.rectangle("line", val.x, val.y, val.w, val.h)
            end

            for i,entity in ipairs(entities) do
                love.graphics.rectangle("line", (entity.x * worldScale) - entity.w/2, (entity.y*worldScale) - entity.h, entity.w, entity.h)
            end

            love.graphics.setColor(1,0,0)
            if debugTimer.t > 0 then
                love.graphics.rectangle("line", debugTimer.x, debugTimer.y, 32, 32)
            end
            love.graphics.setColor(1,1,1)
        end

        -- reset map translation
        love.graphics.translate(-mapTranslateX,-mapTranslateY)

        if roomDrawUI then
            roomDrawUI()
        end

        --draw the player
        love.graphics.draw(player.image, love.graphics.getWidth()/(worldScale*2), love.graphics.getHeight()/(worldScale*2), playerRotationToRadians(player.rotation), 1, 1, player.w/2, player.h/2)


        love.graphics.translate(mapTranslateX,mapTranslateY)


        for _,entity in ipairs(entities) do
            entity:draw()
        end

        love.graphics.translate(-mapTranslateX,-mapTranslateY)

        if screenFade ~= -1 then
            love.graphics.setColor(0, 0, 0, screenFade)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1,1,1,1)
        end

        love.graphics.pop()


    end


    bounds = {}

    function self:init(room)
        entity = require "classes.Entity"
        screenManager.push(room)
    end

    function self:update(dt)

        for _,entity in ipairs(entities) do
            entity:update(dt)
        end
        
        local vx = 0
        local vy = 0

        local speed = 100

        if not scenePaused then
            if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
                vx = vx + speed * worldScale
            end
            if love.keyboard.isDown("left") or love.keyboard.isDown("a")then
                vx = vx - speed * worldScale
            end
            if love.keyboard.isDown("up") or love.keyboard.isDown("w")then
                vy = vy - speed * worldScale
            end
            if love.keyboard.isDown("down") or love.keyboard.isDown("s")then
                vy = vy + 100 * worldScale
            end
        end

        if vy > 0 then player.rotation = 2
        elseif  vy < 0 then player.rotation = 0 end
        if vx > 0 then player.rotation = 3
        elseif vx < 0 then player.rotation = 1 end



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

        local toRemove = {}
        -- iterating through eventTriggers backwards
        for i = #eventTriggers, 1, -1 do
            print(i, inspect(eventTriggers))
            local obj = eventTriggers[i]
            if checkIfTwoBoxesIntersecting(player.x, player.y, player.width, player.height, obj.x, obj.y, obj.w, obj.h) then
                obj.toCall()
                table.remove(eventTriggers, i)
            end
        end

        -- managing screen fade
        if screenFade > -1 then
            if isScreenFadeGoingUp then
                if screenFade > 1 then 
                    isScreenFadeGoingUp = false
                    switchRoom(screenFadeRoomLocation[1], screenFadeRoomLocation[2])
                    roomLoaded = false
                else screenFade = screenFade + 1 * dt end
            else
                if roomLoaded then
                    if screenFade < 0 then
                        screenFade = -1
                        scenePaused = false
                        isScreenFadeGoingUp = true
                    else
                        screenFade = screenFade - 1 * dt
                    end
                end
            end
        end


    end

    function objectCheck()

        if not scenePaused then

            local xFace, yFace = playerRotationToXY(player.rotation)

            local checkXPosition = (player.x/worldScale - player.w/2)+(xFace*32)
            local checkYPosition = (player.y/worldScale - player.h/2)+(yFace*32)

            debugTimer.x = checkXPosition
            debugTimer.y = checkYPosition

            x, y = checkXPosition, checkYPosition
            w, h = 32, 32

            debugTimer.t = .5

            for i, obj in pairs(objects) do
                if obj.locked == false and checkIfTwoBoxesIntersecting(x, y, w, h, obj.x, obj.y, obj.w, obj.h) then
                    obj.action(unpack(obj.arguments))
                end
            end
        end
    end

    -- called to switch between one room and another
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

    -- called when the player exits a room through a door or arch 
    function roomPlayerExit(room, ...)
        screenFade = 0
        scenePaused = true
        local args = {...}
        screenFadeRoomLocation = args
        table.insert(screenFadeRoomLocation, 1, room)
        --switchRoom(room, ...)
    end

    function self:mousePressed(mouseX, mouseY)

        if not scenePaused then
            local angleFromPlayerToMouse = math.atan2(mouseY - player.y, mouseX - player.x) 
            swordSwipe = {timer = 0.1, angle = angleFromPlayerToMouse}
        end
    end

    function self:receive(message)
        if message == "roomExit" or message == "exit" then
            for i, bound in pairs(bounds) do
                bound:destroy()
            end
            map = nil
            objects = {}
            entrances = {}
            -- clear roomDraw and roomDrawUI functions 
            roomDraw = function() end
            roomDrawUI = function () end
            debugTimer.t = 0
        end

        if message == "room_enter" then

            if map.layers["bounds"] then
                for _, obj in pairs(map.layers["bounds"].objects) do
                    local boundX = obj.x*worldScale
                    local boundY = obj.y*worldScale
                    local boundWidth = obj.width*worldScale
                    local boundHeight = obj.height*worldScale
                    local bound = world:newRectangleCollider(boundX, boundY, boundWidth, boundHeight)
                    bound.x, bound.y, bound.w, bound.h = boundX, boundY, boundWidth, boundHeight
                    bound:setType("static")
                    table.insert(bounds, bound)
                end
            end


            if map.layers["doors"] then
                for _,obj in pairs(map.layers["doors"].objects) do
                    table.insert(objects, {x = obj.x, y = obj.y, w = obj.width, h = obj.height, locked = false, name = obj.name, action = roomPlayerExit, arguments = {obj.properties.roomExit, obj.properties.roomExitDoorName}})
                end
            end

            if map.layers["entrances"] then
                for _,obj in pairs(map.layers["entrances"].objects) do
                    local entranceRotation = obj.properties.playerEnterRotation or 0
                    table.insert(entrances, {x = obj.x*worldScale, y = obj.y*worldScale, rotation = entranceRotation, name = obj.name})
                end
            end

            if map.layers["eventTriggers"] then
                for _,obj in pairs(map.layers["eventTriggers"].objects) do 
                    table.insert(eventTriggers, {x = obj.x, y = obj.y, w = obj.width, h = obj.height, functionCall = obj.properties.toCall})
                end
            end

        end

    end

    function addBound(x,y,w,h)
        local bound = world:newRectangleCollider(x*worldScale, y*worldScale, w*worldScale, h*worldScale)
        bound.x, bound.y, bound.w, bound.h = x*worldScale, y*worldScale, w*worldScale, h*worldScale
        bound:setType("static")
        table.insert(bounds, bound)
    end

    return self
end


return RoomManager