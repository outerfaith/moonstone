--!optimize 2

local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local clientboundGameEvent = require("../play/clientboundGameEvent")
local clientboundLoginPacket = require("../play/clientboundLoginPacket")
local networkType = require("../../networkType")
local enum = require("../../../util/enum")
local identifier = require("../../../util/identifier")

export type Data = nil

return table.freeze({
    networkType = networkType.unit(),
    handle = function(connection: sharedTypes.Connection, data: Data)
        -- TODO(outerfaith): handle packet
        print("client acknowledged configuration finish")
        connection.intent = enum.intent.PLAY
        connection:sendPacket(clientboundLoginPacket, {
            entityId = 1,
            hardcore = false,
            dimensions = { identifier.withDefaultNamespace("overworld") },
            maxPlayers = 1,
            viewDistance = 16,
            simulationDistance = 16,
            reducedDebugInfo = false,
            enableRespawnScreen = false,
            doLimitedCrafting = false,
            dimensionType = 0,
            dimensionName = identifier.withDefaultNamespace("overworld"),
            seedHash = 0,
            gameMode = 0,
            previousGameMode = -1,
            isDebugWorld = false,
            isFlat = true,
            hasDeathLocation = false,
            portalCooldown = 0,
            seaLevel = 64,
            enforcesSecureChat = true,
        })
        connection:sendPacket(clientboundGameEvent, {
            event = 13,
            value = 0,
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
