--!optimize 2

local clientboundLoginFinished = require("./clientboundLoginFinished")
local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local networkType = require("../../networkType")

export type Data = {
    read name: string,
    read uuid: string,
}

return table.freeze({
    networkType = networkType.struct({
        -- TODO(outerfaith): limit to 3..16 characters
        { networkType.UNLIMITED_STRING, "name" },
        { networkType.UUID, "uuid" },
    }),
    handle = function(connection: sharedTypes.Connection, data: Data)
        -- TODO(outerfaith): encryption.. need to generate RSA keypair
        connection:sendPacket(clientboundLoginFinished, {
            uuid = data.uuid,
            username = data.name,
            properties = nil,
        })
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
