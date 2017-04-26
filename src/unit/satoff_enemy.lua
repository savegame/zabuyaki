local class = require "lib/middleclass"
local Satoff = class('Satoff', Enemy)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Satoff:initialize(name, sprite, input, x, y, f)
    self.lives = self.lives or 3
    self.hp = self.hp or 100
    self.score_bonus = self.score_bonus or 1500
    self.height = self.height or 55
    if not f then
        f = {}
    end
    f.shapeType = f.shapeType or "polygon"
    f.shapeArgs = f.shapeArgs or { 1, 0, 27, 0, 28, 3, 27, 6, 1, 6, 0, 3 }
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    self.whichPlayerAttack = "close" -- random far close weak healthy fast slow
    self:pickAttackTarget()
    self.type = "enemy"
    self.subtype = "midboss"
    self.face = -1

    self.velocity_walk = 90
    self.velocity_walk_y = 45
    self.velocity_walkHold = 80
    self.velocity_walkHold_y = 40
    self.velocity_run = 140
    self.velocity_run_y = 23
    self.velocity_dash = 190 --speed of the character
--    self.velocity_dash_fall = 180 --speed caused by dash to others fall
    self.friction_dash = self.velocity_dash * 3
    --    self.velocity_shove_x = 220 --my throwing speed
    --    self.velocity_shove_z = 200 --my throwing speed
    --    self.velocity_shove_horizontal = 1.3 -- +30% for horizontal throws
    self.my_thrown_body_damage = 10  --DMG (weight) of my thrown body that makes DMG to others
    self.thrown_land_damage = 20  --dmg I suffer on landing from the thrown-fall

    self.sfx.dead = sfx.satoff_death
    self.sfx.dash_attack = sfx.satoff_attack
    self.sfx.step = "rick_step" --TODO refactor def files

    self:setToughness(0)
    self.walk_speed = 80
    self.run_speed = 100
    self:setState(self.intro)
end

function Satoff:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cool_down = self.cool_down - dt --when <=0 u can move

    --local complete_movement = self.move:update(dt)
    self.ai_poll_1 = self.ai_poll_1 - dt
    self.ai_poll_2 = self.ai_poll_2 - dt
    self.ai_poll_3 = self.ai_poll_3 - dt
    if self.ai_poll_1 < 0 then
        self.ai_poll_1 = self.max_ai_poll_1 + math.random()
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            local dist = self:getDistanceToClosestPlayer()
            if dist < self.wakeup_range
                    or (dist < self.delayed_wakeup_range and self.time > self.wakeup_delay )
            then
                if not self.target then
                    self:setState(self.intro)
                    return
                end
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cool_down <= 0 then
                --can move
                if not self.target then
                    self:setState(self.intro)
                    return
                end
                local t = dist(self.target.x, self.target.y, self.x, self.y)
                if t >= 250 and math.floor(self.y / 6) == math.floor(self.target.y / 6) then
                    self:setState(self.run)
                    return
                else
                    self:setState(self.walk)
                    return
                end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            if not self.target then
                self:setState(self.intro)
                return
            end
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 500 and t >= 180
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self:setState(self.run)
                return
            end
            if self.cool_down <= 0 then
                if math.abs(self.x - self.target.x) <= 60
                    and math.abs(self.y - self.target.y) <= 6
                then
                    self:setState(self.combo)
                    return
                end
            end
        elseif self.state == "run" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
        end
        -- Facing towards the target
        self:faceToTarget()
    end
    if self.ai_poll_2 < 0 then
        self.ai_poll_2 = self.max_ai_poll_2 + math.random()
    end
    if self.ai_poll_3 < 0 then
        self.ai_poll_3 = self.max_ai_poll_3 + math.random()

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t < 600 and self.state == "walk" then
            --set dest
        end
    end
end

function Satoff:combo_start()
    self.isHittable = true
    self:remove_tween_move()
    self.n_combo = 1
    self.horizontal = self.face
    self.velx = self.velocity_dash
    if self.n_combo == 1 then
        self:setSprite("combo1")
    end
    self.cool_down = 0.2
end

function Satoff:combo_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    self:calcMovement(dt, true, self.friction_dash)
end

Satoff.combo = { name = "combo", start = Satoff.combo_start, exit = nop, update = Satoff.combo_update, draw = Satoff.default_draw }

