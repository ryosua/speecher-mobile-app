local crudController = {}

--[[
    An abstract module for creating, reading, updating and deleting model objects.
    Several methods must be overridden in the extending module.

    Do not manipulate display objects in with this module. This module is only responsible for the data, not
    the views representing it.
]]--

-- Modules
local composer = require "composer"
local listItem = require "src.view.listItem"
local pressListener = require "src.controller.pressListener"

function crudController.new(logger, modelType, textAttributeName)
    local this = {}

    local l = logger

    this.modelType = modelType
    this.textAttributeName = textAttributeName
    this.itemToDelete = nil
    this.lastItemDeleted = nil
    this.lastItemDeletedPosition = -1

    --[[
        Gets the list of models saved in JSON.
    ]]--
    function this.getModels()
        assert(false, "You must override getModels() in " .. this.modelType  .. "controller.lua")
    end

    --[[
        Constructs a new model, but does not save it or add it to the list of models.
    ]]--
    function this.newModel(modelText)
        assert(false, "You must override newModel() in " .. this.modelType  .. "controller.lua")
    end

    --[[
        The action that is performed when a model is tapped by the user.
    ]]--
    function this.onCardTap(modelId)
        assert(false, "You must override onCardTap(modelId) in " .. this.modelType  .. "controller.lua")
    end

    --[[
        The parent model - for speech it would be the notecard that the speech belongs to.
    ]]--
    function this.setParent(model)
        assert(false, "You must override setParent(model) in " .. this.modelType  .. "controller.lua")
    end

    --[[
        Creates the diplay item that represents the model.
    ]]--
    function this.createModelItem(xPosition, startingY, ySpacing, i, models, onModelTap, onCardTap)
        local modelItem = listItem.new(xPosition, startingY + ySpacing * i, models[i], onModelTap, onCardTap, this.textAttributeName, nil)
        return modelItem
    end

    --[[
        Creates a new model, adds it to the list of models, and saves it.
    ]]--
    function this.createModel(modelText)
        local models = this.getModels()
        local newModel = this.newModel(modelText)
        models[#models + 1] = newModel
        local idKey = this.modelType .. "IdCounter"
        _saves[idKey] = _saves[idKey] + 1
        _loadsave.saveData(_saves)
        l.log(this.modelType .. " created with title: " .. newModel[textAttributeName])
        return newModel
    end

    --[[
        Returns the index of the model in _saves.[models] that has the ID,
        or -1 if not found.
    ]]--
    function this.getModelIndex(modelId)
        assert(modelId, "getModelIndex - modelId nill")

        local modles = this.getModels()
        local index = -1
        for i = 1, #modles do
            if modles[i].id == modelId then
                index = i
                return index
            end
        end
        return index
    end

    --[[
        Edits the text of a model.
    ]]--
    function this.editModelText(modelId, text)
        local models = this.getModels()
        local i = this.getModelIndex(modelId)
        if i ~= -1 then
            models[i][this.textAttributeName] = text
            _loadsave.saveData(_saves)
        else
            l.log("editModelText: model not found")
        end
    end

    --[[
        Deletes the model.
    ]]--
    function this.deleteModel(modelId)
        local models = this.getModels()
        local i = this.getModelIndex(modelId)
        if i ~= -1 then
            table.remove(models,i)
            _loadsave.saveData(_saves)
        else
            l.log("deleteModel: " .. this.modelType .. " not found")
        end
    end

    function this.undoDelete()
        local models = this.getModels()
        table.insert(models, this.lastItemDeletedPosition, this.lastItemDeleted)
        _loadsave.saveData(_saves)
    end

    --[[
        Called as a result of a drag and drop reorder. Moves an item from the starting position to
        target postion, and shift the items to fill the gap.
    ]]--
    function this.reorder(model, startingPosition, targetPosition)
        local models = this.getModels()
        table.remove(models ,startingPosition)
        table.insert(models, targetPosition, model)
        _loadsave.saveData(_saves)
    end

    --[[
        Swaps two models in the table.
        Returns true if both indexes were found, or false if not.
    ]]--
    function this.swap(modelID1, modelID2)
        local models = this.getModels()

        local index1 = this.getModelIndex(modelID1)
        local index2 = this.getModelIndex(modelID2)

        if (index1 ~= -1) and (index2 ~= -1) then
            local saved = models[index1]
            models[index1] = models[index2]
            models[index2] = saved

            _loadsave.saveData(_saves)

            return true
        else
            return false
        end
    end

    --[[
        Returns a string representing the model.
    ]]--
    function this.toString(model)
        return ("ID: " ..  model.id .. " " .. this.textAttributeName .." :  " .. tostring(model[this.textAttributeName]))
    end

    return this
end

return crudController