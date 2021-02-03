local Audio = class("Audio")

function Audio.PlayBackgroudMusic()
    ccexp.AudioEngine:play2d("music/backgroud.mp3" ,true)
end

function Audio.PlayEffect(res)
    ccexp.AudioEngine:play2d(res, false)
end

return Audio