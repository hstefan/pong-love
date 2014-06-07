local function resetPads()
	w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	yspeed = 300;
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
end

local function clamp(v, l, r)
	if v > r then
		return r
	elseif v < l then
		return l
	else
		return v
	end
end

local function handleKeyboard(v, pos, neg, sc, dt)
	if love.keyboard.isDown(neg) then
		return v - sc * dt
	elseif love.keyboard.isDown(pos) then
		return v + sc * dt
	else
		return v
	end
end

function love.load()
	resetPads()
end

function love.update(dt)
	padleft.y = handleKeyboard(padleft.y, "down", "up", yspeed, dt);
	padright.y = handleKeyboard(padright.y, "r", "w", yspeed, dt);
	padleft.y = clamp(padleft.y, 0, h - padleft.h);
	padright.y = clamp(padright.y, 0, h - padright.h);
end

function love.draw()
	love.graphics.rectangle("fill", padleft.x, padleft.y, padleft.w, padleft.h)
	love.graphics.rectangle("fill", padright.x, padright.y, padright.w, padright.h)
end
