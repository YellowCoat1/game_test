local Screen = require('lib.Screen')

local menu = {}

function menu.new()
    local self = Screen.new()

    function self:update(dt)
        enemiesPaused = true
        --scenePaused = true
    end

    function self:draw()

        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        love.graphics.push()
        love.graphics.setColor(0,0,0,0.8)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(69/255,69/255,69/255,1)
        love.graphics.rectangle("fill", w*(1/4), h*(1/16), w*(1/2), h*(1/8))
        love.graphics.rectangle("fill", w*(1/4), h*(1/4), w*(1/2), h*(1/8))
        love.graphics.setColor(1,1,1)
        love.graphics.print("play", w*(1/4), h*(1/16), 0, 4, 4)
        love.graphics.print("exit", w*(1/4), h*(1/4), 0, 4, 4)
        love.graphics.setColor(1,1,1,1)
        love.graphics.pop()
    end

    function self:mousepressed(x, y)
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        if checkIfPointInBox(x, y, w*(1/4), h*(1/16), w*(1/2), h*(1/8)) then
            enemiesPaused = false
            menuToggle()
        end
        if checkIfPointInBox(x, y, w*(1/4), h*(1/4), w*(1/2), h*(1/8)) then
            screenManager.publish("exit")
            screenManager.switch("mainMenu")
        end
    end

    function self:keypressed(key)
        if key == "escape" then
            enemiesPaused = false
            menuToggle()
        end
    end

    function self:receive(message)
        if message == "exit" then
            inMenu = false
        end
    end

    return self
end

return menu