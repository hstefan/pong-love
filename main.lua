local gamestate = require "hump.gamestate"
local states = require "states"
local game = require "game"
local menu = require "menu"

function love.load()
	love.graphics.setNewFont("data/slkscre.ttf", 64)
	gamestate.registerEvents()
	gamestate.switch(menu)
end
