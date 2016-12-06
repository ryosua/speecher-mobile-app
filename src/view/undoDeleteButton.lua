local undoDeleteButton = {}

function undoDeleteButton.new()
    local this = display.newGroup()

    this.alpha = 0

    local button = display.newImage("images/undoDelete.png")
    button.x = _W
    button.y = _H * .99
    button.xScale = .70
    button.yScale = button.xScale 
    button.anchorX = 1
    button.anchorY = 1
    button.alpha = .25
    
    
    this:insert(button)

    return this
end

return undoDeleteButton