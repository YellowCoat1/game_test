Entity = object:extend()


function Entity:new(name, health, x, y, animationDirectory, framesPerSecond, scale)

    x = x or 0
    y = y or 0
    framesPerSecond = framesPerSecond or 10
    
    self.scale = scale or 1
    self.health = health or 30

    self.state = "resting"

    self.x, self.y = x*worldScale, y*worldScale
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

    self.frame = 1
    self.framesPerSecond = framesPerSecond
    self.timeToNextFrame = 1 / framesPerSecond
    self.animationRepeat = true

end

function Entity:update(dt)
    if self.timeToNextFrame > 0 then
        self.timeToNextFrame = self.timeToNextFrame - dt
    else
        self.frame = self.frame + 1
        if self.frame > #self.animations[self.state] then
            if self.deathFlag then self:delete() return end
            if self.animationRepeat then
                self.frame = 1
            else
                self.frame = self.frame - 1
            end
        end
        self.timeToNextFrame = 1 / self.framesPerSecond
    end
end

function Entity:draw()
    local savedRed,savedGreen,savedBlue = love.graphics.getColor()
    if self.beingDamaged then love.graphics.setColor(1,0,0) end
    local currentFrame = self.animations[self.state][self.frame]
    local flipFactor = 1
    if self.flipped == true then flipFactor = -1 end
    love.graphics.draw(currentFrame, self.x, self.y, 0, self.scale * flipFactor, self.scale, currentFrame:getWidth()/2, currentFrame:getHeight()/2)
    
    love.graphics.setColor(savedRed, savedGreen, savedBlue)
end

function Entity:setAnimation(animation, animationRepeat)
    self.state = animation
    self.timeToNextFrame = 1 / self.framesPerSecond
    self.frame = 1
    self.animationRepeat = animationRepeat
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

function Entity:seePlayer()
    --local distance = calculateDistance(self.x, self.y, player.x, player.y)
    if self.animations["alert"] then
        self.state = "alert"
    elseif self.animations["chasing"] then
        self.state = "chasing"
    end
end

return Entity