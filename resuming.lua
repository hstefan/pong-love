local resuming = {}

local gamestate = require "hump.gamestate"
local states = require "states"
states.resuming = resuming
local fonts = require "fonts"

function resuming:enter()
	local x, y = love.window.getDimensions()
	screenCenter = { x = x/2, y = y/2 }
	counter = 1
end

function resuming:draw()
	local ctMsg = string.format("%d", math.ceil(counter/1 * 3))
	love.graphics.setFont(fonts.big)
	love.graphics.print(ctMsg,
		screenCenter.x - fonts.big:getWidth(ctMsg)/2,
		screenCenter.y - fonts.big:getHeight(ctMsg)/2)
end

function resuming:update(dt)
	counter = counter - dt
	if counter <= 0 then
		gamestate.switch(states.game)
	end
end

function resuming:keyreleased(key, code)
	if key == 'escape' then
		gamestate.switch(states.menu)
	end
end

function resuming:joystickreleased(joystick, button)
	if button == 8 then
		gamestate.switch(states.menu)
	end
end

return resuming
