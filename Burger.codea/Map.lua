Map = class()

function Map:init(id)
    -- you can accept and set parameters here
    self.id = id
    if self.id == 1 then
        self.ground = physics.body(CHAIN, false,
             vec2(-500, 800), vec2(0, 100), vec2(1024, 100), vec2(1524, 800))
        self.groundId = ThePhysics:addBody(self.ground)
        self.ground.info = self
    end
end

function Map:update()
end

function Map:draw()
    if self.id == 1 then
        fill(95, 184, 20, 255)
        drawRectAt(0, 50, 1024, 100)
    end
end

