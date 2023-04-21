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

        table.insert(objects, {x = 944, y = 168, w = 8, h = 16, locked = false, name = "pauseEntities", action = stopEntities, arguments = {}})
        
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

        if gameOver then
            love.graphics.setColor(1,0,0)
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
            state = "BOSSBOSS"
            boss_music = love.audio.newSource("BOSSBOSS.wav","stream")
            --love.audio.play(boss_music)
            bossFight()
        end

        if state == "BOSSBOSS" and player.x > 450*worldScale then
            state = "seen him"
            scenePaused = true
        end

        if state == "seen him" and unpausePlayer then
            scenePaused = false
            state = "hes coming"
        end

        if gameOverTimer then
            gameOverTimer = gameOverTimer - dt
            if gameOverTimer < 0 then love.event.quit() end
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

    function stopEntities()
        entitiesStopped = true
    end

    bossFight = function()
        entities["Lord Zyroth"] = entity("Lord Zyroth", 300, 100, 8, 20, "/sprites/boss", 10, 4)
        entities["Lord Zyroth"].chasingScript = function(self) 
            self.bound:destroy()
            unpausePlayer = true
        end
        entities["Lord Zyroth"].chasingUpdateScript = function(self, dt)
            
            if not (gameOver or entitiesStopped or inMenu) then

                local angleBetweenZyrothAndThePlayer = math.atan2(self.y*self.scale - player.y, self.x*self.scale - player.x)
                
                if player.x < self.x*self.scale then
                    self.flipped = false
                else
                    self.flipped = true
                end

                local speed = 50

                local xMovement = -math.cos(angleBetweenZyrothAndThePlayer)
                local yMovement = -math.sin(angleBetweenZyrothAndThePlayer)

                self.x = self.x + speed * dt * xMovement
                self.y = self.y + speed * dt * yMovement

                local distanceBetweenZyrothAndThePlayer = calculateDistance(self.x * self.scale, self.y * self.scale, player.x, player.y)

                if distanceBetweenZyrothAndThePlayer < 20 then 
                    gameOver = true 
                    gameOverTimer = 3
                    scenePaused = true
                end
        
            end

        end
        entities["Lord Zyroth"].alertRequirement = function(self)
            return state == "seen him"
        end

    end

    return self
end



return MainScreen