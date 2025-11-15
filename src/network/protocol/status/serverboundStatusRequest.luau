--!optimize 2

local clientboundStatusResponse = require("./clientboundStatusResponse")
local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local networkType = require("../../networkType")

export type Data = nil

return table.freeze({
    networkType = networkType.unit(),
    handle = function(connection: sharedTypes.Connection)
        connection:sendPacket(clientboundStatusResponse, {
            version = {
                name = "1.21.10",
                protocol = 773,
            },
            players = {
                max = 670,
                online = 100,
                sample = {},
            },
            description = "ross is a very cool person",
            enforcesSecureChat = true,
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
