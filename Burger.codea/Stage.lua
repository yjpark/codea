Stage = class()

function Stage:init(id)
    -- you can accept and set parameters here
    self.id = id
    self.map = Map(1)
    self.nextSpawnTime = 0
    TheCart:moveTo(512, 200)
end

function Stage:reset()
    TheCart:moveTo(512, 200)
end

function Stage:update()
    self.map:update()
    if ElapsedTime > self.nextSpawnTime then
        local x = 512
        local y = 800
        local w = 80
        local h = 64
        local b = Box(x, y, w, h)
        Boxes[b.id] = b
        self.nextSpawnTime = ElapsedTime + rand(1,1)
    end
end

function Stage:draw()
    self.map:draw()
end