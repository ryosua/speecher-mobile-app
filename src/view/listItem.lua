local listItem = {}

--[[
    Code not used!

    For reference only.
]]--

-- Modules
local composer = require "composer"

function listItem.new(x, y, model, onTextTapListener, onCardTap, textAttributeName, isSpeech)
    local this = display.newGroup()

    local rectangleWidth = _W * .6
    local rectangleHeight = _H * .1
    local rectangle = display.newRect(x, y, rectangleWidth, rectangleHeight)
    rectangle.anchorX = 0
    rectangle.anchorY = 0
    rectangle.model = model
    rectangle:addEventListener("tap", onCardTap)

    local speechArrow = nil

    if isSpeech == true then
        local textOptions =
        {
            text = ">",     
            x = x,
            y = y,
            font = native.systemFontBold,   
            fontSize = 50,
            align = "left"
        }

        speechArrow = display.newText(textOptions)
        speechArrow.anchorX = 0
        speechArrow.anchorY = 0
        speechArrow:setFillColor(0,0,0)

        -- Move x value over for placement of the speech title
        x = x + speechArrow.contentWidth

        local function onArrowTap(e)
            --[[
            if speechArrow.text == ">" then
                speechArrow.text = "v"
            else
                speechArrow.text = ">"
            end
            ]]--

            local options =
            {
                time = 0,
                params =
                {
                    speech = model,
                }
            }
            composer.gotoScene("src.view.scenes.deliver", options)

            return true
        end

        speechArrow:addEventListener("tap", onArrowTap)
    end

    local textOptions =
    {
        text = model[textAttributeName],     
        x = x,
        y = y,
        width = rectangleWidth,
        height = rectangleHeight / 2,
        font = native.systemFontBold,   
        fontSize = 50,
        align = "left"
    }

    local textObject = display.newText(textOptions)
    textObject.anchorX = 0
    textObject.anchorY = 0
    textObject:addEventListener("tap", onTextTapListener)
    textObject.model = model
    textObject:setFillColor(0,0,0)

    this.textObject = textObject

    this:insert(rectangle)
    if isSpeech == true then
        this:insert(speechArrow)
    end
    this:insert(textObject)

    function this.getX()
        return x
    end

    function this.getY()
        return y
    end

    return this
end

return listItem