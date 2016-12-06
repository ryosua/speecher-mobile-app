--[[
    A module allowing accsess to the one instance allowed of any singleton module. The module's themselves do not enforce
    that only one instance can be instantiated, but rather through accessing the modules through this interface, only one
    instance of the selected class is needed. The instances are created the first time they are accessed, then live for 
    the life of the application session.
]]--

-- Modules
local logger = require "src.controller.logger"
local crudGUIController = require "src.controller.crudGUIController"
local ytgAnalytics = require "src.controller.ytgAnalytics"
local ANAYLITICS_KEY = require "flurry_key" -- Just put the key in a seperate file and place in the root folder
local noteController = require "src.controller.noteController"
local notecardController = require "src.controller.notecardController"
local speechController = require "src.controller.speechController"
local speechRecordingController = require "src.controller.speechRecordingController"
local strings = require "src.model.strings"
local ytgAnalytics = require "src.controller.ytgAnalytics"

local singletons = {}

function singletons.new()
    local this = {}

    local loggerI
    local noteControllerI
    local notecardControllerI
    local speechControllerI
    local speechRecordingControllerI
    local stringsI
    local ytgAnalyticsI

    local analyticsInitialized = false

    function this.getLoggerI()
        if loggerI == nil then
            loggerI = logger.new()
        end
        return loggerI
    end

    function this.getCrudGUIController()
        return crudGUIController
    end

    function this.getYtgAnalyticsI()
        if ytgAnalyticsI == nil then
            ytgAnalyticsI = ytgAnalytics.new(ANAYLITICS_KEY)
        end
        return ytgAnalyticsI
    end

    function this.getNoteControllerI(notecard)
        if noteControllerI == nil then
            noteControllerI = noteController.new(this.getLoggerI(), notecard)
        else
            noteControllerI.setParent(notecard)
        end
        return noteControllerI
    end

    function this.getNotecardControllerI(speech)
        if notecardControllerI == nil then
            notecardControllerI = notecardController.new(this.getLoggerI(), speech)
        else
            notecardControllerI.setParent(speech)
        end
        return notecardControllerI
    end

    function this.getSpeechRecordingControllerI(speech, audioControllerI)
        if speechRecordingControllerI == nil then
            speechRecordingControllerI = speechRecordingController.new(this.getLoggerI(), speech, audioControllerI)
        else
            speechRecordingControllerI.setParent(speech)
        end
        return speechRecordingControllerI
    end

    function this.getSpeechControllerI()
        if speechControllerI == nil then
            speechControllerI = speechController.new(this.getLoggerI())
        end
        return speechControllerI
    end

    function this.getStrings()
        return strings
    end

    return this
end

return singletons