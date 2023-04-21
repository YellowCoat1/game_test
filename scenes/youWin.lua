local Screen = require('lib.Screen')

local mainMenu = {}

function mainMenu.new()
    local self = Screen.new()

    love.graphics.setBackgroundColor(0,0,0)

    local youWinTimer = 0

    local yippee = false
    local jklol = false

    yippeeCreature = love.graphics.newImage("/sprites/yippee_Creature.png")
    yippeeCreatureAudio = love.audio.newSource("/yippee.mp3", "static")

    function self:update(dt)
        youWinTimer = youWinTimer + dt
        if youWinTimer > 1 then
            if yippee == false then
                yippee = true
                love.audio.play(yippeeCreatureAudio)
            end
        end

        if youWinTimer > 5.5 then
            jklol = true
        end

        if youWinTimer > 6 then
            drawingPaused = false
            screenManager.pop()
        end
    end

    function self:draw()

        scenePaused = true
        entitiesStopped = false
        gameOver = false
        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill",0,0,love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.push()
        love.graphics.scale(10,10)
        love.graphics.setColor(1,1,1)

        if not jklol then
            
            love.graphics.print("you win!")
            love.graphics.pop()
            if yippee then
                love.graphics.draw(yippeeCreature, love.graphics.getWidth() * 1/2, love.graphics.getHeight() * 1/2)
            end
        else
            love.graphics.print("jk lol", (love.graphics.getWidth()/2)/10, (love.graphics.getHeight()/2) / 10)
            love.graphics.pop()
        end
    end


    return self
end


return mainMenu