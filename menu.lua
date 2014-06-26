local menu = { }

local states = require "states"
states.menu = menu
local gamestate = require "hump.gamestate"

function menu:init()
	menu.window = {}
	menu.window.w, menu.window.h = love.window.getDimensions()
end

function menu:draw()
	local f = love.graphics.getFont()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("PAUSED", menu.window.w/2 - f:getWidth("PAUSED")/2, 80)
end

function menu:keyreleased(key, code)
	if key == 'escape' then
		gamestate.switch(states.game)
	end
end

return menu
