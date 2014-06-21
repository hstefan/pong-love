--Rect = { x = 0, y = 0, w = 0, h = 0 }
--Point = { x = 0, y = 0 }
--Circle = { x = 0, y = 0, r = 0 }

local shapes = {}

function shapes.rectToPts(r)
	return { { x = r.x, y = r.y }, { x = r.x + r.w, y = r.y },
		{ x = r.x, y = r.y + r.h }, { x = r.x + r.w, y = r.y + r.h } }
end

function shapes.pointInRect(p, r)
	return p.x > r.x and p.y > r.y and p.x < r.x + r.w and p.y < r.y + r.h
end

function shapes.pointInCircle(p, c)
	local dv = { x = p.x - c.x, y = p.y - c.y }
	return dv.x * dv.x + dv.y * dv.y < c.r * c.r

end

function shapes.rectInCircle(r, c)
	local pts = shapes.rectToPts(r)
	for i, v in ipairs(pts) do
		if not shapes.pointInCircle(v, c) then
			pts[i] = nil
		else
			print("collision!")
		end
	end
	return pts
end

function shapes.rectInRect(ra, rb)
	local pts = shapes.rectToPts(rb)
	for i, v in ipairs(pts) do
		if not shapes.pointInRect(v, ra) then
			pts[i] = nil
		end
	end
	return pts
end

function shapes.circleInCircle(ca, cb)
	local dv = { dx = ca.x - cb.x, dy = ca.y - cb.y }
	return math.sqrt(dv.x * dv.x + dv.y * dv.y) < (ca.r + cb.r)
end

return shapes
