local game = {}

local states = require "states"
states.game = game

local vector = require "hump.vector"
local shapes = require "shapes"
local gamestate = require "hump.gamestate"
local fonts = require "fonts"
local inputs = require "inputs"

local score = { 0, 0 }

local function clamp(v, l, r)
	if v > r then
		return r
	elseif v < l then
		return l
	else
		return v
	end
end

local function initPaddle(paddle, offset, normal)
	paddle.size = vector(30, 120)
	paddle.pos = vector(0, h / 2 - paddle.size.y / 2) + offset
	paddle.maxSpeed = 800
	paddle.normal = normal
end

local function initBall()
	ball = {}
	local vels = { 1, -1 }
	ball.size = vector(20, 20)
	ball.pos = vector(w/2 - ball.size.x/2, h/2 - ball.size.y/2)
	ball.dir = vector(vels[math.random(2)], vels[math.random(2)]):normalize_inplace()
	ball.speed = 700
end

local function resetPads()
	w, h = love.window.getDimensions()
	initBall()
	padleft = {}
	padright = {}
	initPaddle(padleft, vector(0, 0), vector(1, 0))
	initPaddle(padright, vector(w - 30, 0), vector(-1, 0))
end

local function reflectedDir(paddle)
	local mul = -1
	local yBallOrig = ball.pos.y - paddle.pos.y
	local yRel = clamp(yBallOrig/paddle.size.y - 0.5, -0.5, 0.5)
	mul = mul - yRel
	return vector(mul * ball.dir.x, ball.dir.y):normalize_inplace()
end

local function updateBall(dt)
	local ballRect = { x = ball.pos.x, y = ball.pos.y, w = ball.size.x, h = ball.size.y }
	local leftPaddleRect = { x = padleft.pos.x, y = padleft.pos.y, w = padleft.size.x, h = padleft.size.y }
	local rightPaddleRect = { x = padright.pos.x, y = padright.pos.y, w = padright.size.x, h = padright.size.y }
	local oldDir = ball.dir
	if #(shapes.rectInRect(leftPaddleRect, ballRect)) > 0 then
		ball.dir = reflectedDir(padleft)
		local rightBorder = leftPaddleRect.x + 1.05 * leftPaddleRect.w
		ball.pos.x = ball.pos.x + (rightBorder - ball.pos.x)
		pongClip:setPitch(math.abs(oldDir.x/ball.dir.x))
		pongClip:play()
	elseif #(shapes.rectInRect(rightPaddleRect, ballRect)) > 0 then
		ball.dir = reflectedDir(padright)
		local rightSideBall = ball.pos.x + ball.size.x
		local leftPaddleBorder = rightPaddleRect.x - rightPaddleRect.w * 0.05
		ball.pos.x = ball.pos.x - (rightSideBall - leftPaddleBorder)
		pongClip:setPitch(math.abs(oldDir.x/ball.dir.x))
		pongClip:play()
	elseif ball.pos.y < 0 or ball.pos.y > h - ball.size.y then
		ball.dir.y = -ball.dir.y
	end
	ball.pos = ball.pos + dt * ball.speed * ball.dir
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

local function handleKeyboard(v, pos, neg, sc, dt)
	if love.keyboard.isDown(neg) then
		return v - sc * dt
	elseif love.keyboard.isDown(pos) then
		return v + sc * dt
	else
		return v
	end
end

local function handleJoystick(id, v, sc, dt)
	local axis = inputs.jsData[id].js:getAxis(2)
	if math.abs(axis) < 0.4 then
		return v
	else
		return v + (axis * dt * sc)
	end
end

function game:enter()
	padHandlers = { function(y, spd, dt) return handleKeyboard(y, "down", "up", spd, dt) end,
		function(y, spd, dt) return handleKeyboard(y, "r", "w", spd, dt) end }
	for k, v in ipairs(inputs.selected) do
		if v == "js" then
			padHandlers[k] = function(y, spd, dt) return handleJoystick(k, y, spd, dt) end
		end
	end
end

function drawAll()
	local sct = { string.format("%d", score[1]), string.format("%d", score[2]) }
	local f = love.graphics.getFont()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	love.graphics.print(sct[1], w/2 - f:getWidth(sct[1]), 10)
	love.graphics.print(sct[2], w/2 + f:getWidth(sct[2]), 10)
	love.graphics.rectangle("fill", padleft.pos.x, padleft.pos.y, padleft.size.x, padleft.size.y)
	love.graphics.rectangle("fill", padright.pos.x, padright.pos.y, padright.size.x, padright.size.y)
	love.graphics.rectangle("fill", ball.pos.x, ball.pos.y, ball.size.x, ball.size.y)

	local ballCenter = ball.pos + 0.5 * ball.size
	local length = 30
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.line(ballCenter.x, ballCenter.y,
		ballCenter.x + length * ball.dir.x,
		ballCenter.y + length * ball.dir.y)
	if reflectVec then
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.line(ballCenter.x, ballCenter.y,
			ballCenter.x + length * reflectVec.x,
			ballCenter.y + length * reflectVec.y)
	end
end

function game.reset()
	score = { 0, 0 }
	resetPads()
end

function game:init()
	math.randomseed(os.time())
	pongClip = love.audio.newSource('data/pong.ogg', 'static')
	game.reset()
end

function game:draw()
	drawAll()
end

function game:update(dt)
	padleft.pos.y = padHandlers[1](padleft.pos.y, padleft.maxSpeed, dt)
	padright.pos.y = padHandlers[2](padright.pos.y, padleft.maxSpeed, dt)
	padleft.pos.y = clamp(padleft.pos.y, 0, h - padleft.size.y)
	padright.pos.y = clamp(padright.pos.y, 0, h - padright.size.y)
	updateBall(dt)
	updateScore()
end

function game:joystickreleased(joystick, button)
	if button == 8 then
		gamestate.switch(states.menu)
	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		gamestate.switch(states.menu)
	end
end

return game
