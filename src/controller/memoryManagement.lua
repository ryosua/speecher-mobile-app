--[[
    Contains functions to cancel timers and transitions, which needs to be done manually, and other related functions.

    To save data call:
    _loadsave.saveData(_saves)
]]--

-- Modules
local composer = require "composer"
local ratingPromptController = require "src.controller.ratingPromptController"

local memoryManagement = {}

--[[
    Sets the initial values for all game saves, or can be used to reset all game data for a fresh start.
]]--
function memoryManagement.eraseAllData()
    -- Initialize global saves variable.
    _saves = {}
    
    -- Variables
    _saves.noteFontSizeSliderValue = 50
    _saves.noteIdCounter = 1
    _saves.notecardIdCounter = 1
    _saves.speechIdCounter = 1
    _saves.speechRecordingIdCounter = 1
    _saves.speeches = {}
    _saves.ratingSetting = ratingPromptController.choices.yes
    _saves.numberOfSpeechesPresented = 0
    _saves.noteFontSize = 50
    _saves.paid = true
    _saves.recordSpeeches = true

    -- Save the table as a json file.
    _loadsave.saveData(_saves)
end

function memoryManagement.cancelTimer(timerToCancel)
    if timerToCancel ~= nil then
        timer.cancel( timerToCancel )
        timerToCancel = nil
    end
end

--[[
    Cancels all timers in given table.
]]--
function memoryManagement.cancelAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.cancelTimer(timers[i])
        timers[i] = nil
    end
end

function memoryManagement.cancelTransition(transitionToCancel)
    if transitionToCancel ~= nil then
        transition.cancel( transitionToCancel )
        transitionToCancel = nil
    end
end

--[[
    Cancels all transitions in given table. That is indexed numerically. DO NOT pass in a table with holes.
]]--
function memoryManagement.cancelAllTransitions(transitions)
    for i = 1, #transitions do
        memoryManagement.cancelTransition(transitions[i])
        transitions[i] = nil
    end
end

--[[
    Cancels all transitions in given table using pairs. Slower than the above function, but can handle named transitions
    and holes.
]]--
function memoryManagement.cancelAllTransitionsUsingPairs(transitions)
    for k,v in pairs(transitions) do
        transition.cancel( v )
        v = nil; k = nil
    end
end

function memoryManagement.pauseTimer(timerToPause)
    if timerToPause ~= nil then
        timer.pause( timerToPause )
    end
end

--[[
    Pauses all timers in given table.
]]--
function memoryManagement.pauseAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.pauseTimer(timers[i])
    end
end

--[[
    Pauses all transitions in given table.
]]--
function memoryManagement.pauseAllTransitions(transitions)
    for i = 1, #transitions do
        transition.pause( transitions[i] )
    end
end

function memoryManagement.resumeTimer(timerToResume)
    if timerToResume ~= nil then
        timer.resume( timerToResume )
    end
end

--[[
    Resumes all timers in given table.
]]--
function memoryManagement.resumeAllTimers(timers)
    for i = 1, #timers do
        memoryManagement.resumeTimer(timers[i])
    end
end

--[[
    Resumes all transitions in given table.
]]--
function memoryManagement.resumeAllTransitions(transitions)
    for i = 1, #transitions do
        transition.resume( transitions[i] )
    end
end

function memoryManagement.printMemUsage()          
    local memUsed = gcinfo()/ 1000
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1000000
    local memUsedFormatted = string.format("%.03f", memUsed)
    local textUsedFormatted = string.format("%.03f", texUsed)
end

return memoryManagement