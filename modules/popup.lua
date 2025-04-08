local config = require("global")
local M = {}

local currentPopup = nil

function M.showPopup(name, y, uiGroup, onClose)
    if currentPopup then
        display.remove(currentPopup.bg)
        display.remove(currentPopup.text)
        currentPopup = nil
    end

    local bg = display.newRoundedRect(config.CW / 2, y - 40, 160, 50, 8)
    bg:setFillColor(0.1, 0.1, 0.2, 0.9)
    bg.strokeWidth = 2
    bg:setStrokeColor(1, 1, 1)

    local txt = display.newText({
        text = "📍 " .. name .. "\nLat: " .. math.floor(y),
        x = bg.x, y = bg.y, fontSize = 12, align = "center"
    })

    uiGroup:insert(bg)
    uiGroup:insert(txt)

    currentPopup = { bg = bg, text = txt }

    timer.performWithDelay(3000, function()
        if currentPopup then
            display.remove(currentPopup.bg)
            display.remove(currentPopup.text)
            currentPopup = nil
        end
        if onClose then onClose() end
    end)
end


return M
