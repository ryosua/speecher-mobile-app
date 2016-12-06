--[[
	The slide that is shown before the speech is played.
]]--

local startSlide = {}

function startSlide.new(onStartPress)
    local this = display.newGroup()

	local textOptions =
    {
        text = "Press the play button to start the speech",     
        x = _W * .5,
        y = _H * .4,
        font = native.systemFontBold,   
        fontSize = 40,
        align = "center",
        width = _W * .95
    }

    local getReadyText = display.newText(textOptions)
    getReadyText:setFillColor(0, 0, 0)

    function this.setText(text)
        getReadyText.text = text
    end

    local startButton = display.newImage("images/arrow.png")
    startButton.xScale = .25
    startButton.yScale = startButton.xScale
    startButton.x = _W * .5
    startButton.y = _H * .5
    startButton:addEventListener("tap", onStartPress)

    this:insert(getReadyText)
    this:insert(startButton)

    return this
end

return startSlide