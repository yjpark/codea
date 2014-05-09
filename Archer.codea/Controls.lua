Controls = class()

function Controls:init()
    -- you can accept and set parameters here
    self.radius = 40
    self.buttons = {}
    self.buttons[1] = {
        t = "F",
        x = 50,
        y = 718,
        on = true,
        onTapped = function(b)
            if not b.on then
                displayMode(FULLSCREEN)
                b.on= true
            else
                displayMode(STANDARD)
                b.on = false
            end
        end
    }
    
    self.buttons[2] = {
        t = "D",
        x = 120,
        y = 718,
        on = DEBUG_DRAW,
        onTapped = function(b)
            DEBUG_DRAW = not DEBUG_DRAW
            b.on = DEBUG_DRAW
        end
    }
end

function Controls:draw()
    -- Codea does not automatically call this method
    strokeWidth(1)
    for k, v in ipairs(self.buttons) do
        if v.on then
            fill(33, 78, 244, 255)
        else
            fill(159, 162, 223, 255)
        end
        ellipse(v.x, v.y, self.radius)
        fill(0, 0, 0, 255)
        text(v.t, v.x, v.y)
    end
    text("coins: " .. Coins, WIDTH - 100, HEIGHT - 32)
end

function Controls:touched(touch)
    -- Codea does not automatically call this method
    for k, v in ipairs(self.buttons) do
        local len = vec2(touch.x - v.x, touch.y - v.y):len()
        if len < self.radius then
            v.onTapped(v)
        end
    end
end
