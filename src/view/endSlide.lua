--[[
	The slide that is shown when the speech is over.
]]--

local endSlide = {}

function endSlide.new()
	local this = display.newGroup()

    local slideBackground = display.newRect(0, 0, _W, _H)
    slideBackground.anchorX = 0
    slideBackground.anchorY = 0
    slideBackground.alpha = .01

    local textOptions =
    {
        text = "Great job! You finished the speech.",     
        x = _W * .5,
        y = _H * .5,
        font = native.systemFontBold,   
        fontSize = 40,
        align = "center"
    }

    local textObect = display.newText(textOptions)
    textObect:setFillColor(0, 0, 0)

    this:insert(slideBackground)
    this:insert(textObect)

    return this
end

return endSlide