local slide = {}

-- Modules
local textShortener = require "src.controller.textShortener"
local widget = require "widget"

function slide.new(card, scrollViewListener)
    local scrollViewOptions =
    {
        width = _W,
        height= _H,
        backgroundColor = {224/255, 177/255, 58/255},
        horizontalScrollDisabled = true,
        listener  = scrollViewListener,
        bottomPadding =  _H * .05,
    }

    local this = widget.newScrollView(scrollViewOptions)

    local notes
    if card ~= nil then
        notes = card.notes
    end

    local slideX = _W * .1
    local slideY = _H * .12

    local textOptions =
    {
        text = card.title,     
        x = slideX,
        y = slideY,
        font = native.systemFontBold,   
        fontSize = 75,
        align = "left",
        width = _W * .85,
    }

    local cardTitle = display.newText(textOptions)
    cardTitle.anchorX = 0
    cardTitle.anchorY = 0
    cardTitle:setFillColor(0,0,0)
    
    if textShortener.shortenByHeight(cardTitle, _H * .15) == true then
        cardTitle.text = string.sub(cardTitle.text, 1, string.len(cardTitle.text) - 3)
    	cardTitle.text = cardTitle.text .. "..."
	end

    this:insert(cardTitle)

    local x = _W * .1
    local y = cardTitle.y + cardTitle.contentHeight + _H * .03

    for i = 1, #notes do
        local textOptions =
        {
            text = notes[i].text,     
            x = x,
            y = y,
            font = native.systemFontBold,   
            fontSize = _saves.noteFontSize,
            align = "left",
            width = _W * .85
        }

        local noteTextObject = display.newText(textOptions)
        noteTextObject.anchorX = 0
        noteTextObject.anchorY = 0
        noteTextObject:setFillColor(0,0,0)

        -- Move the next note down.
        y = y + noteTextObject.contentHeight * 1.3

        this:insert(noteTextObject)
    end

    return this
end

return slide