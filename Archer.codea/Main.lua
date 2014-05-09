-- Archer

supportedOrientations(LANDSCAPE_ANY)
--supportedOrientations(LANDSCAPE_LEFT)

Config = {
    arrowDeadDelay = 0.5,
    enemyDeadDelay = 0.5,
}
    
-- Use this function to perform your initial setup
function setup()
    math.randomseed(os.time())
    iparameter("MapID", 1, 6)
    iparameter("LevelID", 1, 12)
    iparameter("SHOOTING_STRENGTH", 400, 1200)
    
    SHOOTING_STRENGTH = 700
    MIN_SHOOTING_LEN = 32
    MAX_SHOOTING_LEN = 160
    MIN_SHOOTING_FACTOR =0.2
    
    displayMode(FULLSCREEN)
    DEBUG_DRAW = false

    Coins = 0
    ThePhysics = PhysicsDebugDraw()
    TheControls = Controls()
    ShootingFactor = 0
    ShootingAngle = 0        
    TheRabbit = Rabbit(80, 768)
    Arrows = {}
    Enemies = {}
    
    resetMapAndLevel()
end

function resetMapAndLevel()
    if TheMap == nil or TheMap.id ~= MapID then
        TheMap = Map(MapID, LevelID)
    end
    
    if TheMap.level.id ~= LevelID then
        TheMap:LoadLevel(LevelID)
    end
end

function update()
    ThePhysics:update()
    TheMap:update()
    
    for k, v in pairs(Enemies) do
        if not v:update() then
            print("Remove Enemy: " .. v.id)
            Enemies[v.id] = nil
            v:destroy()
        end
    end 
    
    for k, v in pairs(Arrows) do
        if not v:update() then
            print("Remove Arrow: " .. v.id)
            Arrows[v.id] = nil
            v:destroy()
        end
    end
end

-- This function gets called once every frame
function draw()
    update()
    -- This sets a dark background color 
    resetMapAndLevel()

    TheMap:draw()
    
    for k, v in pairs(Enemies) do
        v:draw()
    end 

    for k, v in pairs(Arrows) do
        v:draw()
    end

    TheRabbit:draw()

    if TouchAnchor ~= nil then
        --fill(228, 207, 207, 255)
        --ellipse(TouchAnchor.x, TouchAnchor.y, 16)
        
        if ShootingFactor > 0 then
            strokeWidth(0)
            fill(25, 142, 246, 45)
            drawRectAt(TheRabbit.body.x, TheRabbit.body.y, ShootingFactor * 256, 16, ShootingAngle)
        end
    end
    
    TheControls:draw()

    if DEBUG_DRAW then
        ThePhysics:draw()
    end       
end

function touched(touch)
    if touch.state == BEGAN then
        TouchAnchor = touch
        ShootingFactor = 0
    elseif touch.state == MOVING and TouchAnchor ~= nil then
        local len = vec2(touch.x - TouchAnchor.x, touch.y - TouchAnchor.y):len()
        if len > MIN_SHOOTING_LEN then
            ShootingFactor = (len - MIN_SHOOTING_LEN) / MAX_SHOOTING_LEN
            ShootingFactor = ShootingFactor * ShootingFactor + MIN_SHOOTING_FACTOR       
            ShootingFactor = math.min(ShootingFactor, 1)
        else
            ShootingFactor = 0
        end
        ShootingAngle = math.deg(math.atan2(TouchAnchor.y - touch.y, TouchAnchor.x - touch.x))
        
    elseif touch.state == ENDED then
        if ShootingFactor > 0 then
            TheRabbit:shoot(ShootingFactor, ShootingAngle)
            TouchAnchor = nil
            ShootingFactor = 0
        else
            TheControls:touched(touch)
        end
    end
end

function collide(contact)
    ThePhysics:collide(contact)
    
    local a = contact.bodyA.info
    local b = contact.bodyB.info
    
    if a ~= nil and a.collide ~= nil then
        a:collide(contact)
    end
    
    if b ~= nil and b.collide ~= nil then
        b:collide(contact)
    end
end