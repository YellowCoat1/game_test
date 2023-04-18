local Screen = require('lib.Screen')

local mainMenu = {}

function mainMenu.new()
    local self = Screen.new()

    love.graphics.setBackgroundColor(0,153/255,33/255)
    player.image:setFilter("nearest")

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

        love.graphics.draw(player.image, w*(5/8), h*(1/16), 0, 7, 7)

        love.graphics.pop()
    end

    function self:mousepressed(x, y)
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        if checkIfPointInBox(x, y, w*(1/16), h*(1/16), w*(1/4), h*(1/16)) then
            switchScene("roomManager", "room3")
        end
        if checkIfPointInBox(x, y, w*(1/16), h*(3/16), w*(1/4), h*(1/16)) then
            love.event.quit()
        end
    end

    return self
end


return mainMenu