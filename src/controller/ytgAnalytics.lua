local ytgAnalytics = {}

-- Modules
local analytics = require "analytics"

ytgAnalytics.APP_INSTALLED = "App Installed"
ytgAnalytics.SPLASH_SCREEN_STARTED = "Splash Screen Started"
ytgAnalytics.OPTIONS_SCREEN_STARTED = "Options Screen Started"
ytgAnalytics.SPEECH_PRESENTED = "Speech Presented"
ytgAnalytics.SPEECH_CREATED = "Speech Created"
ytgAnalytics.NOTECARD_CREATED = "Notecard Created"
ytgAnalytics.NOTE_CREATED = "Note Created"
ytgAnalytics.RECORDING_PLAYED = "Recording Played"


function ytgAnalytics.new(key)
    local this = {}

    analytics.init(key)

    --[[
        Tracks events, but only if the enviroment is not the simulator.
    ]]--
    function this.track(event, params)
        if system.getInfo('environment') ~= 'simulator' then
            analytics.logEvent(event, params)
        end
    end

    return this
end

return ytgAnalytics