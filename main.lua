screenManager = require "lib.ScreenManager"
sti = require "lib.sti"
windfield = require "lib.windfield"
camera = require "lib.camera"
cartographer = require "lib.cartographer"
inspect = require "lib.inspect"

function love.load()

    screens = {
        mainMenu = require "scenes.mainMenu",
        room1 = require "scenes.room1",
        menu = require "scenes.menu"
    }

    cam = camera()
    cam:zoom(2)

    world = windfield.newWorld(0,0)

    player = {}
    player.x = 100
    player.y = 100
    player.image = love.graphics.newImage("player.png")
    player.w = player.image:getWidth()
    player.h = player.image:getHeight()
    player.collider = world:newRectangleCollider(150,100,player.w,player.h)
    player.collider:setFixedRotation(true)

    player.rotation = 0

    inMenu = false
    screenManager.init(screens, "mainMenu")
    --screenManager.registerCallbacks({"mousepressed", "draw", "update"})

end

function love.update(dt)
    screenManager.update(dt)
    local vx = 0
    local vy = 0

    if not inMenu then
        if love.keyboard.isDown("right") then
            vx = 100
            player.rotation = 3
        end
        if love.keyboard.isDown("left") then
            vx = -100
            player.rotation = 1
        end
        if love.keyboard.isDown("up") then
            vy = -100
            player.rotation = 0
        end
        if love.keyboard.isDown("down") then
            vy = 100
            player.rotation = 2
        end
    end

    local s = 1
    player.collider:setLinearVelocity(vx*s, vy*s)

    cam:lookAt(player.x, player.y)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
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

function switchScene(scene)
    resetPlayer()
    screenManager.publish("exit")
    screenManager.switch(scene)
end

function resetPlayer() 
    player.collider:setPosition(100,100)
    player.x, player.y = 100, 100
end

function menuToggle()
    if not inMenu then
        screenManager.push("menu")
        inMenu = true
    else
        screenManager.pop()
        inMenu = false
    end

end

function checkIfPointInBox(px, py, bx, by, bw, bh)
    if px > bx and px < bx+bw and py > by and py < by+bh then
        return true
    else
        return false
    end
end