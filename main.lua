local function resetPads()
	w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	yspeed = 650;
	s = { 0.707, -0.707 }
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
	ball = { x = w/2, y = h/2, rad = 10, vx = s[math.random(2)], vy = s[math.random(2)], sc = 600 }
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
local function pointInRectangle(r, p)
	return p.x >= r.x and p.x <= r.x + r.w and p.y >= r.y and p.y <= r.y + r.h
end

local function anyInRect(rect, cpts) 
	for k, p in ipairs(cpts) do
		if pointInRectangle(rect, p) then
			return true
		end
	end
	return false
end

local function intersectSides(ball, pad)
	return anyInRect(pad, { { x = ball.x + ball.rad, y = ball.y }, { x = ball.x - ball.rad, y = ball.y } })
end

local function intersectCaps(ball, pad)
	return anyInRect(pad, { { x = ball.x, y = ball.y + ball.rad}, { x = ball.x, y = ball.y - ball.rad } })
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setNewFont("data/slkscre.ttf", 64)
	score = { 0, 0 }
	resetPads()
end

function love.update(dt)
	padleft.y = handleKeyboard(padleft.y, "down", "up", yspeed, dt);
	padright.y = handleKeyboard(padright.y, "r", "w", yspeed, dt);
	padleft.y = clamp(padleft.y, 0, h - padleft.h)
	padright.y = clamp(padright.y, 0, h - padright.h)

	local nx, ny = ball.x + ball.vx * ball.sc * dt, ball.y + ball.vy * ball.sc * dt
	local nball = { x = nx, y = ny, rad = ball.rad }

	if nx < ball.rad or nx > w - ball.rad then
		resetPads()
		if nx < ball.rad then
			score[2] = score[2] + 1;
		else
			score[1] = score[1] + 1;
		end
		return
	end
	if intersectSides(nball, padleft) or intersectSides(nball, padright) then
		ball.vx = -ball.vx
	elseif intersectCaps(nball, padleft) or intersectCaps(nball, padright) then
		ball.vx = -ball.vx
		ball.vy = -ball.vy
	else
		if nx < ball.rad or nx > w - ball.rad then
			ball.vx = -ball.vx
		else
			ball.x = nx
		end
		if ny < ball.rad or ny > h - ball.rad then
			ball.vy = -ball.vy
		else
			ball.y = ny
		end
	end
end

function love.draw()
	local sct = { string.format("%d", score[1]), string.format("%d", score[2]) }
	local f = love.graphics.getFont()
	love.graphics.print(sct[1], w/2 - f:getWidth(sct[1]), 10)
	love.graphics.print(sct[2], w/2 + f:getWidth(sct[2]), 10)
	love.graphics.rectangle("fill", padleft.x, padleft.y, padleft.w, padleft.h)
	love.graphics.rectangle("fill", padright.x, padright.y, padright.w, padright.h)
	love.graphics.circle("fill", ball.x, ball.y, ball.rad, 30)
end
