--!optimize 2

local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local networkType = require("../../networkType")
local identifier = require("../../../util/identifier")

export type Data = {
    read key: identifier.Identifier,
    read data: buffer,
}

return table.freeze({
    networkType = networkType.struct({
        { networkType.IDENTIFIER, "key" },
        { networkType.TERMINATING_BYTE_ARRAY, "data" },
    }),
    handle = function(connection: sharedTypes.Connection, data: Data)
        -- TODO(outerfaith): handle plugin messages
        -- handler only exists right now so the configuration process can be completed
        -- the vanilla client sends one plugin message during config phase (minecraft:brand) and we need to respond with the server brand info
        -- i think modded clients also send plugin messages that contain a list of the mods they expect
        print(`recieved plugin message '{data.key}'`)
    end,
}) :: packet.ServerboundPacket<Data>

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
