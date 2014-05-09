-- Burger
supportedOrientations(LANDSCAPE_ANY)

Config = {
    boxDeadDelay = 0.5,
    boxDensity = 1,
    boxGravityScale = 8,
    boxRestitution = 0.01,
    boxFriction = 10,
    boxAngularDamping = 1,
    boxAngularDampingAttached = 40,

    cartBodyRestitution = 0.01,
    cartBodyFriction = 0,
    cartArmRestitution = 0.01,
    cartArmFriction = 20,
}

-- Use this function to perform your initial setup
function setup()
    math.randomseed(os.time())
    displayMode(FULLSCREEN)
    DEBUG_DRAW = false
    
    iparameter("StageID", 1, 10)
    iparameter("AngleFactor", 10, 100)
    iparameter("AngleThreshold", 0, 10)
    iparameter("SpeedFactor", 10, 100)
    iparameter("HeightDamping", 0, 100)
    
    AngleFactor = 25
    AngleThreshold = 3
    SpeedFactor = 40
    HeightDamping = 30

    ThePhysics = PhysicsDebugDraw()
    TheControls = Controls()
    
    Boxes = {}
    TheCart = Cart()
        
    updateStage()
end

function updateStage()
    if TheStage == nil or TheStage.id ~= StageID then
        for k, v in pairs(Boxes) do
            v:destroy()
        end
        Boxes = {}
        TheStage = Stage(StageID)
    end
end

-- This function gets called once every frame
function update()
    updateStage()
    ThePhysics:update()
    TheStage:update()
    for k, v in pairs(Boxes) do
        if not v:update() then
            print("Remove Box: " .. v.id)
            Boxes[k] = nil
            v:destroy()
        end
    end
    TheCart:update()
end

function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    update()
    TheStage:draw()
    for k, v in pairs(Boxes) do
        v:draw()
    end
    TheCart:draw()
    TheControls:draw()

    if DEBUG_DRAW then
        ThePhysics:draw()
    end       
end

function touched(touch)
    if touch.state == BEGAN then
        TheStage:reset()
    elseif touch.state == MOVING then
    elseif touch.state == ENDED then
        TheControls:touched(touch)
    end
end

function collide(contact)
    ThePhysics:collide(contact)
    if contact.bodyA == nil or contact.bodyB == nil then return end
    
    local a = contact.bodyA.info
    local b = contact.bodyB.info
    
    if a ~= nil and a.collide ~= nil then
        a:collide(contact)
    end
    
    if b ~= nil and b.collide ~= nil then
        b:collide(contact)
    end
end


