local notecardController = {}

-- Modules
local composer = require "composer"
local crudController = require "src.controller.crudController"
local notecard = require "src.model.notecard"

function notecardController.new(logger, speech)
    local l = logger

    local this = crudController.new(l, "notecard", "title")

    this.itemToDelete = nil
    this.speechI = speech

    -- Override
    function this.getModels()
        return this.speechI.cards
    end

    -- Override
    function this.newModel(modelText)
        return notecard.new(modelText)
    end

    -- Override
    function this.onCardTap(modelId)
        local index = this.getModelIndex(modelId)
        local notecard = this.getModels()[index]

        local options =
        {
            time = 0,
            params =
            {
                notecard = notecard,
            }
        }
        composer.gotoScene("src.view.scenes.noteView", options)
    end

    -- Override
    function this.setParent(speech)
        this.speechI = speech
    end

    return this
end

return notecardController