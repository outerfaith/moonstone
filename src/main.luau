--!optimize 2

-- TODO(outerfaith): move this logic into a seperate file
-- this file should only handle argument parsing and then instantiate whatever
-- handles this logic

local task = require("@std/task")
local net = require("@lute/net")

local world = require("@moonstone/ecs/world")
local scheduler = require("@moonstone/ecs/systems/scheduler")
local identifier = require("@moonstone/resources/identifier")
local logger = require("@moonstone/util/logger")

local TICK_INTERVAL = 1 / 20

local log = logger.new("Main coroutine")
local ticker = scheduler.new(world)

ticker
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("pre"), {}))
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("tick"), {}))
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("post"), {}))

net.server.listen({
    port = 25565,
    onconnection = function(stream, server)
        error("not yet implemented")
    end,
})

local accumulated = 0
local last_tick = os.clock()

while true do
    local start = os.clock()
    local delta = start - last_tick

    last_tick = start
    accumulated += delta

    while accumulated >= TICK_INTERVAL do
        ticker:tick(TICK_INTERVAL)
        accumulated -= TICK_INTERVAL
    end

    local finish = os.clock()
    local sleep = TICK_INTERVAL - (finish - start)

    if sleep > 0 then
        task.wait(sleep)
    else
        log:warn(`Tick took longer than expected: {string.format("%.3fs", finish - start)}`)
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
