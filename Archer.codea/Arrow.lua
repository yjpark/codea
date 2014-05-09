Arrow = class()

function Arrow:init(tag, x, y, vx, vy)
    -- you can accept and set parameters here
    self.tag = tag
    if tag == 1 then
        self.id, self.body = ThePhysics:addCircle(8, x, y, vx, vy)
        self.damage = rand(30,50)
    end
    self.body.info = self
    self.body.bullet = true
    self.body.fixedRotation = true
    self.length = 12
    self.radius = 6
    self.x = x
    self.y = y
    self.angle = 0
end

function Arrow:destroy()
    if self.body ~= nil then
        self:onFreeze()
    end
end

function Arrow:update()
    if self.body ~= nil then
        self.x = self.body.x
        self.y = self.body.y
        if self.enemy == nil then
            local v = self.body.linearVelocity
            if v:len() > 0 then 
                local a = math.deg(math.atan2(-v.y, -v.x))
                self.body.angle = a
                self.angle = a
            end
        else
            self.angle = self.body.angle
        end
        return ThePhysics:inWorld(self.body)
    else
        return ElapsedTime - self.deadTime < Config.arrowDeadDelay
    end
end

function Arrow:draw()
    -- Codea does not automatically call this method
    strokeWidth(0)
    fill(0, 0, 0, 255)
    ellipse(self.x, self.y, self.radius)


    fill(92, 93, 95, 255)
    drawRectAt(self.x, self.y, self.length, self.radius / 2, self.angle, function()
        rect(self.x + self.length, self.y - self.radius / 2,
        self.radius * 2, self.radius)
    end)
end

function Arrow:touched(touch)
    -- Codea does not automatically call this method
end

function Arrow:collide(contact)
    if contact.state ~= BEGAN then return end    
    if self.body == nil then return end
    local b = getContactBody(contact, self)
    if b == nil or b.info == nil then return end

    if b.info == TheMap then
        sound(SOUND_HIT, 19383)
        self:onFreeze()
    end
end

function Arrow:onFreeze()
    if self.body == nil then return end
    self.x = self.body.x
    self.y = self.body.y
    ThePhysics:removeBody(self.id)
    self.body = nil
    self.deadTime = ElapsedTime
end
 
function Arrow:onHitEnemy(e, pos)
    if self.body == nil then return end   
    if self.tag == 1 then
        self.enemy = e
        self.damage = 0
        self.body.sensor = true
        self.body.gravityScale = 0
        local j = physics.joint(REVOLUTE, e.body, self.body, self.body.position)
        j.enableLimit = true
        local a = 5
        j.lowerLimit = -a
        j.upperLimit = a
        ThePhysics:addJoint(j)
    end
end


