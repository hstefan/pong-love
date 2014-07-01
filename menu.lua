local menu = { }

local states = require "states"
states.menu = menu
local gamestate = require "hump.gamestate"
local fonts = require "fonts"
local shapes = require "shapes"
local inputs = require "inputs"
local game = require "game"

local controlsRects = {}

function table.contains(table, elem)
	for _, val in pairs(table) do
		if val == elem then
			return true
		end
	end
	return false
end

function menu:init()
	menu.window = {}
	menu.window.w, menu.window.h = love.window.getDimensions()
	game.difficulty = 2
	difficultyRects = {}
end

local function drawControlsBox(center, playerId, numPlayers)
	local keyboardMsg, joystickMsg = "KEYBOARD", "JOYSTICK"

	local playerStr = string.format("P%d", playerId)
	local baseY = 130 + 0.5 * playerId * numPlayers * fonts.small:getHeight(playerStr) + playerId * 20
	local xi, xf = 30, menu.window.w - (fonts.small:getWidth(joystickMsg) + 30)
	local xm = 0.5 * ((xi + fonts.small:getWidth(playerStr)) + xf) - 0.5 * fonts.small:getWidth(keyboardMsg)
	
	love.graphics.setFont(fonts.small)
	love.graphics.print(playerStr, xi, baseY)
	love.graphics.print(keyboardMsg, xm, baseY)
	
	if not inputs.joystickAllowed(playerId) then
		love.graphics.setColor(120, 120, 120, 255)
	end
	
	love.graphics.print(joystickMsg, xf, baseY)
	love.graphics.setColor(255, 255, 255, 255)

	local selHeight = math.max(fonts.small:getHeight(keyboardMsg), fonts.small:getHeight(joystickMsg))
	local selWidth = math.max(fonts.small:getWidth(keyboardMsg), fonts.small:getWidth(joystickMsg))
	local selCenter = xm + fonts.small:getWidth(keyboardMsg)/2
	if inputs.selected[playerId] == "js" then
		selCenter = xf + fonts.small:getWidth(joystickMsg)/2
	end

	controlsRects[playerId] = {}
	controlsRects[playerId].keyboardRect = { x = xm, y = baseY,
		w = fonts.small:getWidth(keyboardMsg),
		h = fonts.small:getHeight(keyboardMsg)
	}
	controlsRects[playerId].joystickRect = { x = xf, y = baseY,
		w = fonts.small:getWidth(joystickMsg),
		h = fonts.small:getHeight(joystickMsg)
	}

	love.graphics.rectangle("fill", selCenter - selWidth/2, baseY + selHeight, selWidth, 4)
end

function drawDifficultyBox(center)
	local msgs = { easy = "EASY", medium = "MEDIUM", hard = "HARD" }
	love.graphics.setColor(255, 255, 255, 255)
	local font = fonts.small
	love.graphics.setFont(font)
	local baseY = 380
	local xi, xf = 30, menu.window.w - (font:getWidth(msgs.hard) + 30)
	local xm = center.x - font:getWidth(msgs.medium)/2
	local m = { { msg = msgs.easy, x = xi }, { msg = msgs.medium, x = xm }, { msg = msgs.hard, x = xf } }
	for i, v in ipairs(m) do
		love.graphics.setColor(120, 120, 120, 255)
		if game.difficulty == i then
			love.graphics.setColor(255, 255, 255, 255)
		end
		difficultyRects[i] = { x = v.x, y = baseY, w = font:getWidth(v.msg), h = font:getHeight(v.msg) }
		love.graphics.print(v.msg, v.x, baseY)
	end
end

function menu:draw()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	love.graphics.print("PAUSED", menu.window.w/2 - fonts.big:getWidth("PAUSED")/2, 30)
	love.graphics.setFont(fonts.tiny)
	local resumeMsg = "START/ESC TO RESUME"
	love.graphics.print(resumeMsg, menu.window.w/2 - fonts.tiny:getWidth(resumeMsg)/2, 30 +
		fonts.big:getHeight("PAUSED"))

	local center = { x = menu.window.w * 0.5, y = menu.window.h * 0.5 }
	drawControlsBox(center, 1, 2)
	drawControlsBox(center, 2, 2)

	drawDifficultyBox(center)

	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(fonts.big)
	local restartMsg = "RESTART"
	menu.restartRect = { x = menu.window.w * 0.5 - fonts.big:getWidth(restartMsg) * 0.5,
		y = menu.window.h - 2 * fonts.big:getHeight(restartMsg),
		w = fonts.big:getWidth(restartMsg),
		h = fonts.big:getHeight(restartMsg)}
	love.graphics.print(restartMsg, menu.restartRect.x, menu.restartRect.y)

	local quitMsg = "QUIT"
	menu.quitRect = { x = menu.window.w * 0.5 - fonts.big:getWidth(quitMsg) * 0.5,
		y = menu.window.h - fonts.big:getHeight(quitMsg),
		w = fonts.big:getWidth(quitMsg),
		h = fonts.big:getHeight(quitMsg)}
	love.graphics.print(quitMsg, menu.quitRect.x, menu.quitRect.y)
end

function menu:keyreleased(key, code)
	if key == 'escape' then
		gamestate.switch(states.resuming)
	end
end

function menu:update(dt)
	for i = 1, 2 do
		if inputs.joystickAllowed(i) then
			local axis = inputs.jsData[i].js:getAxis(1)
			if axis > 0.5 then
				inputs.selected[i] = "js"
			elseif axis < -0.5 then
				inputs.selected[i] = "kb"
			end
		end
	end
end

function menu:mousereleased(x, y, mouseBtn)
	if mouseBtn == "l" then
		local pt = { x = x, y = y }
		if shapes.pointInRect(pt, menu.quitRect) then
			love.event.push("quit")
		end
		if shapes.pointInRect(pt, menu.restartRect) then
			game.reset()
			gamestate.switch(states.resuming)
		end
		for i = 1,2 do
			if shapes.pointInRect(pt, controlsRects[i].keyboardRect) then
				inputs.selected[i] = "kb"
			end
			if inputs.joystickAllowed(i) then
				if shapes.pointInRect(pt, controlsRects[i].joystickRect) then
					inputs.selected[i] = "js"
				end
			end
		end
		for i, v in pairs(difficultyRects) do
			if shapes.pointInRect(pt, v) then
				game.difficulty = i
			end
		end
	end
end

function menu:joystickreleased(joystick, button)
	if button == 8 then
		gamestate.switch(states.resuming)
	end
end

return menu
