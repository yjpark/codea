Box = class()

function Box:init(x, y, w, h)
    -- you can accept and set parameters here
    self.w = w
    self.h = h
    self.id, self.body = ThePhysics:addBox(x, y, w, h)
    local b = self.body
    b.info = self
    b.gravityScale = Config.boxGravityScale
    b.density = Config.boxDensity
    b.friction = Config.boxFriction
    b.restitution = Config.boxRestitution
    b.angularDamping = Config.boxAngularDamping
    b.bullet = true
    self:update()
    print("Create Box: " .. self.id .. ", " .. x .. ", " .. y)
    self.attached = false
end

function Box:destroy()
    if self.body ~= nil then
        self:onFreeze()
    end
end

function Box:onFreeze()
    if self.body == nil then return end
    self:update()
    ThePhysics:removeBody(self.id)
    self.body = nil
    self.deadTime = ElapsedTime
end

function Box:update()
    if self.body ~= nil then
        self.body.awake = true
        self.x = self.body.x
        self.y = self.body.y
        self.angle = self.body.angle
        return ThePhysics:inWorld(self.body)
    else
        return ElapsedTime - self.deadTime < Config.boxDeadDelay
    end
end

function Box:draw()
    if self.deadTime ~= nil then
        tint(211, 197, 197, 255)
    else 
        noTint()
    end
    
    rotateAt(self.x, self.y, self.angle, function()
        sprite("Cargo Bot:Crate Yellow 1", self.x, self.y, self.w, self.h)
    end)
end

function Box:onAttached()
    if self.body == nil then return end
    self.attached = true
    self.body.angularDamping = Config.boxAngularDampingAttached
end

function Box:collide(contact)
    if contact.state ~= BEGAN then return end
    if self.body == nil then return end
    local b = getContactBody(contact, self)
    if b == nil or b.info == nil then return end
    
    if b.info:is_a(Map) then
        self:onFreeze()
    elseif b.info:is_a(Cart) then
        self:onAttached()
    elseif b.info:is_a(Box) then
        if b.info.attached then
            self:onAttached()
        end
    end
end





