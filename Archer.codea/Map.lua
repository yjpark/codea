Map = class()

function Map:init(id, levelId)
    -- you can accept and set parameters here
    self.id = id
    self:setupMap()
    self:loadLevel(levelId)
end

function Map:setupMap()
    if self.id == 1 then
        self.ground = physics.body(CHAIN, false,
            vec2(0, 400), vec2(100, 400), vec2(200, 300),
            vec2(400, 100), vec2(800, 10), vec2(1200, 200))
        self.ground.friction = 10
        self.groundId = ThePhysics:addBody(self.ground)
        self.ground.info = self
    end
end
    
function Map:loadLevel(levelId)
    self.level = Level(self, levelId)
end

function Map:update()
    self.level:update()
end

function Map:draw()
    -- Codea does not automatically call this method
    background(134, 198, 224, 255)
    if self.id == 1 then
        fill(141, 226, 104, 255)
        drawRectAt(0, 200, 100, 400)
        drawRectAt(800, -100, 300, 200, 30)
        drawRectAt(400, 50, 400, 100, -15)
        drawRectAt(-80, 280, 580, 400, -45)
    end
    drawGround(self.ground)
end

function Map:touched(touch)
    -- Codea does not automatically call this method
end
