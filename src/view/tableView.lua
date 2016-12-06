local tableView = {}

-- Modules
local backButton = require "src.view.backButton"
local composer = require "composer"
local platform = require "src.model.platform"
local rowIndicator = require "src.view.rowIndicator"
local textShortener = require "src.controller.textShortener"
local widget = require "widget"
local ytgAnalytics = require "src.controller.ytgAnalytics"

function tableView.new(onRowTouch, dragAndDropControllerI, deleteBarI, crudController, present, viewRecordings, crudGUIController, singletonsI, backButtonI)
    local this

    local scrollTop = _H * .20

    -- For simplicity only the first audio channel is being used.
    -- Use this variable to track which is in use.
    local audioIndex = -1

    -- The rows seem to be re-rendered every time they are tapped, so the alpha needs to be loaded
    -- from a variable instead of just setting the alpha.
    local playButtonAlpha = 1
    local stopButtonAlpha = .5

    local function onRowRender( event )
        local row = event.row
        local index = row.index
        local params = event.row.params
        local font = nil -- system default
        local textSize = 37
        local buttonSize = 75
        local spacing = .15 * _W
        local rowCenterY = row.contentHeight * 0.5

        local function onPresent(e)
            if e.phase == "began" then
                present(params.model)
            end

            return true
        end

        local function onViewRecordings(e)
            if e.phase == "began" then
                viewRecordings(params.model)
            end

            return true
        end

        local function playAudio(e)
            if e.phase == "began" then
                if crudController.audioControllerI.streamLoaded() == false then
                    crudController.audioControllerI.loadStream(params.model.filename .. platform.audioFormat)
                end

                if index ~= audioIndex then
                    crudController.audioControllerI.stopAudio()
                    crudController.audioControllerI.disposeAudio()
                    crudController.audioControllerI.loadStream(params.model.filename .. platform.audioFormat)
                end

                audioIndex = index

                crudController.audioControllerI.startSteam()

                playButtonAlpha = .5
                stopButtonAlpha = 1

                local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()
                ytgAnalyticsI.track(ytgAnalytics.RECORDING_PLAYED)
            end

            return true
        end

        local function stopRecording(e)
            if e.phase == "began" and index == audioIndex then
                crudController.audioControllerI.stopAudio()
                crudController.audioControllerI.rewindAudio()

                playButtonAlpha = 1
                stopButtonAlpha = .5
            end

            return true
        end

        local function onRowDrag(e)
            if e.phase == "began" then
                this:setIsLocked(true)
                dragAndDropControllerI.dragStartPosition = index
                crudController.itemToDelete = params.model
                deleteBarI.alpha = 1

                -- Create a dragable row as an indicator of what the user is dragging.
                row.indicator = rowIndicator.new(_W * .5, rowCenterY, _W * .925, row.contentHeight * .9)
                row.indicator.alpha = .5
                row.indicator.anchorX = .5

                dragAndDropControllerI.dragStarted(row, this)
            end

            if e.phase == "ended" then
                this:setIsLocked(false)

                -- If the touch ends on a different row than it started on, the user has dragged that row,
                -- so refresh the display.
                if dragAndDropControllerI.dragStartPosition ~= index then
                    this.refreshRows()
                end
                deleteBarI.alpha = 0 

                dragAndDropControllerI.dragStopped()
            end

            return true
        end

        row.background = rowIndicator.new(_W * .5, rowCenterY, _W * .925, row.contentHeight * .9)
        row.background.anchorX = .5
        row:insert(row.background)

        if crudController.modelType == "speech" or crudController.modelType == "speechRecording" then
            row.presentButton = display.newImage("images/arrow.png")
            row.presentButton.x = (_W - row.background.contentWidth)/ 2 + row.background.contentWidth * .03
            row.presentButton.y = rowCenterY
            row.presentButton.xScale = .15
            row.presentButton.yScale = row.presentButton.xScale
            row.presentButton.anchorX = 0
            row.presentButton.alpha = 1
            row:insert(row.presentButton)

            if crudController.modelType == "speech" then
                row.presentButton:addEventListener("touch", onPresent)
            end

            if crudController.modelType == "speechRecording" then
                row.presentButton:addEventListener("touch", playAudio)

                if index == audioIndex then
                    row.presentButton.alpha = playButtonAlpha
                end

                local sideLength = 75
                row.pauseButton = display.newRect(row.presentButton.x + row.presentButton.contentWidth * 1.25, rowCenterY, sideLength, sideLength)
                row.pauseButton.anchorX = 0
                row.pauseButton.alpha = .5
                if index == audioIndex then
                    row.pauseButton.alpha = stopButtonAlpha
                end
                row.pauseButton:setFillColor(1, 0, 0)
                row:insert(row.pauseButton)
                row.pauseButton:addEventListener("touch", stopRecording)
            end
        end

        if crudController.modelType == "speech" and #params.model.speechRecordings > 0 then
            row.recordingsButton = display.newImage("images/record.png")
            row.recordingsButton.x = row.presentButton.x + row.presentButton.contentWidth
            row.recordingsButton.xScale = row.presentButton.xScale
            row.recordingsButton.yScale = row.presentButton.xScale
            row.recordingsButton.y = rowCenterY
            row.recordingsButton.anchorX = 0
            row.recordingsButton:addEventListener("touch", onViewRecordings)
            row:insert(row.recordingsButton)
        end

        row.text = display.newText(params.text, 0, 0, font, textSize)
        row.text.anchorX = 0
        row.text:setFillColor(0, 0, 0)
        
        if row.recordingsButton ~= nil then
            row.text.x = row.recordingsButton.x + row.recordingsButton.contentWidth + row.recordingsButton.contentWidth * .15
        elseif row.pauseButton ~= nil then
            row.text.x = row.pauseButton.x + row.pauseButton.contentWidth + row.pauseButton.contentWidth * .15
        elseif row.presentButton ~= nil then
            row.text.x = row.presentButton.x + row.presentButton.contentWidth + row.presentButton.contentWidth * .15
        else
            row.text.x = _W * .125
        end

        local shortenWidth = row.contentWidth * .6

        if row.recordingsButton ~= nil then
            shortenWidth = shortenWidth - row.recordingsButton.contentWidth
        elseif row.pauseButton ~= nil then
            shortenWidth = shortenWidth - row.pauseButton.contentWidth - row.presentButton.contentWidth
        end

        if textShortener.shortenByWidth(row.text, shortenWidth) == true then
            row.text.text = row.text.text .. "..."
        end
        
        row.text.y = rowCenterY
        row:insert(row.text)

        row.dragHandle = display.newImage("images/drag.png")
        local dragHandleScale = .15
        row.dragHandle.xScale = dragHandleScale
        row.dragHandle.yScale = dragHandleScale
        row.dragHandle.x = _W - (_W - row.background.contentWidth)/ 2 - row.background.contentWidth * .03
        row.dragHandle.y = rowCenterY
        row.dragHandle.anchorX = 1
        row.dragHandle.alpha = .1
        row.dragHandle:addEventListener("touch", onRowDrag)
        row:insert(row.dragHandle)
    end

    --[[
        A table listener that hides the back button when the list is scrolled all the way down.
        This will only happen when the backbutton is passed in new(), so only on speechRecordingView.
    ]]--
    local function tableListener(e)
        if e.limitReached then
            if e.direction == "up"then
                if backButtonI ~= nil then
                    backButtonI.alpha = 0
                end
            end
        else
            if backButtonI ~= nil then
                backButtonI.alpha = backButton.ALPHA
            end
        end
    end

    this = widget.newTableView({
        top = _H * .25, 
        left = 0,
        width = _W, 
        height = _H - _H * .25, 
        hideBackground = false,
        backgroundColor = {224/255, 177/255, 58/255},
        noLines = true,
        onRowRender = onRowRender,
        onRowTouch = onRowTouch,
        friction = .925,
        maxVelocity = 5,
        listener = tableListener,
    })

    this.onEditingComplete = nil

    --[[
        This is function is not set through the new funciton because it needs a the function in the GUI
        controller needs the table passed as a parameter.
    ]]--
    function this.setRefreshRows(refreshRows)
        this.refreshRows = refreshRows
    end

    function this.setOnEditingComplete(onEditingComplete)
        this.onEditingComplete = onEditingComplete
    end

    return this
end

return tableView