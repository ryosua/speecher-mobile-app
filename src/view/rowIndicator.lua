local rowIndicator = {}

function rowIndicator.new(x, y, width, height)
	local this = display.newRoundedRect(x, y, width, height, 10)
	
	return this
end

return rowIndicator