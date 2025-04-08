-- elements.lua
local config = require("config")
local utils = require("utils")
local M = {}

function M.createSolarElements(scene, visualGroup, uiGroup)
    local CW, CH = config.CW, config.CH
    local sun = display.newImageRect("sun.png", 100, 100)
    sun.x, sun.y = CW / 2, CH / 2
    visualGroup:insert(sun)

    local radius = { 100, 130, 160, 190, 220, 250, 280 }
    local planets, angle, moons, toggleables = {}, {}, {}

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
            audio.play(config.sounds.click)
            utils.showParticles(p.x, p.y)
            utils.showPopup("Planeta " .. i, p.y, uiGroup, function() isPlaying = true end)
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
            audio.play(config.sounds.click)
            utils.showParticles(moon.x, moon.y)
            utils.showPopup("Luna " .. i, moon.y, uiGroup, function() isPlaying = true end)
        end)

        table.insert(toggleables, { object = moon, name = "Luna " .. i })
    end

    local comet = display.newImageRect("cometa.png", 30, 30)
    comet.x, comet.y = CW / 2, CH / 2
    visualGroup:insert(comet)

    comet:addEventListener("tap", function()
        audio.play(config.sounds.click)
        utils.showParticles(comet.x, comet.y)
        utils.showPopup("Cometa", comet.y, uiGroup, function() isPlaying = true end)
    end)

    table.insert(toggleables, { object = comet, name = "Cometa" })

    return sun, planets, angle, radius, moons, comet, toggleables
end

return M
