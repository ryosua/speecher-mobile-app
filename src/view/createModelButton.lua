local createModelButton = {}

createModelButton.CREATE_MODE = 1
createModelButton.EDIT_MODE = 2

function createModelButton.new(x, y)

    local this = display.newGroup()
    this.anchorX = 0
    this.anchorY = .3

    local plusButtonOptions =
    {
        text = "+",     
        x = x,
        y = y,
        font = native.systemFontBold,   
        fontSize = 100,
        align = "right"
    }

    local plusButton = display.newText(plusButtonOptions)
    
    local editButton = display.newImage("images/wrench.png")
    editButton.xScale = .33
    editButton.yScale = editButton.xScale
    editButton.x = plusButtonOptions.x
    editButton.y = plusButtonOptions.y

    function this.setButtonToPlus()
        plusButton.alpha = 1
        editButton.alpha = 0
        this.mode = createModelButton.CREATE_MODE
    end

    function this.setButtonToEdit()
        plusButton.alpha = 0
        editButton.alpha = 1
        this.mode = createModelButton.EDIT_MODE
    end

    this:insert(plusButton)
    this:insert(editButton)

    -- The button starts in create model mode.
    this.setButtonToPlus()
    this.mode = createModelButton.CREATE_MODE

    return this
end

return createModelButton