local swipeListener = {}

--[[
	A listener that detects right and left swipes and performs an action when either type of
	swipe is detected. Change the threshold to be more or less senstive to swipes.
]]--

-- How much of a difference to register a swipe
local SWIPE_THRESHOLD = 50

function swipeListener.new(onSwipeLeft, onSwipeRight)
	assert(onSwipeLeft, "You must specify a behavior for a left swipe")
	assert(onSwipeRight, "You must specify a behavior for a right swipe")
	local startX

	local function this(e)
		if e.phase == "began" then
			print "Swiped"
			startX = e.x
		end

		if e.phase == "ended" then
			-- Check for nil because this event is fired when they enter deliver
			if startX ~= nil then
				local difference = e.x - startX

				if difference > SWIPE_THRESHOLD then
					onSwipeRight()
				end

				if difference < (SWIPE_THRESHOLD  * -1) then
					onSwipeLeft()
				end 
			end
		end
	end

	return this
end

return swipeListener