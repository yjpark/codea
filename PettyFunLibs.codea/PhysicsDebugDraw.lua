PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.lastBodyId = 0
    self.removeBodies = {}
end

ScreenSize = vec2(1024, 768)
WorldBorder = 512

function PhysicsDebugDraw:addCircle(r, x, y, vx, vy)
    local b = physics.body(CIRCLE, r)
    b.x = x
    b.y = y
    if vx ~= nil and vy ~= nil then
        b.linearVelocity = vec2(vx, vy)
    end
    local id = self:addBody(b)
    return id, b
end

function PhysicsDebugDraw:addBox(x, y, w, h)
    local box = physics.body(POLYGON, vec2(-w/2,h/2), vec2(-w/2,-h/2), vec2(w/2,-h/2), vec2(w/2,h/2))
    box.x = x
    box.y = y
    local id = self:addBody(box)
    return id, box
end

function PhysicsDebugDraw:pointInWorld(x, y, r)
    if r == nil then r = 0 end
    local w = ScreenSize.x
    local h = ScreenSize.y
    local b = WorldBorder
    if x - r < 0 - b then return false end
    if x + r > w + b then return false end
    if y - r < 0 - b then return false end
    if y + r > h + b then return false end
    return true
end

function PhysicsDebugDraw:inWorld(body)
    if body.type == DYNAMIC then 
        if body.shapeType == POLYGON then
            local points = body.points
            for j = 1,#points do
                a = points[j]
            end
        elseif body.shapeType == CHAIN or body.shapeType == EDGE then
            local points = body.points
            for j = 1,#points-1 do
                a = points[j]
            end      
        elseif body.shapeType == CIRCLE then
            return self:pointInWorld(body.x, body.y, body.radius)
        end
    end
    return true
end

function PhysicsDebugDraw:addBody(body)
    self.lastBodyId = self.lastBodyId + 1
    self.bodies[self.lastBodyId] = body
    return self.lastBodyId
end

function PhysicsDebugDraw:removeBody(id)
    local b = self.bodies[id]
    self.bodies[id] = nil
    if b ~= nil then
        b.active = false
        --b.info = nil calling this crash when shooting down through the rabbit
        self.removeBodies[id] = b
    end
end

function PhysicsDebugDraw:removeBodyContacts(b)
    local result = false
    if b ~= nil then
        local removes = {}
        for k, v in pairs(self.contacts) do
            if v.bodyA == b or v.bodyB == b then
                result = true
                table.insert(removes, k)
            end
        end
        for i, v in ipairs(removes) do
            self.contacts[v] = nil
        end
    end
    return result
end

function PhysicsDebugDraw:removeBodyJoints(b)
    local result = false
    if b ~= nil then
        local removes = {}
        for k, v in pairs(self.joints) do
            if v.bodyA == b or v.bodyB == b then
                result = true
                table.insert(removes, k)
            end
        end
        for i, v in ipairs(removes) do
            self.joints[v]:destroy()
            self.joints[v] = nil
        end
    end
    return result
end

function PhysicsDebugDraw:addJoint(joint)
    table.insert(self.joints,joint)
end

function PhysicsDebugDraw:clear()
    -- deactivate all bodies
    
    for k,body in pairs(self.removeBodies) do
        body:destroy()
    end
    
    for k,body in pairs(self.bodies) do
        body:destroy()
    end
  
    for k,joint in pairs(self.joints) do
        joint:destroy()
    end      
    
    self.bodies = {}
    self.joints = {}
    self.contacts = {}
    self.touchMap = {}
end

function PhysicsDebugDraw:update()
    for k, body in pairs(self.removeBodies) do
        local hasContact = self:removeBodyContacts(body)
        local hasJoints = self:removeBodyJoints(body)
        if not hasContact and not hasJoints then
            body:destroy()
            self.removeBodies[k] = nil
        end        
    end
end

function PhysicsDebugDraw:draw()
    pushStyle()
    smooth()
    strokeWidth(5)
    stroke(128,0,128)
    
    local gain = 2.0
    local damp = 0.5
    for k,v in pairs(self.touchMap) do
        local worldAnchor = v.body:getWorldPoint(v.anchor)
        local touchPoint = v.tp
        local diff = touchPoint - worldAnchor
        local vel = v.body:getLinearVelocityFromWorldPoint(worldAnchor)
        v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
    end

    stroke(0, 0, 0, 255)
    noFill()
    
    for k, body in pairs(self.removeBodies) do
        self:drawBody(body, true)
    end
    for k, body in pairs(self.bodies) do
        self:drawBody(body)
    end 

    stroke(0, 61, 255, 255)
    strokeWidth(5)
    
    for k,joint in pairs(self.joints) do
        local a = joint.anchorA
        local b = joint.anchorB
        line(a.x,a.y,b.x,b.y)
    end
    
    stroke(255, 0, 0, 255)
    fill(255, 0, 0, 255)
 
    for k,v in pairs(self.contacts) do
        for m,n in ipairs(v.points) do
            ellipse(n.x, n.y, 10, 10)
        end
    end
    popStyle()
end

function PhysicsDebugDraw:drawBody(body, noColor)
        pushMatrix()
        translate(body.x, body.y)
        rotate(body.angle)
    
        if noColor == nil then
            if body.type == STATIC then
                stroke(255,255,255,255)
            elseif body.type == DYNAMIC then
                stroke(150,255,150,255)
            elseif body.type == KINEMATIC then
                stroke(150,150,255,255)
            end
        end
    
        if body.shapeType == POLYGON then
            strokeWidth(5.0)
            local points = body.points
            for j = 1,#points do
                a = points[j]
                b = points[(j % #points)+1]
                line(a.x, a.y, b.x, b.y)
            end
        elseif body.shapeType == CHAIN or body.shapeType == EDGE then
            strokeWidth(5.0)
            local points = body.points
            for j = 1,#points-1 do
                a = points[j]
                b = points[j+1]
                line(a.x, a.y, b.x, b.y)
            end      
        elseif body.shapeType == CIRCLE then
            strokeWidth(5.0)
            line(0,0,body.radius-3,0)
            strokeWidth(2.5)
            ellipse(0,0,body.radius*2)
        end
        
        popMatrix()
end

function PhysicsDebugDraw:touched(touch)
    local touchPoint = vec2(touch.x, touch.y)
    if touch.state == BEGAN then
        for i,body in ipairs(self.bodies) do
            if body.type == DYNAMIC and body:testPoint(touchPoint) then
                self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = body:getLocalPoint(touchPoint)} 
                return true
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        self.touchMap[touch.id].tp = touchPoint
        return true
    elseif touch.state == ENDED and self.touchMap[touch.id] then
        self.touchMap[touch.id] = nil
        return true;
    end
    return false
end

function PhysicsDebugDraw:collide(contact)
    if contact.state == BEGAN then
        self.contacts[contact.id] = contact
        sound(SOUND_HIT, 2643)
    elseif contact.state == MOVING then
        self.contacts[contact.id] = contact
    elseif contact.state == ENDED then
        self.contacts[contact.id] = nil
    end
end
