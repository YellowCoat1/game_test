local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    map = sti("map/room1/room1.lua")

    background_music = love.audio.newSource("/backgroundMusic.wav", "stream")
    background_music:setLooping(true)
    
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

        love.audio.play(background_music)

    end

    function self:draw()
        roomLoaded = true
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