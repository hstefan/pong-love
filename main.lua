local sh = require "shapes"
local vector = require "hump.vector"

local function initBall() 
	ball = {}
	ball.size = vector(20, 20)
	ball.pos = vector(w/2 - ball.size.x/2, h/2 - ball.size.y/2)
	ball.dir = vector(math.random(2), math.random(2)):normalize_inplace()
	ball.speed = 400
end

local function initPaddle(paddle, offset)
	paddle.size = vector(30, 120)
	paddle.pos = vector(0, h / 2 - paddle.size.y / 2) + offset
	paddle.maxSpeed = 400
end

local function resetPads()
	w, h = love.window.getDimensions()
	initBall()
	padleft = {}
	padright = {}
	initPaddle(padleft, vector(0, 0))
	initPaddle(padright, vector(w - 30, 0))
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
	local leftPaddleRect = { x = padleft.pos.x, y = padleft.pos.y, w = padleft.size.x, h = padleft.size.y }
	local rightPaddleRect = { x = padright.pos.x, y = padright.pos.y, w = padright.size.x, h = padright.size.y }
	if #(sh.rectInRect(leftPaddleRect, ballRect)) > 0 or #(sh.rectInRect(rightPaddleRect, ballRect)) > 0 then
		ball.dir.x = -ball.dir.x
	elseif ball.pos.y < 0 or ball.pos.y > h - ball.size.y then
			ball.dir.y = -ball.dir.y
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
	padleft.pos.y = padHandlers[1](padleft.pos.y, padleft.maxSpeed, dt)
	padright.pos.y = padHandlers[2](padright.pos.y, padleft.maxSpeed, dt)
	padleft.pos.y = clamp(padleft.pos.y, 0, h - padleft.size.y)
	padright.pos.y = clamp(padright.pos.y, 0, h - padright.size.y)
	updateBall(dt)
	updateScore()
end

function love.draw()
	local sct = { string.format("%d", score[1]), string.format("%d", score[2]) }
	local f = love.graphics.getFont()
	love.graphics.print(sct[1], w/2 - f:getWidth(sct[1]), 10)
	love.graphics.print(sct[2], w/2 + f:getWidth(sct[2]), 10)
	love.graphics.rectangle("fill", padleft.pos.x, padleft.pos.y, padleft.size.x, padleft.size.y)
	love.graphics.rectangle("fill", padright.pos.x, padright.pos.y, padright.size.x, padright.size.y)
	love.graphics.rectangle("fill", ball.pos.x, ball.pos.y, ball.size.x, ball.size.y)
end
