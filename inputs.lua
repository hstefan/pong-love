local inputs = {}

inputs.allowed = { { "kb" }, { "kb" } }
inputs.selected = { { "kb " }, { "kb" } }
inputs.jsData = { {}, {} }

function love.joystickadded(joystick)
	for i=1,2 do
		if next(inputs.jsData[i]) == nil then
			inputs.jsData[i].id = joystick:getID()
			inputs.jsData[i].js = joystick
			inputs.allowed[i][2] = "js"
			break
		end
	end
end

function love.joystickremoved(joystick)
	for i=1,2 do
		if inputs.jsData[i].id == joystick:getID() then
			inputs.jsData[i] = {}
			if inputs.selected[i] == "js" then
				inputs.selected[i] = "kb"
			end
			inputs.allowed[i][2] = nil
		end
	end
end

function inputs.joystickAllowed(playerId)
	for _, val in pairs(inputs.allowed[playerId]) do
		if val == "js" then
			return true
		end
	end
	return false
end

return inputs
