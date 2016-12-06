display.setStatusBar( display.TranslucentStatusBar )

-- Modules
local composer = require "composer"
--local keyListener = require "src.controller.keyListener"
local singletons = require "src.controller.singletons"
local ytgAnalytics = require "src.controller.ytgAnalytics"

-- Define composer state variables (to be used extremely sparingingly)
composer.state = {}
composer.state.returnTo = nil
composer.state.lastModel = nil
composer.state.singletonsI = singletons.new()

-- Modules that use state data
local memoryManagement = require "src.controller.memoryManagement"

-- Global constants (use _ to signify global variables)
_W = display.contentWidth  -- the width of the screen
_H = display.contentHeight -- the height of the screen

-- loadsave - Library for saving and loading
_loadsave = require "src.libs.loadsave"

-- Load saved data into a global saves table.
_saves = _loadsave.loadData()


local function main()

    -- Check to see if this is the first time that the app was opened.
    -- If it is the first time then call the erase data function wich will set all intital values of the app saved data.
    if (_saves == nil) then
        memoryManagement.eraseAllData()

        local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()
        ytgAnalyticsI.track(ytgAnalytics.APP_INSTALLED)
    end

    -- Set composer to recycle on scene change, 
    -- or create a new scene everytime that scene is launched vs simpily hiding the display group.
    composer.recycleOnSceneChange = true  

    composer.gotoScene("src.view.scenes.splash")

    return
end

main()