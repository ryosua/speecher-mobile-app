local emptySlide = {}

function emptySlide.new()
	local textOptions =
    {
        text = "You need to create some notecards before you can view the speech.",     
        x = .5 * _W,
        y = .5 * _H,
        width = _W * .95,
        font = native.systemFontBold,   
        fontSize = 40,
        align = "center"
    }

    local this = display.newText(textOptions)
    this.anchorX = .5
    this.anchorY = 0
    this:setFillColor(0,0,0)
    this.alpha = .5

    return this
end

return emptySlide