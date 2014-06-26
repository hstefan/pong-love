local gamestate = require "hump.gamestate"
local states = require "states"
local game = require "game"
local menu = require "menu"
local fonts = require "fonts"

function love.load()
	fonts.load()
	gamestate.registerEvents()
	gamestate.switch(menu)
end
