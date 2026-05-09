--!optimize 2

local jecs = require("@vendor/jecs")

local server = require("@moonstone/ecs/components/server")
local scheduler = require("@moonstone/ecs/systems/scheduler")
local logger = require("@moonstone/util/logger")

local log = logger.new("Connection manager")

local function accept_new_connections(world: jecs.World)
    local _, server_instance = world:query(server):iter()()
    local tcp_server = server_instance.tcp_server

    local connection = tcp_server:accept()

    if connection ~= nil then
        -- TODO(outerfaith): handle new connection
        -- most logic can be ported from the pre-26.1 branch
        log:debug(`New connection from {connection.remote_ip}:{connection.remote_port}`)
    end
end

return table.freeze({
    accept_new_connections = accept_new_connections :: scheduler.System,
})

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
