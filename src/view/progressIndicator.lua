local progressIndcator = {}

function progressIndcator.new()
	local this = display.newRect(0, _H, 0, _H * .01)
	this.anchorX = 0
	this.anchorY = 1

	function this.setProgress(percent)
		this.width = percent * _W
	end

	return this
end

return progressIndcator