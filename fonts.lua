local fonts = {}

function fonts.load()
	fonts.small = love.graphics.setNewFont("data/slkscre.ttf", 40)
	fonts.big = love.graphics.setNewFont("data/slkscre.ttf", 64)
end

return fonts
