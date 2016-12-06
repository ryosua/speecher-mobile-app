local pressListener = {}

function pressListener.new(deleteBarI, crudController)
    local pressTimer

    local function onPressStart()
        deleteBarI.alpha = 1
        -- Move to the top of the scene group
        deleteBarI.parent:insert(deleteBarI)
    end

    local function onPressEnd()
        deleteBarI.alpha = 0
        crudController.hideTextField()
    end

    local function this(e)
        local pressTime = 500
        
        if e.phase == "began" then
            print(e.phase)

            -- Tag item for deletion
            crudController.visualItemToDelete = e.target
            crudController.itemToDelete =  e.target

            pressTimer = timer.performWithDelay(pressTime, onPressStart, 1)

            e.target.markX = e.target.x    -- store x location of object
            e.target.markY = e.target.y    -- store y location of object

            return true

        elseif e.phase == "moved" then
            print(e.phase)

            -- If this is triggered by the card that was not "picked up", it should not do anything.
            if (e.target.markX ~= nil) and (e.target.markY ~= nil) then
                local x = (e.x - e.xStart) + e.target.markX
                local y = (e.y - e.yStart) + e.target.markY
                
                e.target.x, e.target.y = x, y    -- move object based on calculations above

                return true
            end

        elseif e.phase == "ended" then
            print(e.phase)
            if pressTimer ~= nil then
                timer.cancel(pressTimer)
            end
            
            onPressEnd()
            -- Let touch propogate through to the delete bar.
        end
    end

    return this
end

return pressListener