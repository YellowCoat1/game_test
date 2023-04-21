local Screen = require('lib.Screen')

local mainMenu = {}

function mainMenu.new()
    local self = Screen.new()

    love.graphics.setBackgroundColor(0,153/255,33/255)

    scenePaused = false
    inMenu = false


    function self:update(dt)

    end

    function rect(x,y,w,h)
        love.graphics.rectangle("fill", x, y, w, h)
    end

    function self:draw()

        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        love.graphics.push()

        
        love.graphics.setColor(69/255,69/255,69/255)

        rect(w*(1/16),h*(1/16),w*(1/4),h*(1/16))
        rect(w*(1/16),h*(3/16),w*(1/4),h*(1/16))

        love.graphics.setColor(1,1,1)
        love.graphics.print("play", w*(1/16), h*(1/16), 0, 2.5, 2.5)
        love.graphics.print("quit", w*(1/16), h*(3/16), 0, 2.5, 2.5)

        love.graphics.print("the adventures of face-man", w*(11/32), h*(1/32), 0, 3, 3)

        love.graphics.draw(player.image, w*(5/8), h*(1/8), 0, 7, 7)

        love.graphics.print("hes beautiful", w*(3/4), h*(1/8) + player.image:getHeight() * 7)

        love.graphics.pop()
    end

    function self:mousepressed(x, y)
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        if checkIfPointInBox(x, y, w*(1/16), h*(1/16), w*(1/4), h*(1/16)) then
            background_music = love.audio.newSource("/backgroundMusic.wav", "stream")
            background_music:setLooping(true)
            love.audio.play(background_music)
            switchScene("roomManager", "room1")
        end
        if checkIfPointInBox(x, y, w*(1/16), h*(3/16), w*(1/4), h*(1/16)) then
            love.event.quit()
        end
    end

    return self
end


return mainMenu