--!optimize 2
--!native

local test = require("@std/test")

local jecs = require("@vendor/jecs")

local identifier = require("@moonstone/resources/identifier")
local scheduler = require("@moonstone/ecs/systems/scheduler")

local function new_world()
    return jecs.world()
end

test.suite("Scheduler", function(suite)
    suite:case("creates schedulers and phases", function(asserts)
        local world = new_world()
        local phase_id = identifier.with_default_namespace("tick")
        local phase = scheduler.create_phase(phase_id)
        local ticker = scheduler.new(world)

        asserts.eq(world, ticker.world)
        asserts.eq({}, ticker.phases)
        asserts.eq(phase_id, phase.id)
        asserts.eq({}, phase.systems)
    end)

    suite:case("adds and finds phases by identifier value", function(asserts)
        local pre_id = identifier.with_default_namespace("pre")
        local tick_id = identifier.with_default_namespace("tick")
        local pre = scheduler.create_phase(pre_id)
        local tick = scheduler.create_phase(tick_id)
        local ticker = scheduler.new(new_world())

        asserts.eq(ticker, ticker:add_phase(pre))
        asserts.eq(ticker, ticker:add_phase(tick))
        asserts.eq({ pre, tick }, ticker.phases)

        asserts.eq(pre, ticker:get_phase(identifier.with_default_namespace("pre")))
        asserts.eq(tick, ticker:get_phase(identifier.with_default_namespace("tick")))
        asserts.eq(nil, ticker:get_phase(identifier.with_default_namespace("post")))
    end)

    suite:case("schedules systems into an existing phase", function(asserts)
        local phase_id = identifier.with_default_namespace("tick")
        local phase = scheduler.create_phase(phase_id)
        local ticker = scheduler.new(new_world()):add_phase(phase)

        local function first() end
        local function second() end

        asserts.eq(
            ticker,
            ticker:schedule_systems(identifier.with_default_namespace("tick"), first, second)
        )
        asserts.eq({ first, second }, phase.systems)
    end)

    suite:case("ticks systems in phase and system insertion order", function(asserts)
        local world = new_world()
        local ticker = scheduler.new(world)
        local pre_id = identifier.with_default_namespace("pre")
        local tick_id = identifier.with_default_namespace("tick")
        local calls = {}

        local function record(name: string)
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
        local world = new_world()
        local phase_id = identifier.with_default_namespace("initial")
        local called_with_world = false
        local called_with_tick_delta = 0

        local function initial_system(call_world, tick_delta)
            called_with_world = call_world == world
            called_with_tick_delta = tick_delta
        end

        local phase = scheduler.create_phase_with_systems(phase_id, { initial_system })
        local ticker = scheduler.new(world):add_phase(phase)

        asserts.eq({ initial_system }, phase.systems)

        ticker:tick(1 / 20)

        asserts.that(called_with_world)
        asserts.eq(1 / 20, called_with_tick_delta)
    end)

    suite:case("throws when scheduling into an unknown phase", function(asserts)
        local missing_id = identifier.with_default_namespace("missing")
        local ticker = scheduler.new(new_world())

        asserts.throwsWith(`'{missing_id}' is not a phase`, function()
            ticker:schedule_systems(missing_id, function() end)
        end)
    end)

    suite:case("does not allow systems to yield", function(asserts)
        local phase_id = identifier.with_default_namespace("tick")
        local ticker =
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
