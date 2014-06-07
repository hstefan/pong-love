
local function resetPads()
	local w, h = love.window.getDimensions()
	local padw, padh = 30, 120
	local py = h/2 - padh/2
	padleft = { x = 0, y = py, w = padw, h = padh }
	padright = { x = w - padw, y = py, w = padw, h = padh }
end

local function clamp(v, l, r)
	if v > r then
		return r
	elseif v < l then
		return l
	else
		return v
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
