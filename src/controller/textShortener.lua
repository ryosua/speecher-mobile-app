local textShortener = {}

function textShortener.shortenByWidth(textObject, maxSize)
    if textObject.contentWidth > maxSize then
        textObject.text = string.sub(textObject.text, 1, string.len(textObject.text) - 1)
        textShortener.shortenByWidth(textObject, maxSize)
        return true
    end
    return false
end

function textShortener.shortenByHeight(textObject, maxSize)
    if textObject.contentHeight > maxSize then
        textObject.text = string.sub(textObject.text, 1, string.len(textObject.text) - 1)
        textShortener.shortenByHeight(textObject, maxSize)
        return true
    end
    return false
end

return textShortener