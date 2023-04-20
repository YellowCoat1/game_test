Entity = object:extend()


function Entity:new(name, health, x, y, w, h, animationDirectory, framesPerSecond, scale, speed)

    x = x or 0
    y = y or 0
    framesPerSecond = framesPerSecond or 10

    self.speed = speed or 10
    
    self.scale = scale or 1
    self.health = health or 30

    self.state = "resting"

    self.x, self.y = x, y
    self.w, self.h = w*self.scale,h*self.scale
    self.name = name

    self.flipped = false

    self.deathFlag = false

    self.animations = {}

    assert(love.filesystem.getInfo(animationDirectory, "directory"), "animation directory does not exist")


    for _,directory in ipairs(love.filesystem.getDirectoryItems(animationDirectory)) do
        self.animations[directory] = {}
    end

    for animation,_ in pairs(self.animations) do
        for _,frame in ipairs(love.filesystem.getDirectoryItems(animationDirectory .. "/" .. animation)) do
            local frameNumber = tonumber(string.gsub(string.gsub(frame, animation, ""), ".png", ""), 10)
            self.animations[animation][frameNumber] = love.graphics.newImage(animationDirectory .. "/" .. animation .. "/" .. frame)
        end

    end

    self.currentAnimation = "resting"
    self.frame = 1
    self.framesPerSecond = framesPerSecond
    self.timeToNextFrame = 1 / framesPerSecond

    -- local currentFrame = self.animations[self.state][self.frame]
    self.bound = world:newRectangleCollider(self.x*self.scale - self.w*worldScale/2, self.y*self.scale - self.h*worldScale, self.w*worldScale, self.h*worldScale)
    self.bound:setType("static")

end

function Entity:update(dt)

    if self.timeToNextFrame > 0 then
        self.timeToNextFrame = self.timeToNextFrame - dt
    else
        self.frame = self.frame + 1
        if self.frame > #self.animations[self.currentAnimation] then
            self:nextState()
            self:nextAnimationLoop()
        end
        self.timeToNextFrame = 1 / self.framesPerSecond
    end

    if self.currentAnimation == "chasing" then

    end

end

function Entity:nextAnimationLoop()
    if self.deathFlag then return self:delete() end
    if self.currentAnimation ~= self.state then
        self.currentAnimation = self.state
        self.frame = 1
    else
        self.frame = 1
    end
end

function Entity:nextState()
    if self.state == "resting" then
        local distance = calculateDistance(player.x, player.y, self.x*self.scale, self.y*self.scale)
        if distance < 400 then
            self.state = "alert"
        end
    
    elseif self.state == "alert" then
        self.state = "chasingWindup"
    elseif self.state == "chasingWindup" then
        self.state = "chasing"
        self.bound:destroy()
    end
end

function Entity:draw()
    local savedRed,savedGreen,savedBlue = love.graphics.getColor()
    if self.beingDamaged then love.graphics.setColor(1,0,0) end
    print(self.currentAnimation, self.frame)
    local currentFrame = self.animations[self.currentAnimation][self.frame]
    local flipFactor = 1
    if self.flipped == true then flipFactor = -1 end
    love.graphics.draw(currentFrame, self.x*worldScale, self.y*worldScale, 0, self.scale * flipFactor, self.scale, currentFrame:getWidth()/2, currentFrame:getHeight())
    
    love.graphics.setColor(savedRed, savedGreen, savedBlue)
end

function Entity:setState(state)
    self.state = state
    self.timeToNextFrame = 1 / self.framesPerSecond
    self.frame = 1
end

function Entity:destroy()
    if(self.animations["death"]) then
        self:setAnimation("death", false)
        self.deathFlag = true
    end
end

function Entity:__tostring()
    return self.name
end

return Entity