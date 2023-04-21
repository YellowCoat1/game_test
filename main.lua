screenManager = require "lib.ScreenManager"
sti = require "lib.sti"
windfield = require "lib.windfield"
inspect = require "lib.inspect"
object = require "lib.classic.classic"

function love.load()

    screens = {
        mainMenu = require "scenes.mainMenu",
        roomManager = require "scenes.roomManager",
        room1 = require "scenes.room1",
        room2 = require "scenes.room2",
        room3 = require "scenes.room3",
        room4 = require "scenes.room4",
        youWin = require "scenes.youWin",
        menu = require "scenes.menu"
    }

    debug = false
    
    world = windfield.newWorld(0,0)

    scenePaused = false

    worldScale = 2

    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 100
    player.y = 100
    player.image = love.graphics.newImage("player.png")
    player.w = player.image:getWidth()
    player.h = player.image:getHeight()
    player.collider = world:newRectangleCollider(150,100,player.w*worldScale,player.h*worldScale)
    player.collider:setFixedRotation(true)
    player.rotation = 0

    background_music = love.audio.newSource("/backgroundMusic.wav", "stream")
    background_music:setLooping(true)

    inMenu = false
    if debug then
        screenManager.init(screens, "roomManager", "room3")
    else
        screenManager.init(screens, "mainMenu")
    end
end

function love.update(dt)
    if not everythingPaused then
        world:update(dt)
        screenManager.update(dt)
    else
        if everythingPausedScript then everythingPausedScript() end
    end
end

function love.draw()
    screenManager.draw()
end

function love.mousepressed(x, y)
    screenManager.mousepressed(x, y)
end


function love.keypressed(key)
    screenManager.keypressed(key)
    if key == "r" then
        love.event.quit("restart")
    end
end

function switchScene(scene, ...)
    local args = (...)
    screenManager.publish("exit")
    screenManager.switch(scene, args)
end

function resetPlayer()
    player.collider:setPosition(100,100)
    player.x, player.y = 100, 100
end

function menuToggle()
    if not inMenu then
        screenManager.push("menu")
        inMenu = true
        scenePaused = true
    else
        screenManager.pop()
        inMenu = false
        scenePaused = false
    end

end

function checkIfPointInBox(px, py, bx, by, bw, bh)
    if px > bx and px < bx+bw and py > by and py < by+bh then
        return true
    else
        return false
    end
end

function checkIfTwoBoxesIntersecting(x1, y1, w1, h1, x2, y2, w2, h2)
    local first_left = x1
    local first_right = x1 + w1
    local first_top = y1
    local first_bottom = y1 + h1

    local second_left = x2
    local second_right = x2 + w2
    local second_top = y2
    local second_bottom = y2 + h2

    if  first_right > second_left
    and first_left < second_right
    and first_bottom > second_top
    and first_top < second_bottom then
        return true
    else
        return false
    end
end

function round(input, place)
    local inputTimes10ToThePowerOfPlace = input * (10^place)
    local rounded = math.floor(inputTimes10ToThePowerOfPlace + .5)
    local dividedBy10ToThePowerOfPlace = rounded / (10^place)
    return(dividedBy10ToThePowerOfPlace)
end

function playerRotationToXY(rotation)
    local playerRotation = -(rotation * math.pi)/2
    local xFace =  math.sin(playerRotation)
    local yFace = -math.cos(playerRotation)
    return xFace, yFace
end

function playerRotationToRadians(rotation)
    return -(rotation * math.pi)/2
end

function calculateDistance(x1, y1, x2, y2)
    local a = x2 - x1
    local b = y2 - y1
    local c = a^2 + b^2
    return(math.sqrt(c))
end