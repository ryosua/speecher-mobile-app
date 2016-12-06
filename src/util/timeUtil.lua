local timeUtil = {}

function timeUtil.secondsToDigitalTime(seconds)
    local display = ""

    local remaingSeconds = 0 -- The number of seconds left after converting seconds to minutes.
 
    -- Convert minutes to seconds.
    if seconds >= 60 then
        local minutes = math.floor(seconds / 60)

        if minutes >= 10 then
            display = display .. math.floor(minutes / 10)
            display = display .. (minutes % 10)
            display = display .. ":"
        else 
            display = display .. 0
            display = display .. minutes
            display = display .. ":"
        end

        remaingSeconds = seconds % 60

    else
        display = display .. "00:"
        remaingSeconds = seconds
    end

    -- Display the remaining seconds.
    if remaingSeconds >= 10 then
        display = display .. math.floor(remaingSeconds / 10)
        display = display .. remaingSeconds % 10
    else
        display = display .. "0"
        display = display .. remaingSeconds
    end

    return display
end

return timeUtil