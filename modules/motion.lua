--motion.lua

local globals = require("global")

local M = {}

function M.rotateSun(sun)
    sun.rotation = sun.rotation + 0.5
end

function M.orbitPlanets(isPlaying, sun, planets, angle, radius)
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

function M.orbitMoons(isPlaying, moons)
    if not isPlaying then return end
    for _, moon in ipairs(moons) do
        moon.angle = moon.angle + 2
        local rad = math.rad(moon.angle)
        moon.x = moon.planet.x + moon.radius * math.cos(rad)
        moon.y = moon.planet.y + moon.radius * math.sin(rad)
    end
end

function M.moveComet(isPlaying, sun, comet, angleComet)
    if not isPlaying then return angleComet end
    angleComet = angleComet + 0.8
    local rad = math.rad(angleComet)
    local a, b = 400, 120
    comet.x = sun.x + a * math.cos(rad)
    comet.y = sun.y + b * math.sin(rad)
    return angleComet
end

function M.playSystem(planets, moons, sun, comet)
    audio.play(globals.sounds.play)
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
    transition.from(comet, {
        time = 1000,
        x = sun.x,
        y = sun.y,
        transition = easing.outExpo
    })
end

function M.pauseSystem(planets, moons, sun, comet)
    audio.play(globals.sounds.pause)
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
    transition.to(comet, {
        time = 1000,
        x = sun.x,
        y = sun.y,
        transition = easing.inExpo
    })    
end

function M.initializePositions(planets, angle, radius, sun, moons, comet, angleComet)
    -- Posicionar planetas en el centro
    for _, p in ipairs(planets) do
        p.x = sun.x
        p.y = sun.y
        if p.light then
            p.light.x = sun.x - 10
            p.light.y = sun.y
            p.light.isVisible = false  
        end
        
    end

    -- Posicionar lunas en el centro
    for _, moon in ipairs(moons) do
        moon.x = sun.x
        moon.y = sun.y
    end

    -- Posicionar cometa en el centro
    comet.x = sun.x
    comet.y = sun.y
end


return M
