local editField = {}

editField.CREATE_MODE = 1
editField.EDIT_MODE = 2

function editField.new(x, y, width, height)
    local defaultX = 0
    local defaultY = 0

    local this = native.newTextField(x, y, width, height)
    this.mode = editField.CREATE_MODE

    --Changing the anchors causes a corona glitch where the text field moves from 0, 0 to the new position
    --this.anchorX = 0
    --this.anchorY = 0

    --[[
        Sets the function that is called when the editing is submitted.
    ]]--
    function this.setOnCreate(onCreate)
        this.onCreate = onCreate
    end

    --[[
        Sets the function that is called when the editing is submitted.
    ]]--
    function this.setOnEdit(onEdit)
        this.onEdit = onEdit
    end

    local function textListener(e)
        local textField

        if ( e.phase == "began" ) then
        
        end

        if e.phase == "submitted" then
            if (e.target.text ~= nil) and (e.target.text ~= "") then
                if this.mode == editField.CREATE_MODE then
                    this.onCreate()
                elseif this.mode == editField.EDIT_MODE then
                    this.onEdit()
                end
            end

            native.setKeyboardFocus(nil)
        end

        if ( e.phase == "editing" ) then
            
        end
    end

    this:addEventListener( "userInput", textListener )

    return this
end

return editField