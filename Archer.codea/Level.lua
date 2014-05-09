Level = class()

function Level:init(map, id)
    -- you can accept and set parameters here
    self.map = map
    self.id = id
    self.nextSpawnTime = 0
end

function Level:update()
    if ElapsedTime > self.nextSpawnTime then
        if rand(1, 100) < 40 then
            local e = Enemy(2, 900, 512)
            Enemies[e.id] = e
        else
            local num = math.floor(rand(1, 3))
            for i = 1, num do
                local x = WIDTH + 100 / 3
                local y = rand(HEIGHT / 2, HEIGHT)
                local e = Enemy(1, x, y)
                Enemies[e.id] = e
            end
        end
        self.nextSpawnTime = ElapsedTime + rand(3, 6)
    end
end

function Level:draw()
    -- Codea does not automatically call this method
end

function Level:touched(touch)
    -- Codea does not automatically call this method
end
