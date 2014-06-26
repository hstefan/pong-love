local menu = { }

local states = require "states"
states.menu = menu
local gamestate = require "hump.gamestate"
local fonts = require "fonts"

function menu:init()
	menu.window = {}
	menu.window.w, menu.window.h = love.window.getDimensions()
end

local function drawControlsBox(center, playerId, numPlayers)
	local keyboardMsg, joystickMsg = "KEYBOARD", "JOYSTICK"

	local playerStr = string.format("P%d", playerId + 1)
	local baseY = 180 + 0.5 * (playerId + 1) * numPlayers * fonts.small:getHeight(playerStr) + playerId * 20
	local xi, xf = 30, menu.window.w - (fonts.small:getWidth(joystickMsg) + 30)
	local xm = 0.5 * ((xi + fonts.small:getWidth(playerStr)) + xf)

	love.graphics.setFont(fonts.small)
	love.graphics.print(playerStr, xi, baseY)
	love.graphics.print(keyboardMsg, xm - 0.5 * fonts.small:getWidth(keyboardMsg), baseY)
	love.graphics.print(joystickMsg, xf, baseY)
end

function menu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	love.graphics.print("PAUSED", menu.window.w/2 - fonts.big:getWidth("PAUSED")/2, 30)

	local center = { x = menu.window.w * 0.5, y = menu.window.h * 0.5 }
	drawControlsBox(center, 0, 2)
	drawControlsBox(center, 1, 2)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	love.graphics.print("QUIT", menu.window.w * 0.5 - fonts.big:getWidth("QUIT") * 0.5,
		menu.window.h - fonts.big:getHeight())
end

function menu:keyreleased(key, code)
	if key == 'escape' then
		gamestate.switch(states.game)
	end
end

function menu:update(dt)
end

return menu