--States: intro, Idle?, Walk, Combo, HurtHigh, HurtLow, Fall/KO
function Satoff:intro_start()
    self.isHittable = true
    self:setSprite("intro")
end

function Satoff:intro_update(dt)
    self:calcMovement(dt, true, nil)
end

Satoff.intro = { name = "intro", start = Satoff.intro_start, exit = nop, update = Satoff.intro_update, draw = Enemy.default_draw }

function Satoff:stand_start()
    self.isHittable = true
    self.tx, self.ty = self.x, self.y
    self:setSprite("stand")
    self.victims = {}
    self.n_grabAttack = 0

    --self:pickAttackTarget()
    --    self.tx, self.ty = self.x, self.y
end

function Satoff:stand_update(dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcMovement(dt, true, nil)
end

Satoff.stand = { name = "stand", start = Satoff.stand_start, exit = nop, update = Satoff.stand_update, draw = Enemy.default_draw }

function Satoff:walk_start()
    self.isHittable = true
    self:setSprite("walk")
    if not self.target then
        self:setState(self.intro)
        return
    end
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(1 + t / self.walk_speed, self, {
            tx = self.target.x - love.math.random(40, 60),
            ty = self.target.y + 1
        }, 'inOutQuad')
    else
        self.move = tween.new(1 + t / self.walk_speed, self, {
            tx = self.target.x + love.math.random(40, 60),
            ty = self.target.y + 1
        }, 'inOutQuad')
    end
end
function Satoff:walk_update(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        --        if love.math.random() < 0.5 then
        --            self:setState(self.walk)
        --        else
        self:setState(self.stand)
        --        end
        return
    end
    self.can_jump = true
    self.can_attack = true
    self:calcMovement(dt, true, nil)
end
Satoff.walk = { name = "walk", start = Satoff.walk_start, exit = Unit.remove_tween_move, update = Satoff.walk_update, draw = Enemy.default_draw }

function Satoff:run_start()
    self.isHittable = true
    self:setSprite("run")
    local t = dist(self.target.x, self.y, self.x, self.y)

    --get to player(to fight)
    if self.x < self.target.x then
        self.move = tween.new(0.3 + t / self.run_speed, self, {
            tx = self.target.x - love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = 1
        self.horizontal = self.face
    else
        self.move = tween.new(0.3 + t / self.run_speed, self, {
            tx = self.target.x + love.math.random(25, 35),
            ty = self.y + 1 + love.math.random(-1, 1) * love.math.random(6, 8)
        }, 'inQuad')
        self.face = -1
        self.horizontal = self.face
    end
end
function Satoff:run_update(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t > 200 then
            self:setState(self.walk)
        else
            self:setState(self.combo)
        end
        return
    end
    self:calcMovement(dt, true, nil)
end
Satoff.run = {name = "run", start = Satoff.run_start, exit = Unit.remove_tween_move, update = Satoff.run_update, draw = Satoff.default_draw}

local dashAttack_speed = 0.75
function Satoff:dashAttack_start()
    self.isHittable = true
    self:setSprite("dashAttack")
    self.velx = self.velocity_dash * 2 * dashAttack_speed
    self.vely = 0
    self.velz = self.velocity_jump / 2 * dashAttack_speed
    self.z = 0.1
    sfx.play("voice"..self.id, self.sfx.dash_attack)
    --start jump dust clouds
    local psystem = PA_DUST_JUMP_START:clone()
    psystem:setAreaSpread( "uniform", 16, 4 )
    psystem:setLinearAcceleration(-30 , 10, 30, -10)
    psystem:emit(4)
    psystem:setAreaSpread( "uniform", 4, 4 )
    psystem:setPosition( 0, -16 )
    psystem:setLinearAcceleration(sign(self.face) * (self.velx + 200) , -50, sign(self.face) * (self.velx + 400), -700) -- Random movement in all directions.
    psystem:emit(2)
    stage.objects:add(Effect:new(psystem, self.x, self.y-1))
end
function Satoff:dashAttack_update(dt)
    if self.sprite.isFinished then
        self.z = 0
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * dashAttack_speed
    else
        self.velz = 0
        self.velx = 0
        self.z = 0
    end
    self:calcMovement(dt, true, self.friction_dash * dashAttack_speed)
end
Satoff.dashAttack = {name = "dashAttack", start = Satoff.dashAttack_start, exit = nop, update = Satoff.dashAttack_update, draw = Character.default_draw }

return Satoff