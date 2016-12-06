-- Modules
local appBackground = require "src.view.appBackground"
local audioController = require "src.controller.audioController"
local backButton = require "src.view.backButton"
local composer = require "composer"
local emptySlide = require "src.view.emptySlide"
local endSlide = require "src.view.endSlide"
local keyListener = require "src.controller.keyListener"
local memoryManagement = require "src.controller.memoryManagement"
local platform = require "src.model.platform"
local progressIndicator = require "src.view.progressIndicator"
local slide = require "src.view.slide"
local startSlide = require "src.view.startSlide"
local swipeListener = require "src.controller.swipeListener"
local timeUtil = require "src.util.timeUtil"
local topBar = require "src.view.topBar"
local ytgAnalytics = require "src.controller.ytgAnalytics"

local scene = composer.newScene()

local singletonsI = composer.state.singletonsI
local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()

local cardsToDisplay
local cycleSlidesDown
local cycleSlidesUp
local keyListenerI
local nextSlide
local progressIndicatorI
local recording
local recordingStarted = false
local speechRecordingControllerI
local ticker

local function startRecording(cardsToDisplay)
    if _saves.recordSpeeches == true and cardsToDisplay == true then
        -- Create a new speech recording
        local speechRecordingModel = speechRecordingControllerI.createModel(os.date( "%c" ))
        local filePath = system.pathForFile( speechRecordingModel.filename .. platform.audioFormat, system.DocumentsDirectory )
        recording = media.newRecording( filePath )
    
        -- Start recording
        recording:startRecording()
        recordingStarted = true
    end
end

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "src.view.scenes.speechView"

    local speech = event.params.speech

    local speechTimerText
    local timerTextBackground
    local recordingIndicator

    -- Set up the controllers.
    local audioControllerI = audioController.new()
    speechRecordingControllerI = singletonsI.getSpeechRecordingControllerI(speech, audioControllerI)

    local background = appBackground.new()

    local topBarI = topBar.new()
    topBarI.setText(speech.title)

    -- Whether or not there are cards to display
    cardsToDisplay = #speech.cards > 0

    local function onStartPress()
        speechTimerText.alpha = 1
        timerTextBackground.alpha = 1
        nextSlide()
        memoryManagement.resumeTimer(ticker)

        if recordingStarted == false then
            startRecording(cardsToDisplay)
        end
    end

    local slideI
    if cardsToDisplay == true then
        slideI = startSlide.new(onStartPress)
    else
        slideI = emptySlide.new()
    end

    local slideCursor = 0

    local function cycleSlides(index)
        -- Remove old slide
        display.remove(slideI)
        slideI = nil

        --[[
            Create new slide for next card.

            If the index is greater than the number of cards in the speech, display the end card,
            otherwise create a new slide with the current notecard.
        ]]--
        if index > #speech.cards then
            memoryManagement.pauseTimer(ticker)
            slideI = endSlide.new()
            slideI:addEventListener("touch", swipeListener.new(cycleSlidesUp, cycleSlidesDown))

            if recordingIndicator ~= nil then
                recordingIndicator.alpha = 0
            end
        elseif index == 0 then
            memoryManagement.pauseTimer(ticker)
            slideI = startSlide.new(onStartPress)
            slideI.setText("Press the play button to resume your speech.")
            speechTimerText.alpha = 0
            timerTextBackground.alpha = 0
            if recordingIndicator ~= nil then
                recordingIndicator.alpha = 0
            end
        else
            memoryManagement.resumeTimer(ticker)
            slideI = slide.new(speech.cards[index], swipeListener.new(cycleSlidesUp, cycleSlidesDown))

            if recordingIndicator ~= nil then
                recordingIndicator.alpha = 1
            end
        end

        -- Whether or not the recording indicator is in the scene group changes the number of elements in the scene group
        if sceneGroup.numChildren == 7 then
            sceneGroup:insert(sceneGroup.numChildren - 5, slideI)
        else
            sceneGroup:insert(sceneGroup.numChildren - 4, slideI)
        end

        progressIndicatorI.setProgress(index/#speech.cards)
    end

    function nextSlide()
        slideCursor = slideCursor + 1
        cycleSlides(slideCursor)
    end

    function cycleSlidesUp()
        if slideCursor <= #speech.cards + 1 and slideCursor > 0 then
            nextSlide()
        end
    end

    function cycleSlidesDown()
        if slideCursor >= 1 then
            slideCursor = slideCursor - 1
            cycleSlides(slideCursor)
        end
    end

    -- If there are no cards to display then don't attach the listener to change slides,
    -- and don't display the timer.

    if cardsToDisplay then
        local textOptions =
        {
            text = "00:00",     
            x = _W * .5,
            y = _H * .9,
            font = native.systemFontBold,
            fontSize = 75,
            align = "center"
        }



        speechTimerText = display.newText(textOptions)
        speechTimerText.anchorX = .5
        speechTimerText.anchorY = .5
        speechTimerText:setFillColor(0,0,0)
        speechTimerText.alpha = 0

        local scaleFactor = 1.25
        timerTextBackground = display.newRoundedRect(speechTimerText.x, speechTimerText.y, speechTimerText.contentWidth * scaleFactor, speechTimerText.contentHeight * scaleFactor, 50)
        timerTextBackground.alpha = 0

        local seconds = 0
        local function onSecondTick()
            seconds = seconds + 1
            speechTimerText.text = timeUtil.secondsToDigitalTime(seconds)
        end

        ticker = timer.performWithDelay(1000, onSecondTick, 0)
        memoryManagement.pauseTimer(ticker)

        if _saves.recordSpeeches == true then
            recordingIndicator = display.newImage("images/record.png")
            recordingIndicator.x = speechTimerText.x + speechTimerText.contentWidth * .9
            recordingIndicator.y = speechTimerText.y
            recordingIndicator.xScale = .15
            recordingIndicator.yScale = recordingIndicator.xScale
            recordingIndicator.anchorX = .5
            recordingIndicator.anchorY = .5
            recordingIndicator.alpha = 0
         end
    end

    local backButton = backButton.new()

    -- Add the key callback.
    keyListenerI = keyListener.new(cycleSlidesUp, cycleSlidesDown)
    Runtime:addEventListener("key", keyListenerI.onKeyEvent)

    progressIndicatorI = progressIndicator.new()

    sceneGroup:insert(background)
    sceneGroup:insert(slideI)
    sceneGroup:insert(backButton)
    sceneGroup:insert(topBarI)
    sceneGroup:insert(progressIndicatorI)
    
    if recordingIndicator ~= nil then
        sceneGroup:insert(recordingIndicator)
    end

    if speechTimerText ~= nil then
        sceneGroup:insert(timerTextBackground)
        sceneGroup:insert(speechTimerText)
    end
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        -- Keep track of how many times a speech was presented/delivered for the rating prompt
        _saves.numberOfSpeechesPresented = _saves.numberOfSpeechesPresented + 1

        ytgAnalyticsI.track(ytgAnalytics.SPEECH_PRESENTED)
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then

    elseif ( phase == "did" ) then
        if _saves.recordSpeeches == true and cardsToDisplay == true and recording ~= nil then
            -- Stop recording
            recording:stopRecording()       
        end

        _loadsave.saveData(_saves)
    end
end

function scene:destroy( event )
    local sceneGroup = self.view

    memoryManagement.cancelTimer(ticker)

    Runtime:removeEventListener("key", keyListenerI.onKeyEvent)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene