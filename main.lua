local function resetPads()
	w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	yspeed = 450;
	s = { 0.707, -0.707 }
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
	ball = { x = w/2, y = h/2, rad = 10, vx = s[math.random(2)], vy = s[math.random(2)], sc = 300 }
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

local function intersect(ball, pad)
	local cpts = { { x = ball.x + ball.rad, y = ball.y }, { x = ball.x - ball.rad, y = ball.y },
		{ x = ball.x, y = ball.y + ball.rad}, { x = ball.x, y = ball.y - ball.rad } }
	for k, p in ipairs(cpts) do
		if pointInRectangle(pad, p) then
			return true
		end
	end
	return false
end

function love.load()
	math.randomseed(os.time())
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
		return
	end
	if nx < ball.rad or nx > w - ball.rad or intersect(nball, padleft) or intersect(nball, padright) then
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

function love.draw()
	love.graphics.rectangle("fill", padleft.x, padleft.y, padleft.w, padleft.h)
	love.graphics.rectangle("fill", padright.x, padright.y, padright.w, padright.h)
	love.graphics.circle("fill", ball.x, ball.y, ball.rad, 30)
end
