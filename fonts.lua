local fonts = {}

function fonts.load()
	fonts.tiny = love.graphics.setNewFont("data/slkscre.ttf", 16)
	fonts.small = love.graphics.setNewFont("data/slkscre.ttf", 42)
	fonts.big = love.graphics.setNewFont("data/slkscre.ttf", 64)
end

return fonts
