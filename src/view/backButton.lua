local backButton = {}

-- Modules
local composer = require "composer"

backButton.ALPHA = .25

function backButton.new()
    local size = 100
    local this = display.newImage("images/back.png")
    this.x = 0
    this.y = _H * .99
 
    this.xScale = .70
    this.yScale = this.xScale 
    this.anchorX = 0
    this.anchorY = 1
    this.alpha = backButton.ALPHA

    local function goBack()
        local lastScene = composer.state.returnTo
        print ("lastScene: " .. lastScene)

        if (lastScene ~= nil) then
            local params = composer.state.params
            composer.gotoScene(lastScene, params)
        end

        return true
    end

    this:addEventListener("tap", goBack)

    return this
end

return backButton