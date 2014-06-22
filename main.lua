local sh = require "shapes"
local vector = require "hump.vector"

local function initBall() 
	ball = {}
	ball.size = vector(20, 20)
	ball.pos = vector(w/2 - ball.size.x/2, h/2 - ball.size.y/2)
	ball.dir = vector(math.random(2), math.random(2)):normalize_inplace()
	ball.speed = 400
end

local function resetPads()
	w, h = love.window.getDimensions()
	initBall()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	padySpeed = 650;
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

local function updateBall(dt)
	ball.pos = ball.pos + dt * ball.speed * ball.dir
	local ballRect = { x = ball.pos.x, y = ball.pos.y, w = ball.size.x, h = ball.size.y }
	if #(sh.rectInRect(padleft, ballRect)) > 0 or #(sh.rectInRect(padright, ballRect)) > 0 then
		ball.dir.x = -ball.dir.x
	else
		if ball.pos.y < 0 or ball.pos.y > h - ball.size.y then
			ball.dir.y = -ball.dir.y
		end
	end
end

local function updateScore()
	if ball.pos.x < 0 or ball.pos.x > w - ball.size.x then
		if ball.pos.x < 0 then
			score[2] = score[2] + 1;
		else
			score[1] = score[1] + 1;
		end
		resetPads()
	end
end

function love.update(dt)
	padleft.y = padHandlers[1](padleft.y, padySpeed, dt)
	padright.y = padHandlers[2](padright.y, padySpeed, dt)
	padleft.y = clamp(padleft.y, 0, h - padleft.h)
	padright.y = clamp(padright.y, 0, h - padright.h)
	updateBall(dt)
	updateScore()
end

function love.draw()
	local sct = { string.format("%d", score[1]), string.format("%d", score[2]) }
	local f = love.graphics.getFont()
	love.graphics.print(sct[1], w/2 - f:getWidth(sct[1]), 10)
	love.graphics.print(sct[2], w/2 + f:getWidth(sct[2]), 10)
	love.graphics.rectangle("fill", padleft.x, padleft.y, padleft.w, padleft.h)
	love.graphics.rectangle("fill", padright.x, padright.y, padright.w, padright.h)
	love.graphics.rectangle("fill", ball.pos.x, ball.pos.y, ball.size.x, ball.size.y)
end
