local audioController = {}

function audioController.new()
    local this = {}

    -- Reserve the first channel for streams, the rest will play sounds.
    audio.reserveChannels(1)
    audio.setVolume(1, {channel = channel})

    -- A table to store loaded streams so they can be disposed later.
    local loadedStream

    function this.streamLoaded()
        local streamLoaded = false

        if loadedStream ~= nil then
            streamLoaded = true
        end

        return streamLoaded
    end

    --[[
        Returns audioHandle
    ]]--
    function this.loadStream(filename)
        loadedStream = audio.loadStream(filename, system.DocumentsDirectory)
    end

    --[[
        Returns audioHandle
    ]]--
    function this.loadSound(filename)
        return audio.loadSound(filename, system.DocumentsDirectory)
    end
    --[[
        Allows iPod music, and game sounds to be played at the same time.
        This function is constructed from a block of code from the Corona forum, with slight modifications.
    ]]--
    function this.enableIpodMusic()
        -- Set the audio mix mode to allow sounds from the app to mix with other sounds from the device
        if audio.supportsSessionProperty == true then
            audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
        end
         
        -- Store whether other audio is playing.  It's important to do this once and store the result now,
            -- as referring to audio.OtherAudioIsPlaying later gives misleading results, since at that point
            -- the app itself may be playing audio
        isOtherAudioPlaying = false
         
        if audio.supportsSessionProperty == true then
            if not(audio.getSessionProperty(audio.OtherAudioIsPlaying) == 0) then
                isOtherAudioPlaying = true
            end
        end
    end

    local function playStream(stream, channel, loops)
        audio.play( stream, { channel= channel, loops = loops, fadein= 0 } )
    end

    function this.playSound(sound, channel)
        audio.play(sound, {channel = channel})
    end

    function this.startSteam()
        audio.resume(1)
        playStream(loadedStream, 1, 0)
    end

    function this.pauseAudio()
       audio.pause(1)
    end

    function this.stopAudio()
        audio.stop()
    end

    function this.rewindAudio()
        audio.rewind(loadedStream)
    end

    function this.disposeAudio()
        audio.dispose(loadedStream)
        loadedStream = nil
    end

    function this.deleteFile(filename)
        local result, reason = os.remove(system.pathForFile(filename, system.DocumentsDirectory))

        if result then
           print("File removed")
        else
           print("File does not exist", reason)
        end
    end

    return this
end

return audioController