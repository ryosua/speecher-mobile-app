local appBackground = {}

function appBackground.new()
    local this = display.newRect(0, 0, _W, _H)
    this:setFillColor(224/255, 177/255, 58/255)
    this.anchorX = 0
    this.anchorY = 0
    
    return this
end

return appBackground