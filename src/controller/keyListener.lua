--[[
        Code is from a tutorial on Corona's website(with some modifications):
        http://coronalabs.com/blog/2013/03/26/androidizing-your-mobile-app/

        This only works on Android due to a limitation of Corona or iOS.
]]--

-- Modules
local composer = require "composer"

local keyListener = {}

function keyListener.new(cycleSlidesUp, cycleSlidesDown)
	local this = {}

	function this.onKeyEvent(event)
	    local phase = event.phase
	    local keyName = event.keyName

	    local currentScene = composer.getSceneName( "current" )

	    if ( ("back" == keyName) and phase == "up" ) then
	        if (  currentScene == "scenes.splash" ) then
	            native.requestExit()
	        else  
	            local lastScene = composer.state.returnTo
	            if ( lastScene ) then
	                 composer.gotoScene( lastScene )
	            else
	                -- Do nothing
	                --native.requestExit()
	            end
	        end
	    end

	    if ( keyName == "volumeUp" and phase == "down" ) then
	    	cycleSlidesDown()
	        return true
	    elseif ( keyName == "volumeDown" and phase == "down" ) then
	        cycleSlidesUp()
	        return true
	    end
	    
	    return true   -- Becuase behavior for the key is overrided.
	end

	return this
end

return keyListener