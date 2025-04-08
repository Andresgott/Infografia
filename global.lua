local M = {}

M.CW = display.contentWidth
M.CH = display.contentHeight

M.sounds = {
    click = audio.loadSound("click.mp3"),
    play = audio.loadSound("play.mp3"),
    pause = audio.loadSound("pause.mp3")
}

return M
