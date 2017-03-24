-- enemy batch / spawning que

local class = require "lib/middleclass"
local Batch = class('Batch')

--[[
{
    delay = seconds,
    left_stopper =
    right_stopper =
    units = {
        { unit = ,
          spawned = false
        }
    }
]]
function Batch:ps(t)
    print("BATCH #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Batch:initialize(stage, batches)
    self.stage = stage
    self.time = 0
    self.n = 1 --1st batch
    self.batches = batches
    print("Stage has #",#batches,"batches of enemy")
    --self.objects = {}
    --self.units = {}
    if self:load() then
        self.state = "spawn"
        -- left_stopper, right_stopper
    else
        self.state = "done"
    end
end

function Batch:load()
    local n = self.n
    if n > #self.batches then
        return false
    end
    print("load Batch #",n)
    local b = self.batches[n]
    self.left_stopper = b.left_stopper or 0
    self.right_stopper = b.right_stopper or 320

    --self.delay = b.delay or 0
    for i = 1, #b.units do
        local u = b.units[i]
        u.isSpawned = false
        --print("units in batch:",u.unit.name)
    end
    return true
end

function Batch:spawn(dt)
    local b = self.batches[self.n]
    if self.time < b.delay then --delay before the whole batch
        return false
    end

    -- left_stopper, right_stopper
    --move?
    --self:ps(" unitss #"..#b.units)
    local x1, x2 = self.stage.left_stopper.x, self.stage.right_stopper.x
--    self.left_stopper = b.left_stopper or 0
--    self.right_stopper = b.right_stopper or 320

    if x1 < self.left_stopper then
        x1 = x1 + dt * 200
    end
    if x2 < self.right_stopper then
        x2 = x2 + dt * 200
    end
    self.stage:moveStoppers(x1, x2)

    local all_spawned = true
    local all_dead = true
    for i = 1, #b.units do
        local u = b.units[i]
        if not u.isSpawned then
            if self.time - b.delay >= u.delay then --delay before the unit's spawn
                --TODO spawn
                print("spawn ", u.unit.name, u.unit.type, u.unit.hp, self.time)
                --add to stage / bump
                --self:ps(" enSpawn Unit #"..i)
                self.stage.objects:add(u.unit)
                u.isSpawned = true
                if u.state == "stand" then
                    u.unit:setState(u.unit.stand)
                end
            end
            all_spawned = false
            all_dead = false --not yet spawned = alive
        else
            if u.unit.hp > 0 and u.unit.type == "enemy" then --alive enemy
                all_dead = false
            end
        end
    end
    if all_spawned then
        --??
    end
    if all_dead then
        self.state = "next"
        self.time = 0
    end
    --print("all spawned", all_spawned, "all dead", all_dead)
    return true
end

function Batch:update(dt)
    self.time = self.time + dt
--    self:ps()
    if self.state == "spawn" then
        self:spawn(dt)
        return
    elseif self.state == "next" then
--        self:ps()
        self.n = self.n + 1
        if self:load() then
            self.state = "spawn"
            self.time = 0
            self:ps()
        else
            self.state = "done"
            self.time = 0
            self:ps()
        end
        return
    elseif self.state == "done" then
--        self:ps()
        return
    end
end

return Batch