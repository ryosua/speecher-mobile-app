--[[
    This is a stateless module to manipulate display objects for the crud scenes. All state should be controlled in
    crudController.lua, and all instances to display objects should be in the scenes themselves and passed to 
    funcitons of this controller.
]]--

local crudGUIController = {}

-- Modules
local composer = require "composer"
local editField = require "src.view.editField"
local memoryManagement = require "src.controller.memoryManagement"
local strings = require "src.model.strings"
local tableView = require "src.view.tableView"
local ytgAnalytics = require "src.controller.ytgAnalytics"

function crudGUIController.setTextFieldToCreateNewItems(crudControllerI, editFieldI, createModelButtonI)
    editFieldI.text = ""
    editFieldI.placeholder = "new " .. crudControllerI.modelType

    editFieldI.mode = editField.CREATE_MODE
    native.setKeyboardFocus(nil)

    createModelButtonI.setButtonToPlus()
end

--[[
    For speech recordings the user may not create recordings from the CRUD GUI. They are
    created automatatically in deliver, so use this instead of setTextFieldToCreateNewItems().
]]--
function crudGUIController.clearAfterEditingForRecordings(editFieldI)
    editFieldI.text = ""
    editFieldI.placeholder = strings.speechRecordingDefaultText
    native.setKeyboardFocus(nil)
end

local function edit(crudControllerI, model)
    crudControllerI.onCardTap(model.id)
    return true
end

local function present(model)
    local options =
    {
        time = 0,
        params =
        {
            speech = model
        }
    }
    composer.gotoScene("src.view.scenes.deliver", options)

    return true
end

local function viewRecordings(model)
    local options =
    {
        time = 0,
        params =
        {
            speech = model
        }
    }
    composer.gotoScene("src.view.scenes.speechRecordingView", options)

    return true
end

local function fillTable(crudControllerI, deleteBarI, editFieldI, strings, tableViewI)
    local models = crudControllerI.getModels()

    -- Positions
    local ySpacing = 150
    local startingY = 0
    local xPosition = _W * .1

    for i = 1, #models do
        tableViewI:insertRow {
            rowHeight = 150,
            isCategory = false,
            rowColor = { default={224/255, 177/255, 58/255}, over={ 1, 1, 1 } } ,
            lineColor = { 1, 1, 1 },
            params = {
                text = models[i][crudControllerI.textAttributeName],
                model = models[i],
            }
        }
    end
end

function crudGUIController.refreshRows(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, createModelButtonI)
    tableViewI:deleteAllRows()
    fillTable(crudControllerI, deleteBarI, editFieldI, strings, tableViewI)

    if crudControllerI.modelType ~= "speechRecording" then
        crudGUIController.setTextFieldToCreateNewItems(crudControllerI, editFieldI, createModelButtonI)
    else
        crudGUIController.clearAfterEditingForRecordings(editFieldI)
    end
    
    -- Don't use the below method because reloading the data just means updating something like the color
    -- we want to delete and render all the rows, which calls for a custom funciton.
    -- tableViewI:reloadData()
end

--[[
    Creates a new scroll view and populates it with an item for each model in the list.
]]--
function crudGUIController.createTableViewWithModels(crudControllerI, deleteBarI, editFieldI, strings, dragAndDropControllerI, createModelButtonI, singletonsI, backButton)
    local tableViewI

    --[[
        When a model is tapped, they can edit the title or text of the model.
    ]]--
    local function onRowTouch(e)

        if e.phase == "press" then
        	local model = e.target.params.model
            edit(crudControllerI, model)
        end

        if e.phase == "tap" then
        	local model = e.target.params.model
            local index = e.target.index
            local modelId = model.id

            --[[
                This function gets called after edit is complete.
            ]]--
            local function onEditingComplete()
                -- Change the text that is part of the model object.
                crudControllerI.editModelText(modelId, editFieldI.text)

                -- Change the text in the table model.
                tableViewI:getRowAtIndex(index).params.text = model[crudControllerI.textAttributeName]
                tableViewI:reloadData()

                if crudControllerI.modelType ~= "speechRecording" then
                    crudGUIController.setTextFieldToCreateNewItems(crudControllerI, editFieldI, createModelButtonI)
                else
                    crudGUIController.clearAfterEditingForRecordings(editFieldI)
                end
            end

            -- For some reason the y coordinate is off about 290 px
            local offset = 290
            local x = 0
            local y = _H * .3

            -- Change the behavior of the text field to edit the speech.
            editFieldI.mode = editField.EDIT_MODE

            createModelButtonI.setButtonToEdit()
            tableViewI.setOnEditingComplete(onEditingComplete)
            editFieldI.setOnEdit(onEditingComplete)

            -- Set the defualt text for the text field to that of the model.
            editFieldI.text = model[crudControllerI.textAttributeName]

            native.setKeyboardFocus( editFieldI )
        end

        return true
    end

    tableViewI = tableView.new(onRowTouch, dragAndDropControllerI, deleteBarI, crudControllerI, present, viewRecordings, crudGUIController, singletonsI, backButton)

    local function refreshRows()
        crudGUIController.refreshRows(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, createModelButtonI)
    end

    tableViewI.setRefreshRows(refreshRows)

    fillTable(crudControllerI, deleteBarI, editFieldI, strings, tableViewI)
    
    return tableViewI
