local class = require "lib/middleclass"
local Gopper = class('Gopper', Enemy)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Gopper:initialize(name, sprite, input, x, y, f)
    self.hp = 40
    self.score_bonus = 200
    self.tx, self.ty = x, y
    Enemy.initialize(self, name, sprite, input, x, y, f)
    self:pickAttackTarget()
    self.type = "enemy"
    self.subtype = "gopper"
    self.friendly_damage = 2 --divide friendly damage
    self.face = -1
    self.sfx.dead = sfx.gopper_death
    self.sfx.dash = sfx.gopper_attack
--    self.sfx.jump_attack =
    self.sfx.step = "kisa_step"

    self:setToughness(0)
    self.walk_speed = 80
    self.run_speed = 100
    self:setState(self.intro)
end

function Gopper:updateAI(dt)
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
            if self:getDistanceToClosestPlayer() < 100 then
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cool_down <= 0 then
                --can move
                local t = dist(self.target.x, self.target.y, self.x, self.y)
                if t < 400 and t >= 100 and
                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                    self:setState(self.run)
                    return
                end
                if t < 300 then
                    self:setState(self.walk)
                    return
                end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 400 and t >= 100
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4) then
                self:setState(self.run)
                return
            end
            if self.cool_down <= 0 then
                if math.abs(self.x - self.target.x) <= 50
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
        self:faceToTarget(x, y)
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

function Gopper:combo_start()
    self.isHittable = true
    self:remove_tween_move()
    if self.n_combo > 3 or self.n_combo < 1 then
        self.n_combo = 1
    end
    if self.n_combo == 1 then
        self:setSprite("combo1")
    elseif self.n_combo == 2 then
        self:setSprite("combo2")
    elseif self.n_combo == 3 then
        self:setSprite("combo3")
    end
    self.cool_down = 0.2
end

function Gopper:combo_update(dt)
    if self.sprite.isFinished then
        self.n_combo = self.n_combo + 1
        if self.n_combo > 4 then
            self.n_combo = 1
        end
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.combo = { name = "combo", start = Gopper.combo_start, exit = nop, update = Gopper.combo_update, draw = Gopper.default_draw }

function Gopper:dash_start()
    self.isHittable = true
    self:remove_tween_move()
    dpo(self, self.state)
    self:setSprite("dash")
    self.velx = self.velocity_dash
    self.vely = 0
    self.velz = 0
    sfx.play("voice" .. self.id, self.sfx.dash)
end

function Gopper:dash_update(dt)
    if self.sprite.isFinished then
        dpo(self, self.state)
        self:setState(self.stand)
        return
    end
    self:calcFriction(dt, self.friction_dash)
    self:checkCollisionAndMove(dt)
end

Gopper.dash = { name = "dash", start = Gopper.dash_start, exit = nop, update = Gopper.dash_update, draw = Character.default_draw }


--States: intro, Idle?, Walk, Combo, HurtHigh, HurtLow, Fall/KO
function Gopper:intro_start()
    self.isHittable = true
    self:setSprite("intro")
end

function Gopper:intro_update(dt)
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.intro = { name = "intro", start = Gopper.intro_start, exit = nop, update = Gopper.intro_update, draw = Enemy.default_draw }

function Gopper:stand_start()
    self.isHittable = true
    self.tx, self.ty = self.x, self.y
    self:setSprite("stand")
    self.victims = {}
    self.n_grabhit = 0

    --self:pickAttackTarget()
    --    self.tx, self.ty = self.x, self.y
end

function Gopper:stand_update(dt)
    if self.isGrabbed then
        self:setState(self.grabbed)
        return
    end
    self:calcFriction(dt)
    self:checkCollisionAndMove(dt)
end

Gopper.stand = { name = "stand", start = Gopper.stand_start, exit = nop, update = Gopper.stand_update, draw = Enemy.default_draw }

function Gopper:walk_start()
    self.isHittable = true
    self:setSprite("walk")
    self.can_jump = false
    self.can_attack = false
    local t = dist(self.target.x, self.target.y, self.x, self.y)
    if love.math.random() < 0.25 then
        --random move arond the player (far from)
        self.move = tween.new(1 + t / self.walk_speed, self, {
            tx = self.target.x + rand1() * love.math.random(70, 85),
            ty = self.target.y + rand1() * love.math.random(20, 35)
        }, 'inOutQuad')
    else
        if math.abs(self.x - self.target.x) <= 30
                and math.abs(self.y - self.target.y) <= 10
        then
            --step back(too close)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / self.walk_speed, self, {
                    tx = self.target.x - love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / self.walk_speed, self, {
                    tx = self.target.x + love.math.random(40, 60),
                    ty = self.target.y + love.math.random(-1, 1) * 20
                }, 'inOutQuad')
            end
        else
            --get to player(to fight)
            if self.x < self.target.x then
                self.move = tween.new(1 + t / self.walk_speed, self, {
                    tx = self.target.x - love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            else
                self.move = tween.new(1 + t / self.walk_speed, self, {
                    tx = self.target.x + love.math.random(25, 30),
                    ty = self.target.y + 1
                }, 'inOutQuad')
            end
        end
    end
end
function Gopper:walk_update(dt)
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
    self:checkCollisionAndMove(dt)
    self.can_jump = true
    self.can_attack = true
end
Gopper.walk = { name = "walk", start = Gopper.walk_start, exit = Unit.remove_tween_move, update = Gopper.walk_update, draw = Enemy.default_draw }

function Gopper:run_start()
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


    self.can_attack = false
end
function Gopper:run_update(dt)
    local complete
    if self.move then
        complete = self.move:update(dt)
    else
        complete = true
    end
    if complete then
        local t = dist(self.target.x, self.target.y, self.x, self.y)
        if t > 100 then
            self:setState(self.walk)
        else
            self:setState(self.dash)
        end
        return
    end
    self:checkCollisionAndMove(dt)
end
Gopper.run = {name = "run", start = Gopper.run_start, exit = Unit.remove_tween_move, update = Gopper.run_update, draw = Gopper.default_draw}

local dash_speed = 0.75
function Gopper:dash_start()
    self.isHittable = true
    self:setSprite("dash")
    self.velx = self.velocity_dash * 2 * dash_speed
    self.vely = 0
    self.velz = self.velocity_jump / 2 * dash_speed
    self.z = 0.1
    sfx.play("voice"..self.id, self.sfx.dash)
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
function Gopper:dash_update(dt)
    if self.sprite.isFinished then
        self:setState(self.stand)
        return
    end
    if self.z > 0 then
        self.z = self.z + dt * self.velz
        self.velz = self.velz - self.gravity * dt * dash_speed
    else
        self.velz = 0
        self.velx = 0
        self.z = 0
    end
    self:calcFriction(dt, self.friction_dash * dash_speed)
    self:checkCollisionAndMove(dt)
end
Gopper.dash = {name = "dash", start = Gopper.dash_start, exit = nop, update = Gopper.dash_update, draw = Character.default_draw }

return Gopper