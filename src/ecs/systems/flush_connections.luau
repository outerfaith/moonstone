--!optimize 2

const task = require("@std/task")

const jecs = require("@vendor/jecs")

const client_connection = require("@moonstone/ecs/components/client_connection")

type World = jecs.World

const function flush_connections(world: World, tick_delta: number)
    const clients = world:query(client_connection)

    task.spawn(function()
        for idx, client in clients:iter() do
            client.connection:flush()
        end
    end)
end

return flush_connections

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
