local note = {}

function note.new(text)
    local this = {}

    this.id = _saves.noteIdCounter
    this.text = text

    return this
end

return note