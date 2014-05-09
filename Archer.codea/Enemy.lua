Enemy = class()

function Enemy:init(tag, x, y)
    self.tag = tag
    if tag == 1 then
        local vx = rand(-100, -50)
        self.id, self.body = ThePhysics:addCircle(26, x, y, vx, 0)
        self.body.gravityScale = 0
        self.body.density = 1.5
        self.body.info = self
        self.health = rand(40,70)
        self.coin = math.floor(rand(3,9))
    elseif tag == 2 then
        self.id, self.body = ThePhysics:addBox(x, y, 75, 50)
        self.body.gravityScale = 3
        self.body.angleDamping = 0.9
        self.body.density = 5
        self.body.info = self
        self.health = rand(80, 120)
        self.coin = math.floor(rand(25,50))
    end

    self.arrows = {}
    self.x = x
    self.y = y
    self.angle = 0
end

function Enemy:destroy()
    if self.body ~= nil then
        self:onFreeze()
    end
    self.arrows = {}
end

function Enemy:update()
    if self.body ~= nil then
        self.x = self.body.x
        self.y = self.body.y
        self.angle = self.body.angle
        return ThePhysics:inWorld(self.body)
    else
        return ElapsedTime - self.deadTime < Config.enemyDeadDelay
    end 
end

function Enemy:draw()
    -- Codea does not automatically call this method
    if self.deadTime ~= nil then
        tint(218, 119, 120, 145)
    else
        noTint()
    end 
    if self.tag == 1 then
        rotateAt(self.x, self.y, self.angle, function()
            translate(0, 8)
            sprite("Planet Cute:Tree Short", self.x, self.y, 50, 85)
        end)
    elseif self.tag == 2 then
        rotateAt(self.x, self.y, self.angle + 90, function()
            sprite("Tyrian Remastered:Blimp Boss", self.x, self.y, 48, 65)
        end)
    end
end

function Enemy:touched(touch)
    -- Codea does not automatically call this method
end

function Enemy:collide(contact)
    if contact.state ~= BEGAN then return end    
    if self.body == nil then return end
    local b = getContactBody(contact, self)
    if b == nil or b.info == nil then return end

    if b.info == TheMap then
        if self.tag == 1 then
            self:onFreeze()
            sound(SOUND_HIT, 13921)
        elseif self.tag == 2 then
        end
    elseif b.info:is_a(Arrow) then
        if b.info.enemy == nil and self.arrows[b.info.id] == nil then
            self.arrows[b.info.id] = b.info
            self.health = self.health - b.info.damage
            b.info:onHitEnemy(self, contact.points[1])
            if self.health <= 0 then
                self:onDead()
            end
            sound(SOUND_HIT, 26714)
        end
    end
end

function Enemy:onDead()
    if self.tag == 1 then
        self.body.gravityScale = 3
        Coins = Coins + self.coin
    elseif self.tag == 2 then
        self:onFreeze()
        sound(SOUND_EXPLODE, 18956)
    end
end  

function Enemy:onFreeze()
    if self.body == nil then return end
    self.x = self.body.x
    self.y = self.body.y
    ThePhysics:removeBody(self.id)
    self.body = nil
    self.deadTime = ElapsedTime
    
    for k, v in pairs(self.arrows) do
        v:onFreeze()
    end
    self.arrows = {}
end








