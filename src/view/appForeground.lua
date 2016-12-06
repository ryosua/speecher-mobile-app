local appForeground = {}

function appForeground.new()
    local this = display.newRect(0, 0, _W, _H)
    this.anchorX = 0
    this.anchorY = 0
    this.alpha = .01
    
    return this
end

return appForeground