local topBar = {}

-- Modules
local composer = require "composer"
local textShortener = require "src.controller.textShortener"

function topBar.new()
    local this = display.newGroup()
    local background = display.newRect(0, 0, _W, _H * .11)
    background:setFillColor(4/255, 62/255, 80/255)
    background.anchorX = 0
    background.anchorY = 0

    local function goBack()
        local lastScene = composer.state.returnTo

        if (lastScene ~= nil) then
            local params = composer.state.params
            composer.gotoScene(lastScene, params)
        end

        return true
    end

    local textOptions =
    {
        text = "Text",     
        x = _W * .1,
        y = _H * .07,
        font = native.systemFontBold,
        fontSize = 50,
        align = "right"
    }
    text = display.newText(textOptions)
    text.anchorX = 0
    text.anchorY = .5
    text:addEventListener("tap", goBack)

    local settingsButton = display.newImage("images/gearWhite.png")
    settingsButton.xScale = .225
    settingsButton.yScale = settingsButton.xScale
    text.anchorY = .5
    settingsButton.x = _W * .9
    settingsButton.y = text.y

    local function changeScene()  
        composer.gotoScene("src.view.scenes.options")
        return true
    end

    settingsButton:addEventListener("tap", changeScene)

    function this.setText(newText)
        text.text = newText
        if textShortener.shortenByWidth(text, _W * .7) == true then
        	text.text = text.text .. "..."
    	end
    end

    this:insert(background)
    this:insert(settingsButton)
    this:insert(text)

    return this
end

return topBar