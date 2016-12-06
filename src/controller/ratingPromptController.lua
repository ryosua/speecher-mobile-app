--[[
    A module for the rating prompt system.
]]--

local ratingPromptController = {}

ratingPromptController.choices = {
    yes = "Yes!",
    no = "Not really"
}

function ratingPromptController.new(timers)
    local this = {}

    this.timers = timers

    -- The navtive elements are on a seperate thread for Android, so a small delay is needed. 
    local DELAY = 100

    local ratingTitle = "Enjoying Speecher?"
    local NUMBER_OF_SPEECHES_PRESENTED_TO_TRIGGER = 10 -- Number of speeches presented required for the rating prompt to be shown.

    --[[ 
        This is the table that is actually getting passed to the alert object. 
        It needs to be indexed by numbers (array stlye, not dictinary syle) because these determine the order
    ]]--
    local choiceArray = {}
        choiceArray[1] = ratingPromptController.choices.yes
        choiceArray[2] = ratingPromptController.choices.no

    local function openNewEmail()
        local options =
        {
            to = "person@domain.com", -- removed company email that is no longer active
            subject = "Speecher Feedback",
            body = "",
        }

        native.showPopup("mail", options)
    end

    local function openAppInStore()
        local iOSStoreLink = "" -- inactive link removed
        local androidStoreLink = "" -- inactive link removed

        if ( string.sub( system.getInfo("model"), 1, 4 ) == "iPad" ) or string.sub(system.getInfo("model"),1,2) == "iP" then --If apple product
            system.openURL(iOSStoreLink)
        else
            system.openURL(androidStoreLink) -- If Android
        end
    end

    local function getRatingSetting()
        return _saves.ratingSetting
    end

    local function getNumberOfSpeechesPresented()
        return _saves.numberOfSpeechesPresented
    end

    local function onRatingSelection(e)
        if e.action == "clicked" then
            local i = e.index

            if (i == 1) then
                local prompt = "Would you mind rating Speecher?"
                local choices = {"Ok, sure", "No, thanks"}
                local onFeedbackSelection = function(e)
                    if e.action == "clicked" then
                        local i = e.index
                        if (i == 1) then
                            openAppInStore()
                        end
                    end
                end

                timers[table.getn(timers) + 1] = timer.performWithDelay( DELAY, 
                    function()
                        native.showAlert("", prompt, choices, onFeedbackSelection)
                    end
                )
            end

            if (i == 2) then
                local prompt = "Would you mind giving us some feedback?"
                local choices = {"Ok, sure", "No, thanks"}
                local onFeedbackSelection = function(e)
                    if e.action == "clicked" then
                        local i = e.index
                        if (i == 1) then
                            openNewEmail()
                        end
                    end
                end

                timers[table.getn(timers) + 1] = timer.performWithDelay( DELAY, 
                    function()
                        native.showAlert("", prompt, choices, onFeedbackSelection)
                    end
                )
            end

            _saves.ratingSetting = ratingPromptController.choices.no -- Don't ask again

            _loadsave.saveData(_saves)
        end
    end

    --[[
        Determines whether or not the rating prompt button should be shown.
    ]]--
    local function shouldPromptForRating()
        local shouldPrompt = false

        local showDialog = (getNumberOfSpeechesPresented() >= NUMBER_OF_SPEECHES_PRESENTED_TO_TRIGGER)
        if (getRatingSetting() == ratingPromptController.choices.yes) and (showDialog == true)  then
            shouldPrompt = true
        end

        return shouldPrompt
    end

    --[[
        Opens the initial rating prompt menu, if the user has met the criteria for being shown the rating prompt.
    ]]--
    function this.promptForRating()
        if shouldPromptForRating() == true then
            timers[table.getn(timers) + 1] = timer.performWithDelay( DELAY, 
                function()
                    native.showAlert("", ratingTitle, choiceArray, onRatingSelection)
                end
            )
        end
    end

    return this
end

return ratingPromptController