end

--[[
    The function to call in the listener for the create model button.
]]--
function crudGUIController.doOnCreate(crudControllerI, editFieldI, placeholder, strings, tableViewI, singletonsI, e)
    if e == nil or e.phase == "began" then -- This function from a touch event or not.
        if editFieldI.text ~= nil and editFieldI.text ~= "" then
            local model = crudControllerI.createModel(editFieldI.text)

            tableViewI:insertRow {
                rowHeight = 150,
                isCategory = false,
                rowColor = { default={224/255, 177/255, 58/255}, over={ 1, 1, 1 } } ,
                lineColor = { 1, 1, 1 },
                params = {
                    text = model[crudControllerI.textAttributeName],
                    model = model,
                }
            }

            editFieldI.text = ""
            native.setKeyboardFocus( nil )

            editFieldI.placeholder = placeholder

            local ytgAnalyticsI = composer.state.singletonsI.getYtgAnalyticsI()
            local modelType = crudControllerI.modelType

            if modelType == "speech" then
                ytgAnalyticsI.track(ytgAnalytics.SPEECH_CREATED)
            elseif modelType == "notecard" then
                ytgAnalyticsI.track(ytgAnalytics.NOTECARD_CREATED)
            elseif modelType == "note" then
                ytgAnalyticsI.track(ytgAnalytics.NOTE_CREATED)
            end
        end
    end

    return true
end

function crudGUIController.doOnForegroundTouch(crudControllerI, deleteBarI, dragAndDropControllerI, editFieldI, tableViewI, createModelButtonI, e)
    if e.phase == "ended" then
            deleteBarI.alpha = 0
            dragAndDropControllerI.dragStopped()
            tableViewI:setIsLocked(false)
            tableViewI.refreshRows()
        end

        if e.phase == "began" then
            if crudControllerI.modelType ~= "speechRecording" then
                crudGUIController.setTextFieldToCreateNewItems(crudControllerI, editFieldI, createModelButtonI)
            else
                crudGUIController.clearAfterEditingForRecordings(editFieldI)
            end
        end

        if e.phase == "moved" then
            dragAndDropControllerI.dragPosition.x = e.x
            dragAndDropControllerI.dragPosition.y = e.y
        end

    return false -- prograte the event
end

function crudGUIController.doOnDeleteItem(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, transitions, undoDeleteButtonI, e)
    if e.phase == "ended" then

        -- Cancel the undelete button transition in case multiple deletes happen in a row.
        memoryManagement.cancelTransition(transitions.hideUndoDeleteButton)
        
        -- Save information about the last item deleted in case the user wants to restore it.
        crudControllerI.lastItemDeleted = crudControllerI.itemToDelete
        crudControllerI.lastItemDeletedPosition = crudControllerI.getModelIndex(crudControllerI.lastItemDeleted.id)

        -- Delete the model
        crudControllerI.deleteModel(crudControllerI.itemToDelete.id)
        
        tableViewI.refreshRows()
        deleteBarI.alpha = 0
        tableViewI:setIsLocked(false)

        -- Give the user the oppurtunity to restore it for a few seconds
        undoDeleteButtonI.alpha = 1

        transitions.hideUndoDeleteButton = transition.to(undoDeleteButtonI, { time=1000, delay=2000, alpha=0})
    end

    return true
end

function crudGUIController.doOnUndoDelete(crudControllerI, deleteBarI, editFieldI, strings, tableViewI, transitions, undoDeleteButtonI, e)
    if e.phase == "ended" then
        undoDeleteButtonI.alpha = 0
        memoryManagement.cancelTransition(transitions.hideUndoDeleteButton)
        crudControllerI.undoDelete()
        tableViewI.refreshRows()
    end

    return true
end

function crudGUIController.transitionTableViewDown(row)
    if row ~= nil then
        transition.to(row, { time=100, delay=0, y = row.y + row.contentHeight})
    end
end

function crudGUIController.transitionTableViewUp(row)
    if row ~= nil then
        transition.to(row, { time=100, delay=0, y = row.y - row.contentHeight})
    end
end

return crudGUIController