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
        addBound(1,1,1,1)
    end

    function self:draw()
        roomLoaded = true
    end

    function roomDraw()
        if barsShut then
            map:drawTileLayer("bars")
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
            print("a")
            addBound(128, 48, 32, 256)
            timer = 1.5
        end

        if state == "bars just shut" and timer == 0 then
            scenePaused = false
            state = "regular 2"
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

    return self
end

return MainScreen