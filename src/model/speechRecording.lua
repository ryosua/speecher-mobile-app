local speechRecording = {}

function speechRecording.new(text)
    local this = {}

    this.id = _saves.speechRecordingIdCounter
    this.title = text
    this.filename = "speechRecording" .. this.id

    return this
end

return speechRecording