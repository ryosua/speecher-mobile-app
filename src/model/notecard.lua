local notecard = {}

function notecard.new(text)
    local this = {}

    this.notes = {}
    this.id = _saves.notecardIdCounter
    this.title = text

    return this
end

return notecard