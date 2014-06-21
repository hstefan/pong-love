sh = require "shapes"

local function resetPads()
	w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	padySpeed = 650;
	s = { 0.707, -0.707 }
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
	ball = { x = w/2 - 10, y = h/2 - 10, w = 20, h = 20, vx = s[math.random(2)], vy = s[math.random(2)], sc = 600 }
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

local function handleJoystick(device, v, sc, dt)
	local axis = device:getAxis(2)
	if math.abs(axis) < 0.4 then
		return v
	else
		return v + (axis * dt * sc)
	end
end

local function setupInputMethods()
	padHandlers = { function(y, spd, dt) return handleKeyboard(y, "down", "up", spd, dt) end,
		function(y, spd, dt) return handleKeyboard(y, "r", "w", spd, dt) end }
	joysticks = love.joystick.getJoysticks()
	for k, v in ipairs(joysticks) do
		padHandlers[k] = function(y, spd, dt) return handleJoystick(joysticks[k], y, spd, dt) end
	end
end

function love.load()
	math.randomseed(os.time())
	love.graphics.setNewFont("data/slkscre.ttf", 64)
	score = { 0, 0 }
	resetPads()
	setupInputMethods()
end

function love.update(dt)
	padleft.y = padHandlers[1](padleft.y, padySpeed, dt)
	padright.y = padHandlers[2](padright.y, padySpeed, dt)
	padleft.y = clamp(padleft.y, 0, h - padleft.h)
	padright.y = clamp(padright.y, 0, h - padright.h)

	local nx, ny = ball.x + ball.vx * ball.sc * dt, ball.y + ball.vy * ball.sc * dt
	local nball = { x = nx, y = ny, w = ball.w, h = ball.h }

	if nx < ball.w or nx > w - ball.w then
		resetPads()
		if nx < ball.w then
			score[2] = score[2] + 1;
		else
			score[1] = score[1] + 1;
		end
		return
	end
	if #(sh.rectInRect(padleft, nball)) > 0 or #(sh.rectInRect(padright, nball)) > 0 then
		ball.vx = -ball.vx
	else
		if nx < ball.w or nx > w - ball.w then
			ball.vx = -ball.vx
		else
			ball.x = nx
		end
		if ny < ball.h or ny > h - ball.h then
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
	love.graphics.rectangle("fill", ball.x, ball.y, ball.w, ball.h)
end
