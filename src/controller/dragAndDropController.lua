local dragAndDropController = {}

-- Modules
local rowIndicator = require "src.view.rowIndicator"

function dragAndDropController.new(crudControllerI, crudGUIController)
	local this = {}

	this.dragPosition = {}
    this.rowBeingDragged = nil
    this.dragStartPosition = nil
    this.dragStartY = nil
    this.tableViewI = nil

    --[[
        A runtime to continuously update the position of the row indicator. This is simpler than using a combination of
        event listeners, and makes the animation much smoother.
    ]]--
    local function rowDragRuntime()
        this.rowBeingDragged.indicator.y =  this.dragPosition.y

        local distanceDragged = this.dragPosition.y - this.dragStartY
        
        local roundingFunction

        if distanceDragged >= 0 then
            roundingFunction = math.floor
        else
            roundingFunction = math.ceil
        end

        local numberOfRowsOffset = roundingFunction(distanceDragged / this.rowBeingDragged.contentHeight)

        if numberOfRowsOffset == 1 or numberOfRowsOffset == -1 then
            local otherModel = crudControllerI.getModels()[this.dragStartPosition + numberOfRowsOffset]

            -- Choose an animation based on the direction of the offset
            local animate
            if numberOfRowsOffset == 1 then
                animate = crudGUIController.transitionTableViewUp
            else
                animate = crudGUIController.transitionTableViewDown
            end

            -- Check for nil (the user could drag 1 or more below or above the last or first row)
            if otherModel ~= nil then
                crudControllerI.swap(this.rowBeingDragged.params.model.id, otherModel.id)
                animate(this.tableViewI:getRowAtIndex(this.dragStartPosition + numberOfRowsOffset))

                this.tableViewI.refreshRows()
                this.dragStopped()

                -- Set the new starting position and index
                this.dragStartY = this.dragPosition.y
                this.dragStartPosition = this.dragStartPosition + numberOfRowsOffset

                local row = this.tableViewI:getRowAtIndex(this.dragStartPosition)
                row.indicator = rowIndicator.new(_W * .5, row.contentHeight * 0.5, _W * .925, row.contentHeight * .9)
                row.indicator.alpha = .5
                this.dragStarted(row, this.tableViewI)
            end
        end
    end

    function this.dragStarted(row, tableViewI)
        this.rowBeingDragged = row
        this.dragPosition.y = this.rowBeingDragged.y
        this.dragStartY = this.rowBeingDragged.y + tableViewI.y
        this.rowBeingDragged.alpha = 0
        Runtime:addEventListener("enterFrame", rowDragRuntime)
    end

    function this.dragStopped()
        if this.rowBeingDragged ~= nil then
            this.rowBeingDragged.alpha = 1
            
            display.remove(this.rowBeingDragged.indicator)
            this.rowBeingDragged.indicator = nil

            this.rowBeingDragged = nil
            this.dragStartY = nil

            Runtime:removeEventListener("enterFrame", rowDragRuntime)
        end
    end

    function this.setTableView(tableView)
        this.tableViewI = tableView
    end

	return this
end

return dragAndDropController