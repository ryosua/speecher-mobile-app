local speechRecordingController = {}

-- Modules
local composer = require "composer"
local crudController = require "src.controller.crudController"
local platform = require "src.model.platform"
local speechRecording = require "src.model.speechRecording"

function speechRecordingController.new(logger, speech, audioControllerI)
    local l = logger

    local this = crudController.new(l, "speechRecording", "title")

    this.speechI = speech
    this.audioControllerI = audioControllerI

    -- Override
    function this.getModels()
        return this.speechI.speechRecordings
    end

    -- Override
    function this.newModel(modelText)
        return speechRecording.new(modelText)
    end

    -- Override
    function this.onCardTap(modelId)
       -- Playback speech
    end

    -- Override
    function this.setParent(speech)
        this.speechI = speech
    end

    local parentDeleteModel = this.deleteModel

    -- Override
    function this.deleteModel(modelId)
        -- Delete the file associated with the model.
        local modelIndex = this.getModelIndex(modelId)
        local model = this.getModels()[modelIndex]
        this.audioControllerI.deleteFile(model.filename .. platform.audioFormat)

        -- Delete the model using parent method.
        parentDeleteModel(modelId)
    end

    return this
end

return speechRecordingController