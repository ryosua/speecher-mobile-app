local noteController = {}

-- Modules
local composer = require "composer"
local crudController = require "src.controller.crudController"
local note = require "src.model.note"

function noteController.new(logger, notecard)
    local l = logger

    local this = crudController.new(l, "note", "text")

    this.itemToDelete = nil
    this.notecardI = notecard

    -- Override
    function this.getModels()
        return this.notecardI.notes
    end

    -- Override
    function this.newModel(modelText)
        return note.new(modelText)
    end

    -- Override
    function this.onCardTap(modelId)
       -- Do nothing. This overrides the parent method that throws an error with assert.
    end

    -- Override
    function this.setParent(notecard)
        this.notecardI = notecard
    end

    return this
end

return noteController