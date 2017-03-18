local sprite_sheet = "res/img/char/niko.png"
local image_w,image_h = LoadSpriteSheet(sprite_sheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, image_w, image_h)
end
local combo_kick = function(slf, cont)
    slf:checkAndAttack(
        { left = 30, width = 26, height = 12, damage = 7, type = "low", velocity = slf.velx, sfx = "air" },
        cont
    )
    slf.cool_down_combo = 0.4
end
local combo_punch = function(slf, cont)
    slf:checkAndAttack(
        { left = 30, width = 26, height = 12, damage = 9, type = "fall", velocity = slf.velx, sfx = "air" },
        cont
    )
end
local jump_forward_attack = function(slf, cont)
    slf:checkAndAttack(
        { left = 16, width = 22, height = 12, damage = 14, type = "fall", velocity = slf.velx },
        cont
    )
end

return {
    serialization_version = 0.42, -- The version of this serialization process

    sprite_sheet = sprite_sheet, -- The path to the spritesheet
    sprite_name = "niko", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon  = {
            { q = q(39, 14, 37, 17) }
        },
        intro = {
            { q = q(114,73,38,58), ox = 18, oy = 57 }, --duck
            delay = 5
        },
        stand = {
            -- q = Love.graphics.newQuad( X, Y, Width, Height, Image_W, Image_H),
            -- ox,oy pivots offsets from the top left corner of the quad
            -- delay = 0.1, func = fun
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            { q = q(40,3,36,63), ox = 18, oy = 62 }, --stand 2
            { q = q(78,4,36,62), ox = 18, oy = 61 }, --stand 3
            { q = q(40,3,36,63), ox = 18, oy = 62 }, --stand 2
            loop = true,
            delay = 0.175
        },
        walk = {
            { q = q(116,2,36,64), ox = 18, oy = 63 }, --walk 1
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            { q = q(154,3,38,63), ox = 18, oy = 62 }, --walk 2
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            loop = true,
            delay = 0.175
        },
        run = { --TODO: Remove
            { q = q(116,2,36,64), ox = 18, oy = 63 }, --walk 1
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            { q = q(154,3,38,63), ox = 18, oy = 62 }, --walk 2
            { q = q(2,2,36,64), ox = 18, oy = 63 }, --stand 1
            loop = true,
            delay = 0.1
        },
        jump = {
            { q = q(2,264,57,66), ox = 18, oy = 65 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,264,57,66), ox = 18, oy = 65, delay = 5 }, --jump
            { q = q(55,218,75,43), ox = 42, oy = 32, delay = 0.5 }, --lying down
            { q = q(132,209,58,52), ox = 26, oy = 51 }, --getting up
            { q = q(114,73,38,58), ox = 18, oy = 57 }, --duck
            delay = 0.3
        },
        duck = {
            { q = q(114,73,38,58), ox = 18, oy = 57 }, --duck
            delay = 0.15
        },
        pickup = {
            { q = q(114,73,38,58), ox = 18, oy = 57 }, --duck
            delay = 0.28
        },
        dashAttack = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.16
        },
        combo1 = {
            { q = q(2,332,40,63), ox = 16, oy = 62 }, --kick 1
            { q = q(44,332,60,63), ox = 15, oy = 62, func = combo_kick, delay = 0.23 }, --kick 2
            { q = q(2,332,40,63), ox = 16, oy = 62, delay = 0.015 }, --kick 1
            delay = 0.01
        },
        combo2 = {
            { q = q(2,332,40,63), ox = 16, oy = 62 }, --kick 1
            { q = q(44,332,60,63), ox = 15, oy = 62, func = combo_kick, delay = 0.23 }, --kick 2
            { q = q(2,332,40,63), ox = 16, oy = 62, delay = 0.015 }, --kick 1
            delay = 0.01
        },
        combo3 = {
            { q = q(50,68,62,63), ox = 18, oy = 62, func = combo_punch, delay = 0.2 }, --punch 2
            { q = q(2,68,46,63), ox = 18, oy = 62 }, --punch 1
            delay = 0.01
        },
        fall = {
            { q = q(2,199,51,62), ox = 25, oy = 61 }, --falling
            delay = 5
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,199,51,62), ox = 25, oy = 61, rotate = -1.57, rx = 30, ry = -25}, --falling
            delay = 5
        },
        getup = {
            { q = q(55,218,75,43), ox = 42, oy = 32, delay = 0.2 }, --lying down
            { q = q(132,209,58,52), ox = 26, oy = 51 }, --getting up
            { q = q(114,73,38,58), ox = 18, oy = 57 }, --duck
            delay = 0.3
        },
        fallen = {
            { q = q(55,218,75,43), ox = 42, oy = 32 }, --lying down
            delay = 65
        },
        hurtHigh = {
            { q = q(2,133,41,64), ox = 23, oy = 63, delay = 0.03 }, --hurt high 1
            { q = q(45,133,46,64), ox = 28, oy = 63 }, --hurt high 2
            { q = q(2,133,41,64), ox = 23, oy = 63, delay = 0.1 }, --hurt high 1
            delay = 0.3
        },
        hurtLow = {
            { q = q(93,134,40,63), ox = 19, oy = 62, delay = 0.03 }, --hurt low 1
            { q = q(135,136,44,61), ox = 20, oy = 60 }, --hurt low 2
            { q = q(93,134,40,63), ox = 19, oy = 62, delay = 0.1 }, --hurt low 1
            delay = 0.3
        },
        jumpAttackForward = {
            { q = q(61,265,56,63), ox = 28, oy = 64 }, --jump attack forward 1
            { q = q(119,263,64,67), ox = 36, oy = 66, funcCont = jump_forward_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        jumpAttackLight = { --TODO: Remove
            { q = q(61,265,56,63), ox = 28, oy = 64 }, --jump attack forward 1
            { q = q(119,263,64,67), ox = 36, oy = 66, funcCont = jump_forward_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        jumpAttackStraight = {
            { q = q(61,265,56,63), ox = 28, oy = 64 }, --jump attack forward 1
            { q = q(119,263,64,67), ox = 36, oy = 66, funcCont = jump_forward_attack, delay = 5 }, --jump attack forward 2
            delay = 0.12
        },
        sideStepUp = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        sideStepDown = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grab = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabAttack = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        grabAttackLast = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.05
        },
        shoveDown = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
            delay = 0.1
        },
        shoveForward = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabSwap = { --TODO: Remove
            { q = q(134,68,60,60), ox = 30, oy = 59 }, --no frame
        },
        grabbed = {
            { q = q(2,133,41,64), ox = 23, oy = 63 }, --hurt high 1
            { q = q(45,133,46,64), ox = 28, oy = 63 }, --hurt high 2
            delay = 0.1
        },

    } --offsets

} --return (end of file)
