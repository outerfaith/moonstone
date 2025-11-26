--!optimize 2
--!strict

local net = zune.net
local task = zune.task

local jecs = require("@pkg/jecs")
local scheduler = require("./scheduler")
local world = require("./world")
local connection = require("./network/protocol/connection")
local player = require("./components/player")
local logger = require("./util/logger")

local TICK_INTERVAL = 1 / 20

local log = logger.new("Main coroutine")
local ticker = scheduler.new(world, log)

local socket = net.createSocket(
    net.ADDRF.INET,
    bit32.bor(net.SOCKF.STREAM, net.SOCKF.CLOEXEC, net.SOCKF.NONBLOCK),
    net.IPPROTO.TCP
)

socket:setOption(net.SOCKOPTLV.SOCKET, net.SOCKOPT.REUSEADDR, true)
if net.SOCKOPT.REUSEPORT then
    socket:setOption(net.SOCKOPTLV.SOCKET, net.SOCKOPT.REUSEPORT, true)
end
socket:bindIp("127.0.0.1", 25565)
socket:listen()

task.spawn(function()
    while socket:isOpen() do
        local incoming = socket:accept()
        local conn = connection.new(incoming)
        world:set(world:entity(), player, {
            connection = conn,
        })
        task.spawn(function()
            while conn._socket:isOpen() do
                -- TODO(outerfaith): once all packets are implemented, this
                -- shouldn't be a pcall
                pcall(function()
                    conn:processPackets()
                end)
            end
        end)
        task.wait()
    end
end)

local function flushConnections(world: jecs.World)
    for entity, player in world:query(player) do
        player.connection:flush()
    end
end

ticker
    :addPhase(scheduler.createPhaseWithSystems("preTick", {}))
    :addPhase(scheduler.createPhaseWithSystems("tick", {}))
    :addPhase(scheduler.createPhaseWithSystems("postTick", { flushConnections }))

local accumulated = 0
local lastTick = os.clock()

while true do
    local start = os.clock()
    local dt = start - lastTick

    lastTick = start
    accumulated += dt

    while accumulated >= TICK_INTERVAL do
        ticker:tick(TICK_INTERVAL)
        accumulated -= TICK_INTERVAL
    end

    local finish = os.clock()
    local sleep = TICK_INTERVAL - (finish - start)

    if sleep > 0 then
        task.wait(sleep)
    else
        log:warn(string.format("Tick took longer than expected: %.3fs", finish - start))
    end
end

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
