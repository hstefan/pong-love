local gamestate = require "hump.gamestate"
local states = require "states"
local game = require "game"
local menu = require "menu"
local resuming = require "resuming"
local fonts = require "fonts"
local inputs = require "inputs"

function love.load()
	fonts.load()
	gamestate.registerEvents()
	gamestate.switch(menu)
end

function love.quit()
	print("Bye!")
end
