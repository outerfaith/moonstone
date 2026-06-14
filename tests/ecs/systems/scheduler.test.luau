--!optimize 2

const test = require("@std/test")

const jecs = require("@vendor/jecs")

const identifier = require("@moonstone/resources/identifier")
const scheduler = require("@moonstone/ecs/systems/scheduler")

const function new_world()
    return jecs.world()
end

test.suite("Scheduler", function(suite)
    suite:case("creates schedulers and phases", function(asserts)
        const world = new_world()
        const phase_id = identifier.with_default_namespace("tick")
        const phase = scheduler.create_phase(phase_id)
        const ticker = scheduler.new(world)

        asserts.eq(world, ticker.world)
        asserts.eq({}, ticker.phases)
        asserts.eq(phase_id, phase.id)
        asserts.eq({}, phase.systems)
    end)

    suite:case("adds and finds phases by identifier value", function(asserts)
        const pre_id = identifier.with_default_namespace("pre")
        const tick_id = identifier.with_default_namespace("tick")
        const pre = scheduler.create_phase(pre_id)
        const tick = scheduler.create_phase(tick_id)
        const ticker = scheduler.new(new_world())

        asserts.eq(ticker, ticker:add_phase(pre))
        asserts.eq(ticker, ticker:add_phase(tick))
        asserts.eq({ pre, tick }, ticker.phases)

        asserts.eq(pre, ticker:get_phase(identifier.with_default_namespace("pre")))
        asserts.eq(tick, ticker:get_phase(identifier.with_default_namespace("tick")))
        asserts.eq(nil, ticker:get_phase(identifier.with_default_namespace("post")))
    end)

    suite:case("schedules systems into an existing phase", function(asserts)
        const phase_id = identifier.with_default_namespace("tick")
        const phase = scheduler.create_phase(phase_id)
        const ticker = scheduler.new(new_world()):add_phase(phase)

        const function first() end
        const function second() end

        asserts.eq(
            ticker,
            ticker:schedule_systems(identifier.with_default_namespace("tick"), first, second)
        )
        asserts.eq({ first, second }, phase.systems)
    end)

    suite:case("ticks systems in phase and system insertion order", function(asserts)
        const world = new_world()
        const ticker = scheduler.new(world)
        const pre_id = identifier.with_default_namespace("pre")
        const tick_id = identifier.with_default_namespace("tick")
        const calls = {}

        const function record(name: string)
            return function(call_world, tick_delta)
                table.insert(calls, {
                    name = name,
                    world_matches = call_world == world,
                    tick_delta = tick_delta,
                })
            end
        end

        ticker
            :add_phase(scheduler.create_phase(pre_id))
            :add_phase(scheduler.create_phase(tick_id))
            :schedule_systems(tick_id, record("tick:first"), record("tick:second"))
            :schedule_systems(pre_id, record("pre:first"))

        ticker:tick(0.05)

        asserts.eq({
            { name = "pre:first", world_matches = true, tick_delta = 0.05 },
            { name = "tick:first", world_matches = true, tick_delta = 0.05 },
            { name = "tick:second", world_matches = true, tick_delta = 0.05 },
        }, calls)
    end)

    suite:case("supports phases created with initial systems", function(asserts)
        const world = new_world()
        const phase_id = identifier.with_default_namespace("initial")
        local called_with_world = false
        local called_with_tick_delta = 0

        const function initial_system(call_world, tick_delta)
            called_with_world = call_world == world
            called_with_tick_delta = tick_delta
        end

        const phase = scheduler.create_phase_with_systems(phase_id, { initial_system })
        const ticker = scheduler.new(world):add_phase(phase)

        asserts.eq({ initial_system }, phase.systems)

        ticker:tick(1 / 20)

        asserts.that(called_with_world)
        asserts.eq(1 / 20, called_with_tick_delta)
    end)

    suite:case("throws when scheduling into an unknown phase", function(asserts)
        const missing_id = identifier.with_default_namespace("missing")
        const ticker = scheduler.new(new_world())

        asserts.throwsWith(`'{missing_id}' is not a phase`, function()
            ticker:schedule_systems(missing_id, function() end)
        end)
    end)

    suite:case("does not allow systems to yield", function(asserts)
        const phase_id = identifier.with_default_namespace("tick")
        const ticker =
            scheduler.new(new_world()):add_phase(scheduler.create_phase_with_systems(phase_id, {
                function()
                    coroutine.yield()
                end,
            }))

        asserts.throws(function()
            ticker:tick(0)
        end)
    end)
end)

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
