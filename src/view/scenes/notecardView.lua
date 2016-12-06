-- Modules
local appBackground = require "src.view.appBackground"
local appForeground = require "src.view.appForeground"
local backButton = require "src.view.backButton"
local composer = require "composer"
local createModelButton = require "src.view.createModelButton"
local dragAndDropController = require "src.controller.dragAndDropController"
local editField = require "src.view.editField"
local deleteBar = require "src.view.deleteBar"
local memoryManagement = require "src.controller.memoryManagement"
local pressToHoldTip = require "src.view.pressToHoldTip"
local topBar = require "src.view.topBar"
local undoDeleteButton = require "src.view.undoDeleteButton"

local scene = composer.newScene()

local singletonsI = composer.state.singletonsI
local strings = singletonsI.getStrings()

-- Controllers
local crudControllerI

-- Display
local background
local foreground
local createModelButtonI
local deleteBarI 
local tableViewI
local pressToHoldTipI

-- Native
local editFieldI

-- Misc
local onCreateModelButtonTap
local deleteItem
local onForegroundTouch
local timers = {}
local transitions = {}

function scene.getTextField()
    return editFieldI
end

function scene:create( event )
    local sceneGroup = self.view
    composer.state.returnTo = "src.view.scenes.speechView"

    local speech
    if event.params ~= nil then
        speech = event.params.speech
    else
        speech = composer.state.lastModel
    end

    -- Set up the controllers.
    crudControllerI = singletonsI.getNotecardControllerI(speech)
    crudGUIController = singletonsI.getCrudGUIController()
    local dragAndDropControllerI = dragAndDropController.new(crudControllerI, crudGUIController)

    deleteBarI = deleteBar.new()

    local topBarI = topBar.new()
    topBarI.setText(speech.title .. " > Notecards")

    editFieldI = editField.new(_W * .55, topBarI.contentHeight + _H * .075, _W * .8, _H * .05)

    createModelButtonI = createModelButton.new(editFieldI.x - editFieldI.contentWidth * .59, editFieldI.y)
    createModelButtonI.anchorX = .5
    createModelButtonI.anchorY = .5

    -- Display models
    tableViewI = crudGUIController.createTableViewWithModels(crudControllerI, deleteBarI, editFieldI, strings, dragAndDropControllerI, createModelButtonI, singletonsI)
    dragAndDropControllerI.setTableView(tableViewI)
    
    function onCreateModelButtonTap(e)
        if createModelButtonI.mode == createModelButton.CREATE_MODE then
            local notecardsCreated = _saves.notecardIdCounter

            if notecardsCreated <= 2 then
                pressToHoldTipI.animate()
            end

            return crudGUIController.doOnCreate(crudControllerI, editFieldI, strings.newNotecardDefaultText, strings, tableViewI, singletonsI, e)
        elseif createModelButtonI.mode == createModelButton.EDIT_MODE then
            tableViewI.onEditingComplete()
            return true
        end
    end

    editFieldI.setOnCreate(onCreateModelButtonTap)
    editFieldI.placeholder = strings.newNotecardDefaultText

    background = appBackground.new()

    function onForegroundTouch(e)
        return crudGUIController.doOnForegroundTouch(crudControllerI, deleteBarI, dragAndDropControllerI, editFieldI, tableViewI, createModelButtonI, e)
    end

    foreground = appForeground.new()
    foreground:addEventListener("touch", onForegroundTouch)

    local undoDeleteButtonI = undoDeleteButton.new()

    local function onUndoDelete(e)
        return crudGUIController.doOnUndoDelete(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, transitions, undoDeleteButtonI, e)
    end

    undoDeleteButtonI:addEventListener("touch", onUndoDelete) 

    function deleteItem(e)
        return crudGUIController.doOnDeleteItem(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, transitions, undoDeleteButtonI, e)
    end

    deleteBarI:addEventListener("touch", deleteItem)

    createModelButtonI:addEventListener("touch", onCreateModelButtonTap)

    local backButton = backButton.new()

    pressToHoldTipI = pressToHoldTip.new("Press and hold to add a note to the notecard.")

    sceneGroup:insert(background)
    sceneGroup:insert(topBarI)
    --sceneGroup:insert(editFieldI) not inserted becuase it is native
    sceneGroup:insert(tableViewI)
    sceneGroup:insert(deleteBarI)
    sceneGroup:insert(foreground)
    sceneGroup:insert(backButton)
    sceneGroup:insert(createModelButtonI)
    sceneGroup:insert(undoDeleteButtonI)
    sceneGroup:insert(pressToHoldTipI)
end

function scene:destroy( event )

    local sceneGroup = self.view

    editFieldI:removeSelf()
    createModelButtonI:removeEventListener("tap", onCreateModelButtonTap)
    foreground:removeEventListener("touch", onForegroundTouch)
    deleteBarI:removeEventListener("touch", deleteItem)

    memoryManagement.cancelAllTimers(timers)
    memoryManagement.cancelAllTransitionsUsingPairs(transitions)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene