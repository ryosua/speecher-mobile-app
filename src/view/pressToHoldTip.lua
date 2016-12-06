local pressToHoldTip = {}

function pressToHoldTip.new(text)
	local textOptions =
	{
	    text = text,     
	    x = _W * .5,
	    y = _H * .7,
	    width = _W * .60,
	    font = native.systemFontBold,
	    fontSize = 40,
	    align = "center"
	}
	this = display.newText(textOptions)
	this.anchorX = .5
	this.anchorY = .5
	this.alpha = 0

	function this.animate()
		local function hide()
			local hideTimer = timer.performWithDelay(10000, function()
				this.alpha = 0
			end )
		end

		local fadeIn = transition.fadeIn( this, { time=500, onComplete=hide } )
	end

	return this
end

return pressToHoldTip