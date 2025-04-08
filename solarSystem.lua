-----------------------------------------------------------------------------------------
-- main.lua
-----------------------------------------------------------------------------------------

local composer = require("composer")
local scene = composer.newScene()

local CW, CH = display.contentWidth, display.contentHeight

-- Variables
local isPlaying = false
local currentPopup
local isDropdownOpen = false

-- Sistema Solar
local sun, planets, angle, radius, moons, comet, angleComet
local toggleables, orbitLines, starField = {}, {}, {}

-- UI
local dropdownItems, toggleBtn = {}, nil
local visualGroup, uiGroup

-- Sonidos
local clickSound = audio.loadSound("click.mp3")
local playSound = audio.loadSound("play.mp3")
local pauseSound = audio.loadSound("pause.mp3")

-- Estrellas animadas
local function createStarField(group)
    for i = 1, 100 do
        local star = display.newCircle(group, math.random(CW), math.random(CH), math.random(1, 2))
        star:setFillColor(1, 1, 1, math.random(3, 8) / 10)
        table.insert(starField, star)
    end
end

local function animateStars()
    for _, star in ipairs(starField) do
        transition.to(star, {
            time = math.random(2000, 4000),
            alpha = math.random(3, 8) / 10,
            onComplete = animateStars
        })
    end
end

-- Partículas
local function showParticles(x, y)
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
local function showPopup(name, y)
    if currentPopup then
        display.remove(currentPopup.bg)
        display.remove(currentPopup.text)
        currentPopup = nil
    end

    local bg = display.newRoundedRect(CW / 2, y - 40, 160, 50, 8)
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
        isPlaying = true
    end)
end

-- Movimiento
local function rotateSun()
    sun.rotation = sun.rotation + 0.5
end

local function orbitPlanets()
    if not isPlaying then return end
    for i, p in ipairs(planets) do
        angle[i] = angle[i] + 0.3 + (i * 0.02)
        local rad = math.rad(angle[i])
        p.x = sun.x + radius[i] * math.cos(rad)
        p.y = sun.y + radius[i] * math.sin(rad)
        if p.light then
            p.light.x = p.x - 10
            p.light.y = p.y
        end
    end
end

local function orbitMoons()
    if not isPlaying then return end
    for _, moon in ipairs(moons) do
        moon.angle = moon.angle + 2
        local rad = math.rad(moon.angle)
        moon.x = moon.planet.x + moon.radius * math.cos(rad)
        moon.y = moon.planet.y + moon.radius * math.sin(rad)
    end
end

local function moveComet()
    if not isPlaying then return end
    angleComet = angleComet + 0.8
    local rad = math.rad(angleComet)
    local a, b = 400, 120
    comet.x = sun.x + a * math.cos(rad)
    comet.y = sun.y + b * math.sin(rad)
end

-- Play & Pause con animación tipo big bang
local function playSystem()
    isPlaying = true
    audio.play(playSound)
    for _, p in ipairs(planets) do
        transition.from(p, {
            time = 1000,
            x = sun.x,
            y = sun.y,
            transition = easing.outExpo
        })
    end
    for _, moon in ipairs(moons) do
        transition.from(moon, {
            time = 1000,
            x = sun.x,
            y = sun.y,
            transition = easing.outExpo
        })
    end
end

local function pauseSystem()
    isPlaying = false
    audio.play(pauseSound)
    for _, p in ipairs(planets) do
        transition.to(p, {
            time = 1000,
            x = sun.x,
            y = sun.y,
            transition = easing.inExpo
        })
    end
    for _, moon in ipairs(moons) do
        transition.to(moon, {
            time = 1000,
            x = sun.x,
            y = sun.y,
            transition = easing.inExpo
        })
    end
end

-- Dropdown toggle
local function hideDropdown()
    for _, obj in ipairs(dropdownItems) do display.remove(obj) end
    dropdownItems = {}
    isDropdownOpen = false
end

