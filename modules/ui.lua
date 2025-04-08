-- ui.lua
local config = require("global")

local M = {}

-- Dropdown
M.dropdownItems = {}
M.isDropdownOpen = false
M.toggleBtn = nil

-- Estrellas animadas
M.starField = {}

function M.createStarField(group)
    for i = 1, 100 do
        local star = display.newCircle(group, math.random(config.CW), math.random(config.CH), math.random(1, 2))
        star:setFillColor(1, 1, 1, math.random(3, 8) / 10)
        table.insert(M.starField, star)
    end
end

function M.animateStars()
    for _, star in ipairs(M.starField) do
        transition.to(star, {
            time = math.random(2000, 4000),
            alpha = math.random(3, 8) / 10,
            onComplete = M.animateStars
        })
    end
end

-- Partículas
function M.showParticles(x, y)
    for i = 1, 10 do
        local dot = display.newCircle(x, y, 3)
        dot:setFillColor(1, 1, 1)
        transition.to(dot, {
            time = 1000,
            x = x + math.random(-30, 30),
            y = y + math.random(-30, 30),
            alpha = 0,
            onComplete = function() display.remove(dot) end
        })
    end
end

-- Popup
function M.showPopup(name, y, uiGroup, onClose)
    if M.currentPopup then
        display.remove(M.currentPopup.bg)
        display.remove(M.currentPopup.text)
        M.currentPopup = nil
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

    M.currentPopup = { bg = bg, text = txt }

    timer.performWithDelay(3000, function()
        if M.currentPopup then
            display.remove(M.currentPopup.bg)
            display.remove(M.currentPopup.text)
            M.currentPopup = nil
        end
        if onClose then onClose() end
    end)
end

-- Botones UI
function M.createButtons(sceneGroup, visualGroup, uiGroup, toggleables, onPlay, onPause)
    local playBtn = display.newText({ text = "Play", x = 60, y = 30, fontSize = 18 })
    playBtn:addEventListener("tap", onPlay)
    uiGroup:insert(playBtn)

    local pauseBtn = display.newText({ text = "Pause", x = 140, y = 30, fontSize = 18 })
    pauseBtn:addEventListener("tap", onPause)
    uiGroup:insert(pauseBtn)

    M.toggleBtn = display.newText({ text = "Toggle ▼", x = config.CW - 60, y = 30, fontSize = 14 })
    uiGroup:insert(M.toggleBtn)

    M.toggleBtn:addEventListener("tap", function()
        if M.isDropdownOpen then
            M.hideDropdown()
        else
            M.showDropdown(toggleables, uiGroup)
        end
    end)
end

function M.hideDropdown()
    for _, obj in ipairs(M.dropdownItems) do
        display.remove(obj)
    end
    M.dropdownItems = {}
    M.isDropdownOpen = false
end

function M.showDropdown(toggleables, uiGroup)
    M.hideDropdown()

    for i, entry in ipairs(toggleables) do
        local icon = entry.object.isVisible and "✅" or "❌"
        local bg = display.newRoundedRect(M.toggleBtn.x, M.toggleBtn.y + i * 30, 140, 25, 6)
        bg:setFillColor(0, 0, 0.3, 0.9)
        bg.strokeWidth = 1
        bg:setStrokeColor(1, 1, 1)

        local txt = display.newText({
            text = icon .. " " .. entry.name,
            x = bg.x, y = bg.y, fontSize = 13
        })

        uiGroup:insert(bg)
        uiGroup:insert(txt)

        local function toggle()
            entry.object.isVisible = not entry.object.isVisible
            M.showDropdown(toggleables, uiGroup)
        end

        bg:addEventListener("tap", toggle)
        txt:addEventListener("tap", toggle)

        table.insert(M.dropdownItems, bg)
        table.insert(M.dropdownItems, txt)
    end

    M.toggleBtn:toFront()
    M.isDropdownOpen = true
end

return M
