local speechController = {}

-- Modules
local composer = require "composer"
local crudController = require "src.controller.crudController"
local listItem = require "src.view.listItem"
local speech = require "src.model.speech"

function speechController.new(logger, scene)
    local l = logger

    local this = crudController.new(l, "speech", "title", scene)

    this.itemToDelete = nil

    -- Override
    function this.getModels()
        return _saves.speeches
    end

    -- Override
    function this.newModel(modelText)
        return speech.new(modelText)
    end

    -- Unused, there is another function that is used here, but that should be changed to this
    function this.deliverSpeech(speechId)
        l.log("This function will change scenes to deliverSpeech.lua and pass the speech object with the given ID for display")
    end

    -- Override
    function this.onCardTap(modelId)
        local index = this.getModelIndex(modelId)
        local speech = this.getModels()[index]

        -- Save the speech for when the user goes back
        composer.state.lastModel = speech

        local options =
        {
            time = 0,
            params =
            {
                speech = speech,
            }
        }
        composer.gotoScene("src.view.scenes.notecardView", options)
    end

    -- Override
    function this.createModelItem(xPosition, startingY, ySpacing, i, models, onModelTap, onCardTap)
        local modelItem = listItem.new(xPosition, startingY + ySpacing * i, models[i], onModelTap, onCardTap, this.textAttributeName, true)
        return modelItem
    end

    return this
end

return speechController