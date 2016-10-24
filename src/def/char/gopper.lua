local image_w = 195 --This info can be accessed with a Love2D call
local image_h = 489 --after the image has been loaded

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local step_sfx = function(slf)
    sfx.play("sfx", slf.sfx.step, 0.5, 1 + 0.02 * love.math.random(-2,2))
    local padust = PA_DUST_STEPS:clone()
    padust:setLinearAcceleration(-slf.face * 50, 1, -slf.face * 100, -15)
    padust:emit(3)
    stage.objects:add(Effect:new(padust, slf.x - 20 * slf.face, slf.y+2))
end
local dash_belly_clouds = function(slf)
    slf.isHittable = false
    sfx.play("sfx", "fall", 0.5, 1 + 0.02 * love.math.random(-2,2))
    --landing dust clouds
    local psystem = PA_DUST_LANDING:clone()
    psystem:setLinearAcceleration(150, 1, 300, -35)
    psystem:setDirection( 0 )
    psystem:setPosition( 20, 0 )
    psystem:emit(5)
    psystem:setLinearAcceleration(-150, 1, -300, -35)
    psystem:setDirection( 3.14 )
    psystem:setPosition( -20, 0 )
    psystem:emit(5)
    stage.objects:add(Effect:new(psystem, slf.x + 10 * slf.face, slf.y+2))
end
local combo_punch = function(slf)
    slf:checkAndAttack(28,0, 26,12, 7, "high", slf.velx, "air")
    slf.cool_down_combo = 0.4
end
local combo_kick = function(slf)
    slf:checkAndAttack(30,0, 26,12, 9, "fall", slf.velx, "air")
end
local dash_attack = function(slf) slf:checkAndAttack(12,0, 30,12, 14, "fall", slf.velocity_dash_fall) end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = "res/img/char/gopper.png", -- The path to the spritesheet
    --TODO read width/height of the sheet automatically.
    sprite_name = "gopper", -- The name of the sprite

    delay = 0.20,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(39, 12, 33, 17) }
        },
        intro = {
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 5
        },
        stand = {
            -- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            { q = q(40,3,36,61), ox = 18, oy = 60 }, --stand 2
            { q = q(78,4,36,60), ox = 18, oy = 59 }, --stand 3
            { q = q(40,3,36,61), ox = 18, oy = 60 }, --stand 2
            loop = true,
            delay = 0.167
        },
        walk = {
            { q = q(116,2,36,62), ox = 18, oy = 61 }, --walk 1
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            { q = q(154,3,38,61), ox = 18, oy = 60 }, --walk 2
            { q = q(2,2,36,62), ox = 18, oy = 61 }, --stand 1
            loop = true,
            delay = 0.167
        },
        run = {
            { q = q(2,246,48,59), ox = 23, oy = 59 }, --run 1
            { q = q(52,244,46,61), ox = 23, oy = 61, delay = 0.13 }, --run 2
            { q = q(100,245,48,60), ox = 23, oy = 60, func = step_sfx }, --run 3
            { q = q(2,310,48,60), ox = 23, oy = 59 }, --run 4
            { q = q(52,308,47,62), ox = 23, oy = 61, delay = 0.13 }, --run 5
            { q = q(101,309,50,60), ox = 23, oy = 59, func = step_sfx }, --run 6
            loop = true,
            delay = 0.08
        },
        jump = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        respawn = {
            { q = q(2,372,58,52), ox = 24, oy = 51, delay = 5 }, --dash
            { q = q(62,389,68,35), ox = 28, oy = 27, delay = 0.5 }, --lying down on belly
            { q = q(132,372,56,48), ox = 22, oy = 44 }, --getting up on belly
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 0.3
        },
        duck = {
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 0.15
        },
        pickup = {
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 0.28
        },
        dash = {
            { q = q(2,372,58,52), ox = 24, oy = 51, funcCont = dash_attack, delay = 0.5 }, --dash
            -- below: temporary frames, move elsewhere later
            { q = q(62,389,68,35), ox = 28, oy = 27, func = dash_belly_clouds, delay = 0.8 }, --lying down on belly
            { q = q(132,372,56,48), ox = 22, oy = 44 }, --getting up on belly
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 0.3
        },
        combo1 = {
            { q = q(2,66,46,61), ox = 18, oy = 60 }, --punch1
            { q = q(50,66,62,61), ox = 18, oy = 60, func = combo_punch, delay = 0.2 }, --punch2
            { q = q(2,66,46,61), ox = 18, oy = 60, delay = 0.01 }, --punch1
            delay = 0.005
        },
        combo2 = {
            { q = q(2,66,46,61), ox = 18, oy = 60 }, --punch1
            { q = q(50,66,62,61), ox = 18, oy = 60, func = combo_punch, delay = 0.2 }, --punch2
            { q = q(2,66,46,61), ox = 18, oy = 60, delay = 0.01 }, --punch1
            delay = 0.005
        },
        combo3 = {
            { q = q(2,426,40,61), ox = 16, oy = 60 }, --kick1
            { q = q(44,426,60,61), ox = 15, oy = 60, func = combo_kick, delay = 0.23 }, --kick2
            { q = q(2,426,40,61), ox = 16, oy = 60, delay = 0.015 }, --kick1
            delay = 0.01
        },
        fall = {
            { q = q(2,199,67,43), ox = 33, oy = 42 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,199,67,43), ox = 33, oy = 42 }, --falling
            delay = 5
        },
        getup = {
            { q = q(71,199,65,43), ox = 32, oy = 32, delay = 0.2 }, --lying down
            { q = q(138,193,55,49), ox = 24, oy = 48 }, --getting up
            { q = q(114,71,38,56), ox = 18, oy = 55 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(71,199,65,43), ox = 32, oy = 32 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,129,38,62), ox = 20, oy = 61, delay = 0.03 }, --hh1
            { q = q(42,129,43,62), ox = 25, oy = 61 }, --hh2
            { q = q(2,129,38,62), ox = 20, oy = 61, delay = 0.1 }, --hh1
            delay = 0.3
        },
        hurtLow = {
            { q = q(87,130,37,61), ox = 19, oy = 60, delay = 0.03 }, --hl1
            { q = q(126,132,42,59), ox = 20, oy = 58 }, --hl2
            { q = q(87,130,37,61), ox = 19, oy = 60, delay = 0.1 }, --hl1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackLight = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 5
        },
        sideStepUp = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        sideStepDown = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grab = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabHit = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabHitLast = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabHitEnd = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.1
        },
        grabThrow = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabSwap = {
            { q = q(135,66,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabbed = {
            { q = q(2,129,38,62), ox = 20, oy = 61 }, --hh1
            { q = q(42,129,43,62), ox = 25, oy = 61 }, --hh2
            delay = 0.1
        },

    } --offsets

} --return (end of file)
