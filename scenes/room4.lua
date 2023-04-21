local Screen = require('lib.Screen')

local MainScreen = {}

function MainScreen.new()
    local self = Screen.new()

    drawingPaused = true
    scenePaused = true
    map = sti("map/room4/room4.lua")

    
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

        spawnEnemies()
        table.insert(objects, {x = 944, y = 168, w = 8, h = 16, locked = false, name = "pauseEntities", action = stopEntities, arguments = {}})

        screenManager.push("youWin")
        
        Entity = require("classes.Entity")
    end

    function self:draw()
        roomLoaded = true
    end

    function roomDraw()
 
    end

    function roomDrawUI()

        if gameOver then
            love.graphics.setColor(1,0,0)
        end

    end

    function self:update(dt)

       timer = 0

        if gameOverTimer then
            gameOverTimer = gameOverTimer - dt
            if gameOverTimer < 0 then love.event.quit() end
        end

        if timer >= 0 then
            timer = timer - dt
        else 
            timer = 0
        end

        if drawingPaused == false then
            state = "sick em boys"
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

    function spawnEnemies()
        table.insert(entities, entity("Lord Zyroth", 40, 50, 8, 20, "/sprites/boss", 10, 3))

        table.insert(entities, entity("Lord Zyroth", 50, 70, 8, 20, "/sprites/boss", 10, 3))

        table.insert(entities, entity("Lord Zyroth", 93, 53, 8, 20, "/sprites/boss", 10, 3))

        table.insert(entities, entity("Lord Zyroth", 100, 100, 8, 20, "/sprites/boss", 10, 3))

        table.insert(entities, entity("Lord Zyroth", 46, 114, 8, 20, "/sprites/boss", 10, 3))
        

        

        -- table.insert(entities, entity("Lord Zyroth", 46, 134, 8, 20, "/sprites/boss", 10, 3))

        for _, enemy in pairs(entities) do
            enemy.chasingScript = function(self) 
                self.bound:destroy()
                scenePaused = false
                unpausePlayer = true
            end

            enemy.chasingUpdateScript = function(self, dt)
                
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
            enemy.alertRequirement = function(self)
                return state == "sick em boys"
            end
        end

    end

    return self
end



return MainScreen