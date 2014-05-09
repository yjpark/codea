Cart = class()

function Cart:init()
    -- you can accept and set parameters here
    self.w = 128
    self.h = 32
    self.id, self.body = ThePhysics:addCircle(32, 512, 32)
    local b = self.body
    b.info = self
    b.type = STATIC
    b.friction = Config.cartBodyFriction
    b.restitution = Config.cartBodyRestitution
    
    self.armId, self.arm = ThePhysics:addBox(512, 200, self.w, self.h)
    b = self.arm
    b.info = self
    b.friction = Config.cartArmFriction
    b.restitution = Config.cartArmRestitution
    b.bullet = true
    self.arm.type = STATIC
    self.joint = physics.joint(REVOLUTE, self.body, self.arm, self.arm.position)
    local j = self.joint
    j.enableLimit = true
    j.lowerLimit = -1
    j.upperLimit = 1
    self:update()
end

function Cart:moveTo(x, y)
    local offset = x - self.body.x
    self.body.x = x
    self.arm.y = y
    
    for k, v in pairs(Boxes) do
        if v.attached and v.body ~= nil then
            v.body.x = v.body.x + offset
        end
    end
end

function Cart:update()    
    local offset = Gravity.x * SpeedFactor
    --offset = UserAcceleration.x * SpeedFactor * 30
    
    self.body.x = self.body.x + offset
    self.arm.x = self.body.x
    local angle = -Gravity.x * AngleFactor
    if math.abs(angle) > AngleThreshold then
        if angle > 0 then
            angle = angle - AngleThreshold
        else
            angle = angle + AngleThreshold
        end
    else
        angle = 0
    end
    self.arm.angle = angle

    for k, v in pairs(Boxes) do
        if v.attached and v.body ~= nil then
            local dis = math.abs(v.body.y - self.arm.y)
            local damping = dis / 1000 * HeightDamping / 100 * math.abs(angle)
            if damping > 0.5 then damping = 0.5 end
            v.body.x = v.body.x + offset * (1 - damping)
            --v.body.x = v.body.x + offset
        end
    end
    
    self.x = self.arm.x
    self.y = self.arm.y
    self.angle = self.arm.angle
    if self.x < 0 then
        self.body.x = 0
    elseif self.x > 1024 then
        self.body.x = 1024
    end
end

function Cart:draw()
    rotateAt(self.x, self.y, self.angle, function()
        sprite("Cargo Bot:Game Area Floor", self.x, self.y, self.w, self.h)
    end)
end

