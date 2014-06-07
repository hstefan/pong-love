
local function resetPads()
	local w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
end

function love.load()
	resetPads()
end

function love.update(dt)
	if love.keyboard.isDown("up") then
		padleft.y = padleft.y - 100 * dt
	elseif love.keyboard.isDown("down") then
		padleft.y = padleft.y + 100 * dt
	end
	if love.keyboard.isDown("w") then
		padright.y = padright.y - 100 * dt
	elseif love.keyboard.isDown("r") then
		padright.y = padright.y + 100 * dt
	end
end

function love.draw()
	love.graphics.rectangle("fill", padleft.x, padleft.y, padleft.w, padleft.h)
	love.graphics.rectangle("fill", padright.x, padright.y, padright.w, padright.h)
end
