--!optimize 2

-- TODO(outerfaith): move this logic into a seperate file
-- this file should only handle argument parsing and then instantiate whatever
-- handles this logic

const task = require("@std/task")
const net = require("@lute/net")

const world = require("@moonstone/ecs/world")
const client_connection = require("@moonstone/ecs/components/client_connection")
const scheduler = require("@moonstone/ecs/systems/scheduler")
const connection = require("@moonstone/network/connection")
const frame_buffer = require("@moonstone/network/frame_buffer")
const packet_coding = require("@moonstone/network/protocol/packet_coding")
const packet_registry = require("@moonstone/network/protocol/packet_registry")
const identifier = require("@moonstone/resources/identifier")
const enum = require("@moonstone/util/enum")
const logger = require("@moonstone/util/logger")

const TICK_INTERVAL = 1 / 20

const log = logger.new("Main coroutine")
const ticker = scheduler.new(world)

ticker
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("pre"), {}))
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("tick"), {}))
    :add_phase(scheduler.create_phase_with_systems(identifier.with_default_namespace("post"), {}))

net.server.listen({
    port = 25565,
    onconnection = function(stream, server)
        const conn = connection.new(stream)
        const entity = world:entity()

        world:set(entity, client_connection, {
            connection = conn,
            frame_buf = frame_buffer.new(),
            intent = enum.CONNECTION_INTENT.HANDSHAKE,
        })

        -- TODO(outerfaith): replace whatever the hell this is with something else
        task.spawn(function()
            while true do
                const ok, err = pcall(function()
                    const client = assert(world:get(entity, client_connection), "unreachable")
                    const recv = conn:read()

                    client.frame_buf:append(recv)

                    const frame = client.frame_buf:read_frame_or_nil()
                    if frame == nil then
                        return
                    end

                    const registry =
                        packet_registry.get(enum.PACKET_FLOW.SERVERBOUND, client.intent)
                    const type, data = packet_coding.decode(frame, registry)

                    -- TODO(outerfaith): packets should be stored in a queue, then
                    -- handlers should be no-yield invoked pre-tick
                    registry:get_handler().handler_for(type)(data, entity)
                end)

                if not ok then
                    conn:close(false)
                    world:delete(entity)
                    log:error(err :: string)
                    break
                end
            end
        end)
    end,
})

local accumulated = 0
local last_tick = os.clock()

while true do
    const start = os.clock()
    const delta = start - last_tick

    last_tick = start
    accumulated += delta

    while accumulated >= TICK_INTERVAL do
        ticker:tick(TICK_INTERVAL)
        accumulated -= TICK_INTERVAL
    end

    const finish = os.clock()
    const sleep = TICK_INTERVAL - (finish - start)

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
