--!optimize 2

const jecs = require("@vendor/jecs")

const identifier = require("@moonstone/resources/identifier")
const no_yield = require("@moonstone/util/no_yield")

export type System = (world: jecs.World, tick_delta: number) -> ()

export type Phase = {
    read id: identifier.Identifier,
    read systems: { System },
}

type SchedulerProto = {
    __index: SchedulerProto,
    add_phase: (self: Scheduler, phase: Phase) -> Scheduler,
    get_phase: (self: Scheduler, id: identifier.Identifier) -> Phase?,
    schedule_systems: (
        self: Scheduler,
        phase_id: identifier.Identifier,
        ...System
    ) -> Scheduler,
    tick: (self: Scheduler, tick_delta: number) -> (),
}

export type Scheduler = setmetatable<{
    read world: jecs.World,
    read phases: { Phase },
}, SchedulerProto>

const scheduler = {} :: SchedulerProto
scheduler.__index = scheduler

export function new(world: jecs.World): Scheduler
    return table.freeze(setmetatable({
        world = world,
        phases = {},
    }, scheduler))
end

export function create_phase_with_systems(id: identifier.Identifier, systems: { System }): Phase
    return table.freeze({
        id = id,
        systems = systems,
    })
end

export function create_phase(id: identifier.Identifier): Phase
    return create_phase_with_systems(id, {})
end

function scheduler.add_phase(self: Scheduler, phase)
    table.insert(self.phases, phase)
    return self
end

function scheduler.get_phase(self: Scheduler, id)
    for iter_idx, phase in self.phases do
        if phase.id == id then
            return phase :: Phase?
        end
    end

    return nil
end

function scheduler.schedule_systems(self: Scheduler, phase_id, ...: System)
    const systems = table.freeze({ ... })
    const phase = assert(self:get_phase(phase_id), `'{phase_id}' is not a phase`)

    for iter_idx, system in ipairs(systems) do
        table.insert(phase.systems, system)
    end

    return self
end

function scheduler.tick(self: Scheduler, tick_delta)
    for iter_idx, phase in ipairs(self.phases) do
        for phase_iter_idx, system in ipairs(phase.systems) do
            no_yield(system, self.world, tick_delta)
        end
    end
end

--[[
   Copyright 2025-2026 Outerfaith
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
