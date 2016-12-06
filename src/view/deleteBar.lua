local deleteBar = {}

function deleteBar.new()
    local this = display.newGroup()

    local backgroundHeight = _H * .11

    local background = display.newRect(0, 0, _W, backgroundHeight)
    background:setFillColor(.600, 0, 0)
    background.anchorX = 0
    background.anchorY = 0
    this.alpha = 0

    local textOptions =
    {
        text = "Drag here to delete",     
        x = _W * .5,
        y = background.contentHeight * .5,
        font = native.systemFontBold,
        fontSize = 40,
        align = "center"
    }
    text = display.newText(textOptions)
    text.anchorX = .5
    text.anchorY = .5
    text.alpha = .5

    this:insert(background)
    this:insert(text)

    return this
end

return deleteBar