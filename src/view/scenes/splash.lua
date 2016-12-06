-- Modules
local composer = require "composer"
local memoryManagement = require "src.controller.memoryManagement"
local appBackground = require "src.view.appBackground"
local ytgAnalytics = require "src.controller.ytgAnalytics"

-- Memory management
local timers = {}

local background

local function changeScene()  
    composer.gotoScene("src.view.scenes.speechView")
    return true
end

local scene = composer.newScene()

local singletonsI = composer.state.singletonsI
local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()

function scene:create( event )
    local sceneGroup = self.view

    background = appBackground.new()
    background:addEventListener("tap", changeScene)

    local speecherText = display.newImage("images/workMark_250_white.png")
    speecherText.x = _W * .5
    speecherText.y = _H *  1/5
    speecherText.xScale = 2
    speecherText.yScale = speecherText.xScale

    local speecherLogo = display.newImage("images/speecherIcon.png")
    speecherLogo.x = _W * .5
    speecherLogo.y = speecherText.y + _H / 3
    speecherLogo.xScale = 2
    speecherLogo.yScale = speecherLogo.xScale

    local yosuatreegamesTextOptions =
        {
            text = "BY YOSUATREEGAMES",
            x = _W * .5,
            y = _H * .9,
            font = native.systemFontBold,   
            fontSize = 30,
            align = "left"
        }
    local yosuatreegamesText = display.newText(yosuatreegamesTextOptions)

    sceneGroup:insert(background)
    sceneGroup:insert(speecherLogo)
    sceneGroup:insert(speecherText)
    sceneGroup:insert(yosuatreegamesText)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        ytgAnalyticsI.track(ytgAnalytics.SPLASH_SCREEN_STARTED)

        -- Change scene automatically with timer.
        timers[#timers + 1] = timer.performWithDelay(2000, changeScene)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        memoryManagement.cancelAllTimers(timers)
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    -- Remove event listeners.
    background:removeEventListener("tap", changeScene)
end

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene