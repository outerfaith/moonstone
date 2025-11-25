--!optimize 2

local clientboundFinishConfiguration = require("./clientboundFinishConfiguration")
local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local networkType = require("../../networkType")
local knownPack = require("../../../resources/knownPack")

export type Data = {
    read packs: { knownPack.KnownPack },
}

return table.freeze({
    networkType = networkType.struct({
        { networkType.array(knownPack.NETWORK_TYPE), "packs" },
    }),
    handle = function(connection: sharedTypes.Connection, data: Data)
        -- TODO(outerfaith): handle packet
        print("recieved client known packs, finishing configuration")
        connection:sendPacket(clientboundFinishConfiguration)
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
