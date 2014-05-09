function drawRectAt(x, y, w, h, a, f)
    pushMatrix()
    if a ~= nil then
        translate(x, y)
        rotate(a)
        translate(-x, -y)
    end
    rect(x, y - h / 2, w, h)
    if f ~= nil then f() end
    popMatrix()
end

function rotateAt(x, y, a, f)
    pushMatrix()
    if a ~= nil then
        translate(x, y)
        rotate(a)
        translate(-x, -y)
    end
    if f ~= nil then f() end
    popMatrix()
end

function getContactBody(contact, src)
    if contact.bodyA.info == src then
        return contact.bodyB, contact.bodyA
    end
    if contact.bodyB.info == src then
        return contact.bodyA, contact.bodyB
    end
    return nil, nil
end

function drawGround(body)
    if body.shapeType == CHAIN or body.shapeType == EDGE then
        stroke(232, 165, 45, 255)
        strokeWidth(45)
        local points = body.points
        for j = 1,#points-1 do
            a = points[j]
            b = points[j+1]
            line(a.x, a.y, b.x, b.y)
        end
    end
end

function rand(min, max)
    return min + math.random() * (max - min)
end