local function showDropdown()
    hideDropdown()
    for i, entry in ipairs(toggleables) do
        local icon = entry.object.isVisible and "✅" or "❌"
        local bg = display.newRoundedRect(toggleBtn.x, toggleBtn.y + i * 30, 140, 25, 6)
        bg:setFillColor(0, 0, 0.3, 0.9)
        bg.strokeWidth = 1
        bg:setStrokeColor(1, 1, 1)
        local txt = display.newText({ text = icon .. " " .. entry.name, x = bg.x, y = bg.y, fontSize = 13 })
        uiGroup:insert(bg)
        uiGroup:insert(txt)
        local function toggle()
            entry.object.isVisible = not entry.object.isVisible
            showDropdown()
        end
        bg:addEventListener("tap", toggle)
        txt:addEventListener("tap", toggle)
        table.insert(dropdownItems, bg)
        table.insert(dropdownItems, txt)
    end
    toggleBtn:toFront()
    isDropdownOpen = true
end

-- Crear escena
function scene:create(event)
    local sceneGroup = self.view

    visualGroup = display.newGroup()
    uiGroup = display.newGroup()
    sceneGroup:insert(visualGroup)
    sceneGroup:insert(uiGroup)

    createStarField(visualGroup)
    animateStars()

    -- Sol
    sun = display.newImageRect("sun.png", 100, 100)
    sun.x = CW / 2
    sun.y = CH / 2

    planets, angle, radius = {}, {}, { 100, 130, 160, 190, 220, 250, 280 }

    for i = 1, 7 do
        local orbit = display.newCircle(CW / 2, CH / 2, radius[i])
        orbit:setStrokeColor(0.2, 0.3, 1, 0.4)
        orbit.strokeWidth = 1
        orbit:setFillColor(0, 0, 0, 0)
        visualGroup:insert(orbit)

        local p = display.newImageRect("planeta" .. i .. ".png", 30, 30)
        p.x, p.y = sun.x, sun.y
        angle[i] = math.random(360)
        planets[i] = p

        local light = display.newCircle(p.x - 10, p.y, 12)
        light:setFillColor(0, 0, 0, 0.5)
        p.light = light
        visualGroup:insert(light)
        visualGroup:insert(p)

        p:addEventListener("tap", function()
            isPlaying = false
            audio.play(clickSound)
            showParticles(p.x, p.y)
            showPopup("Planeta " .. i, p.y)
        end)

        table.insert(toggleables, { object = p, name = "Planeta " .. i })
    end

    moons = {}
    for i = 1, 3 do
        local moon = display.newImageRect("luna.png", 10, 10)
        moon.planet = planets[i + 2]
        moon.angle = math.random(360)
        moon.radius = 15
        table.insert(moons, moon)
        visualGroup:insert(moon)

        moon:addEventListener("tap", function()
            isPlaying = false
            audio.play(clickSound)
            showParticles(moon.x, moon.y)
            showPopup("Luna " .. i, moon.y)
        end)

        table.insert(toggleables, { object = moon, name = "Luna " .. i })
    end

    comet = display.newImageRect("cometa.png", 30, 30)
    comet.x, comet.y = CW / 2, CH / 2
    angleComet = 0
    visualGroup:insert(comet)

    comet:addEventListener("tap", function()
        isPlaying = false
        audio.play(clickSound)
        showParticles(comet.x, comet.y)
        showPopup("Cometa", comet.y)
    end)

    table.insert(toggleables, { object = comet, name = "Cometa" })
    visualGroup:insert(sun)

    -- Botones UI
    local playBtn = display.newText({ text = "Play", x = 60, y = 30, fontSize = 18 })
    playBtn:addEventListener("tap", playSystem)
    uiGroup:insert(playBtn)

    local pauseBtn = display.newText({ text = "Pause", x = 140, y = 30, fontSize = 18 })
    pauseBtn:addEventListener("tap", pauseSystem)
    uiGroup:insert(pauseBtn)

    toggleBtn = display.newText({ text = "Toggle ▼", x = CW - 60, y = 30, fontSize = 14 })
    toggleBtn:addEventListener("tap", function()
        if isDropdownOpen then hideDropdown() else showDropdown() end
    end)
    uiGroup:insert(toggleBtn)
end

function scene:show(event)
    if event.phase == "did" then
        Runtime:addEventListener("enterFrame", rotateSun)
        Runtime:addEventListener("enterFrame", orbitPlanets)
        Runtime:addEventListener("enterFrame", orbitMoons)
        Runtime:addEventListener("enterFrame", moveComet)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", rotateSun)
        Runtime:removeEventListener("enterFrame", orbitPlanets)
        Runtime:removeEventListener("enterFrame", orbitMoons)
        Runtime:removeEventListener("enterFrame", moveComet)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
