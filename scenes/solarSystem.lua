-----------------------------------------------------------------------------------------
-- main.lua
-----------------------------------------------------------------------------------------

local composer = require("composer")
local globals = require("global")
local ui = require("modules.ui")
local popup = require("modules.popup")
local motion = require("modules.motion")

local scene = composer.newScene()

-- Variables del sistema
local sun, planets, moons, comet
local angle, radius, angleComet = {}, {}, 0
local toggleables = {}
local visualGroup, uiGroup
local isPlaying = false

-- Referencias para los enterFrame
local rotate, orbitP, orbitM, moveC

function scene:create(event)
    local sceneGroup = self.view
    visualGroup = display.newGroup()
    uiGroup = display.newGroup()
    sceneGroup:insert(visualGroup)
    sceneGroup:insert(uiGroup)

    -- Fondo estrellado
    ui.createStarField(visualGroup)
    ui.animateStars()

    -- Sol
    sun = display.newImageRect("sun.png", 100, 100)
    sun.x, sun.y = globals.CW / 2, globals.CH / 2
    visualGroup:insert(sun)

    -- Planetas y órbitas
    planets = {}
    radius = { 100, 130, 160, 190, 220, 250, 280 }

    for i = 1, 7 do
        local orbit = display.newCircle(sun.x, sun.y, radius[i])
        orbit:setStrokeColor(0.2, 0.3, 1, 0.4)
        orbit.strokeWidth = 1
        orbit:setFillColor(0, 0, 0, 0)
        visualGroup:insert(orbit)

        local planet = display.newImageRect("planeta" .. i .. ".png", 30, 30)
        planet.x, planet.y = sun.x, sun.y
        angle[i] = math.random(360)
        planets[i] = planet

        local light = display.newCircle(planet.x - 10, planet.y, 12)
        light:setFillColor(0, 0, 0, 0.5)
        planet.light = light

        visualGroup:insert(light)
        visualGroup:insert(planet)

        planet:addEventListener("tap", function()
            isPlaying = false
            audio.play(globals.sounds.click)
            ui.showParticles(planet.x, planet.y)
            popup.showPopup("Planeta " .. i, planet.y, uiGroup, function()
                isPlaying = true
            end)
        end)

        table.insert(toggleables, { object = planet, name = "Planeta " .. i })
    end

    -- Lunas
    moons = {}
    for i = 1, 3 do
        local moon = display.newImageRect("luna.png", 10, 10)
        moon.planet = planets[i + 2]
        moon.angle = math.random(360)
        moon.radius = 15
        visualGroup:insert(moon)
        table.insert(moons, moon)

        moon:addEventListener("tap", function()
            isPlaying = false
            audio.play(globals.sounds.click)
            ui.showParticles(moon.x, moon.y)
            popup.showPopup("Luna " .. i, moon.y, uiGroup, function()
                isPlaying = true
            end)
        end)

        table.insert(toggleables, { object = moon, name = "Luna " .. i })
    end

    -- Cometa
    comet = display.newImageRect("cometa.png", 30, 30)
    comet.x, comet.y = sun.x, sun.y
    visualGroup:insert(comet)

    comet:addEventListener("tap", function()
        isPlaying = false
        audio.play(globals.sounds.click)
        ui.showParticles(comet.x, comet.y)
        popup.showPopup("Cometa", comet.y, uiGroup, function()
            isPlaying = true
        end)
    end)

    table.insert(toggleables, { object = comet, name = "Cometa" })

    -- Botones UI
    ui.createButtons(sceneGroup, visualGroup, uiGroup, toggleables,
        function()
            isPlaying = true
            motion.playSystem(planets, moons, sun)
        end,
        function()
            isPlaying = false
            motion.pauseSystem(planets, moons, sun)
        end
    )
end

function scene:show(event)
    if event.phase == "did" then
        rotate = function() motion.rotateSun(sun) end
        orbitP = function() motion.orbitPlanets(isPlaying, sun, planets, angle, radius) end
        orbitM = function() motion.orbitMoons(isPlaying, moons) end
        moveC = function()
            angleComet = motion.moveComet(isPlaying, sun, comet, angleComet)
        end

        Runtime:addEventListener("enterFrame", rotate)
        Runtime:addEventListener("enterFrame", orbitP)
        Runtime:addEventListener("enterFrame", orbitM)
        Runtime:addEventListener("enterFrame", moveC)
    end
end

function scene:hide(event)
    if event.phase == "will" then
        Runtime:removeEventListener("enterFrame", rotate)
        Runtime:removeEventListener("enterFrame", orbitP)
        Runtime:removeEventListener("enterFrame", orbitM)
        Runtime:removeEventListener("enterFrame", moveC)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)

return scene
