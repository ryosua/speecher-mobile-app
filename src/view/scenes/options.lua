-- Modules
local appBackground = require "src.view.appBackground"
local backButton = require "src.view.backButton"
local composer = require "composer"
local topBar = require "src.view.topBar"
local widget = require "widget"
local ytgAnalytics = require "src.controller.ytgAnalytics"

local scene = composer.newScene()

local singletonsI = composer.state.singletonsI
local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()

function scene:create( event )
    local sceneGroup = self.view

    local background = appBackground.new()

    local topBarI = topBar.new()
    topBarI.setText("Options")

    local labelSize = 50

    local options = 
    {
        text = "Font size",     
        x = _W * .1,
        y = topBarI.contentHeight + topBarI.contentHeight * .1,
        font = native.systemFontBold,   
        fontSize = labelSize,
        align = "left"  --new alignment parameter
    }

    local fontSizeLabel = display.newText(options)
    fontSizeLabel.anchorX = 0
    fontSizeLabel.anchorY = 0
    fontSizeLabel:setFillColor(1, 1, 1)

    local function sliderListener(e)
        local fontSize = e.value
        local minimumFontSize = 50
        local maximumFontSize = 150

        fontSize = (e.value/ 100 * (maximumFontSize - minimumFontSize)) + minimumFontSize

        _saves.noteFontSize = math.round(fontSize)
        _saves.noteFontSizeSliderValue = e.value
        print(_saves.noteFontSize)
    end
    
    -- Image sheet options and declaration
    local sliderOptions = {
        frames = {
            { x=0, y=0, width=150, height=150},
            { x=150, y=0, width=150, height=150},
            { x=300, y=0, width=150, height=150},
            { x=450, y=0, width=150, height=150},
            { x=600, y=0, width=150, height=150}
        },
        sheetContentWidth = 750,
        sheetContentHeight = 150
    }
    local fontSizeSliderSheet = graphics.newImageSheet( "images/sliderWidget.png", sliderOptions )
        
    -- Create the widget
    local fontSizesSlider = widget.newSlider(
        {
            sheet = fontSizeSliderSheet,
            leftFrame = 1,
            middleFrame = 2,
            rightFrame = 3,
            fillFrame = 4,
            handleFrame = 5,
            frameWidth = 150,
            frameHeight = 150,
            handleWidth = 150,
            handleHeight = 150,
            top = fontSizeLabel.y + _H * .1,
            left = _W*.01,
            orientation = "horizontal",
            width = 750,
            value = _saves.noteFontSizeSliderValue,
            listener = sliderListener
        }
    )

    local recordSpeechTextOptions = 
    {
        text = "Record Speech Audio",     
        x = fontSizeLabel.x,
        y = fontSizesSlider.y + fontSizesSlider.contentHeight,
        font = native.systemFontBold,   
        fontSize = labelSize,
        align = "left"  --new alignment parameter
    }

    local recordSpeechText = display.newText(recordSpeechTextOptions)
    recordSpeechText.anchorX = 0
    recordSpeechText.anchorY = 0
    recordSpeechText:setFillColor(1, 1, 1)

	local function onSwitchPress( event )
	    local switch = event.target

	    _saves.recordSpeeches = switch.isOn
	    _loadsave.saveData(_saves)

	    return true
	end
    
    -- Image sheet options and declaration
    local options = {
        width = 600,
        height = 600,
        numFrames = 2,
        sheetContentWidth = 1200,
        sheetContentHeight = 600
    }
    local checkboxSheet = graphics.newImageSheet( "images/speechRadio.png", options )

	local checkboxButton = widget.newSwitch(
	    {
	        left = recordSpeechText.x,
	        top = recordSpeechText.y + recordSpeechText.contentHeight,
	        style = "checkbox",
	        id = "Checkbox",
	        onPress = onSwitchPress,
            sheet = checkboxSheet,
            height = 150,
            width = 150,
            frameOff = 1,
            frameOn = 2
	    }
	)
	checkboxButton:setState(
		{
			isOn = _saves.recordSpeeches
		}
	)

    local backButton = backButton.new()

    sceneGroup:insert(background)
    sceneGroup:insert(topBarI)
    sceneGroup:insert(fontSizeLabel)
    sceneGroup:insert(fontSizesSlider)
    sceneGroup:insert(recordSpeechText)
    sceneGroup:insert(checkboxButton)
    sceneGroup:insert(backButton)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        ytgAnalyticsI.track(ytgAnalytics.OPTIONS_SCREEN_STARTED)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then

    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene