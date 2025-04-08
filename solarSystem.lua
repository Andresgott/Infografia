----------------------------------------------------------------------------------------- 
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local composer = require("composer")
local scene = composer.newScene()

local CW = display.contentWidth
local CH = display.contentHeight
local isPlaying = false

local sun, planets, angle, radius, moons, comet, angleComet
local toggleables = {}
local dropdownGroup -- nuevo grupo para el menú desplegable

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

local function playSystem()
    isPlaying = true
    for _, p in ipairs(planets) do
        transition.from(p, {time = 1000, x = sun.x, y = sun.y, transition = easing.outExpo})
    end
    for _, moon in ipairs(moons) do
        transition.from(moon, {time = 1000, x = sun.x, y = sun.y, transition = easing.outExpo})
    end
end

local function pauseSystem()
    isPlaying = false
    for _, p in ipairs(planets) do
        transition.to(p, {time = 1000, x = sun.x, y = sun.y, transition = easing.inExpo})
    end
    for _, moon in ipairs(moons) do
        transition.to(moon, {time = 1000, x = sun.x, y = sun.y, transition = easing.inExpo})
    end
end

function scene:create(event)
    local sceneGroup = self.view

    local bg = display.newRect(sceneGroup, CW / 2, CH / 2, CW, CH)
    bg:setFillColor(0, 0, 0.1)

    sun = display.newImageRect(sceneGroup, "sun.png", 100, 100)
    sun.x = CW / 2
    sun.y = CH / 2

    planets = {}
    angle = {}
    radius = {100, 130, 160, 190, 220, 250, 280}
    for i = 1, 7 do
        local p = display.newImageRect(sceneGroup, "planeta" .. i .. ".png", 30, 30)
        p.x = sun.x
        p.y = sun.y
        angle[i] = math.random(360)
        planets[i] = p
        table.insert(toggleables, {object = p, name = "Planeta " .. i})
        sceneGroup:insert(p)
    end

    moons = {}
    for i = 1, 3 do
        local moon = display.newImageRect(sceneGroup, "luna.png", 10, 10)
        moon.planet = planets[i + 2]
        moon.angle = math.random(360)
        moon.radius = 15
        table.insert(moons, moon)
        table.insert(toggleables, {object = moon, name = "Luna " .. i})
    end

    comet = display.newImageRect(sceneGroup, "cometa.png", 30, 30)
    comet.x, comet.y = CW / 2, CH / 2
    angleComet = 0
    table.insert(toggleables, {object = comet, name = "Cometa"})

    local playBtn = display.newText({text = "Play", x = 60, y = 30, fontSize = 18})
    playBtn:addEventListener("tap", playSystem)
    sceneGroup:insert(playBtn)

    local pauseBtn = display.newText({text = "Pause", x = 140, y = 30, fontSize = 18})
    pauseBtn:addEventListener("tap", pauseSystem)
    sceneGroup:insert(pauseBtn)

    local toggleBtn = display.newText({
        text = "Toggle Element ▼",
        x = CW - 80,
        y = 30,
        fontSize = 14
    })
    sceneGroup:insert(toggleBtn)

    local dropdownVisible = false
    dropdownGroup = display.newGroup()
    sceneGroup:insert(dropdownGroup)

    local function hideDropdown()
        dropdownGroup:removeSelf()
        dropdownGroup = display.newGroup()
        sceneGroup:insert(dropdownGroup)
        dropdownVisible = false
    end

    local function showDropdown()
        hideDropdown()
        local itemHeight = 25
        local menuWidth, menuHeight = 160, #toggleables * itemHeight + 10
        local bg = display.newRoundedRect(dropdownGroup, toggleBtn.x, toggleBtn.y + menuHeight / 2, menuWidth, menuHeight, 12)
        bg:setFillColor(0, 0, 0.6, 0.8)
        bg.strokeWidth = 2
        bg:setStrokeColor(1, 1, 1, 0.6)

        for i, entry in ipairs(toggleables) do
            local isVisible = entry.object.isVisible
            local icon = isVisible and "✅" or "❌"
            local label = display.newText({
                text = icon .. " " .. entry.name,
                x = toggleBtn.x,
                y = toggleBtn.y + 10 + i * itemHeight,
                fontSize = 14
            })
            label:setFillColor(1, 1, 1)
            label:addEventListener("tap", function()
                entry.object.isVisible = not entry.object.isVisible
                showDropdown() -- refresh menu
            end)
            dropdownGroup:insert(label)
        end
        dropdownVisible = true
    end

    toggleBtn:addEventListener("tap", function()
        if dropdownVisible then
            hideDropdown()
        else
            showDropdown()
        end
    end)
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
