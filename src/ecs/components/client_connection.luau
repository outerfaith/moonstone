--!optimize 2

const jecs = require("@vendor/jecs")

const world = require("@moonstone/ecs/world")
const connection = require("@moonstone/network/connection")
const frame_buffer = require("@moonstone/network/frame_buffer")

type Id<T> = jecs.Id<T>
type Connection = connection.Connection
type FrameBuffer = frame_buffer.FrameBuffer

export type ClientConnection = {
    read connection: Connection,
    read frame_buf: FrameBuffer,
    read intent: number,
}

return world:component() :: Id<ClientConnection>

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
