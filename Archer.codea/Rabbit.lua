Rabbit = class()

function Rabbit:init(x, y)
    -- you can accept and set parameters here
    self.id, self.body = ThePhysics:addCircle(25, x, y)
    self.body.info = self
    self.body.desity = 100
    self.body.friction = 100
    self.body.fixedRotation = true
end

function Rabbit:draw()
    -- Codea does not automatically call this method
    sprite("Planet Cute:Character Horn Girl",
     self.body.x, self.body.y, 50, 85)
end

function Rabbit:touched(touch)
    -- Codea does not automatically call this method
end

function Rabbit:shoot(factor, angle)
    local vx = SHOOTING_STRENGTH * factor * math.cos(math.rad(angle))
    local vy = SHOOTING_STRENGTH * factor * math.sin(math.rad(angle))
    local a = Arrow(1, self.body.x, self.body.y, vx, vy)
    Arrows[a.id] = a
    sound(SOUND_SHOOT, 12229)
end

function Rabbit:collide(contact)
    local b = getContactBody(contact, self)
    if b.info == TheMap then
        self.body.type = STATIC
        self.body.sensor = true
    end
end
