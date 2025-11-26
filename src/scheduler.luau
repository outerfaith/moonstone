--!optimize 2
--!native
--!strict

local jecs = require("@pkg/jecs")
local logger = require("./util/logger")
local noYield = require("./util/noYield")

local scheduler = {}
scheduler.__index = scheduler

export type System = (world: jecs.World, logger: logger.Logger, tick: number) -> ()

export type Phase = {
    id: string,
    systems: { System },
}

export type Scheduler = typeof(setmetatable(
    {} :: {
        read world: jecs.World,
        read logger: logger.Logger,
        read phases: { Phase },
    },
    scheduler
))

function scheduler.new(world: jecs.World, logger: logger.Logger): Scheduler
    return table.freeze(setmetatable({
        world = world,
        logger = logger,
        phases = {},
    }, scheduler))
end

function scheduler.createPhase(id: string): Phase
    return scheduler.createPhaseWithSystems(id, {})
end

function scheduler.createPhaseWithSystems(id: string, systems: { System }): Phase
    return {
        id = id,
        systems = systems,
    }
end

function scheduler.addPhase(self: Scheduler, phase: Phase): Scheduler
    table.insert(self.phases, phase)
    return self
end

function scheduler.getPhase(self: Scheduler, id: string): Phase?
    for idx, phase in self.phases do
        if phase.id == id then
            return phase
        end
    end
    return nil
end

function scheduler.scheduleSystems(self: Scheduler, id: string, systems: { System }): Scheduler
    local phase = self:getPhase(id)
    assert(phase ~= nil, "A phase with this id has not been registered")

    for idx, system in ipairs(systems) do
        table.insert(phase.systems, system)
    end

    return self
end

function scheduler.tick(self: Scheduler, dt: number)
    for idx, phase in ipairs(self.phases) do
        for idx, system in ipairs(phase.systems) do
            noYield(system, self.world, self.logger, dt)
        end
    end
end

return scheduler

--[[
   Copyright 2025 Outerfaith
                  Contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]
