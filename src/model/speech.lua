local speech = {}

function speech.new(text)
    local this = {}

    this.cards = {}
    this.speechRecordings = {}
    this.id = _saves.speechIdCounter
    this.title = text

    return this
end

return speech