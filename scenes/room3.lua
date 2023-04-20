local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    map = sti("map/room3/room3.lua")
    
    local timer = 0
    local state = "first entered"

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
        
        Entity = require("classes.Entity")
    end

    function self:draw()
        roomLoaded = true
    end

    function roomDraw()
        if barsShut then
            map:drawTileLayer("bars")
        end

    end

    function roomDrawUI()
        if bossbar then
            love.graphics.setColor(0,0,0,0.75)
            love.graphics.rectangle("fill", 0,0,230,20)

            love.graphics.setColor(1,1,1,1)
            if not jkjk then
                love.graphics.print("LORD ZYROTH, TAKER OF NEW SOULS")
            else
                love.graphics.print("jkjk")
            end

            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill", 0, 20,(love.graphics.getWidth()/1.3)/worldScale, love.graphics.getHeight()/(20*worldScale))
            love.graphics.setColor(1,1,1)
        end
    end

    function self:update(dt)
        if state == "first entered" and player.x > 190*worldScale then
            state = "bars about to shut"
            timer = 1
            scenePaused = true
        end

        if state == "bars about to shut" and timer == 0 then
            state = "bars just shut"
            barsShut = true
            addBound(128, 48, 32, 256)
            local door_close = love.audio.newSource("door_close.mp3", "static")
            love.audio.play(door_close)
            timer = 2.5 
        end

        if state == "bars just shut" and timer == 0 then
            scenePaused = false
            state = "regular 2"
        end

        if state == "regular 2" and player.x > 300*worldScale then
            bossbar = true
            state = "BOSSBOSS"
            boss_music = love.audio.newSource("BOSSBOSS.wav","stream")
            love.audio.play(boss_music)
            bossFight()
        end

        if state == "BOSSBOSS" and player.x > 700*worldScale then
            jkjk = true
            love.audio.stop(boss_music)
            state = "jk lol"
        end

        if timer > 0 then
            timer = timer - dt
        else 
            timer = 0
        end

    end

    function self:keypressed(key)

        if key == "escape" and screenFade == -1 then
            menuToggle()
        end

        if key == "e" then
            objectCheck()
        end

    end

    bossFight = function()
        table.insert(entities, entity("Lord Zyroth", 10, 300, 100, "/sprites/boss", "resting", 10, 4))
        print(entities[1])
    end

    return self
end



return MainScreen