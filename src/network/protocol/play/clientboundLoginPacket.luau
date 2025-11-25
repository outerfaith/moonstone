--!optimize 2

local packet = require("../packet")
local networkType = require("../../networkType")
local identifier = require("../../../util/identifier")

export type Data = {
    read entityId: number,
    read hardcore: boolean,
    read dimensions: { identifier.Identifier },
    read maxPlayers: number,
    read viewDistance: number,
    read simulationDistance: number,
    read reducedDebugInfo: boolean,
    read enableRespawnScreen: boolean,
    read doLimitedCrafting: boolean,
    read dimensionType: number,
    read dimensionName: identifier.Identifier,
    read seedHash: number,
    read gameMode: number,
    read previousGameMode: number,
    read isDebugWorld: boolean,
    read isFlat: boolean,
    read hasDeathLocation: boolean,
    -- TODO(outerfaith): proper optional type for these
    read deathDimensionName: nil,
    read deathDimensionLocation: nil,
    read portalCooldown: number,
    read seaLevel: number,
    read enforcesSecureChat: boolean,
}

return table.freeze({
    networkType = networkType.struct({
        { networkType.INT, "entityId" },
        { networkType.BOOLEAN, "hardcore" },
        { networkType.array(networkType.IDENTIFIER), "dimensions" },
        { networkType.VAR_INT, "maxPlayers" },
        { networkType.VAR_INT, "viewDistance" },
        { networkType.VAR_INT, "simulationDistance" },
        { networkType.BOOLEAN, "reducedDebugInfo" },
        { networkType.BOOLEAN, "enableRespawnScreen" },
        { networkType.BOOLEAN, "doLimitedCrafting" },
        { networkType.VAR_INT, "dimensionType" },
        { networkType.IDENTIFIER, "dimensionName" },
        { networkType.LONG, "seedHash" },
        { networkType.UNSIGNED_BYTE, "gameMode" },
        { networkType.BYTE, "previousGameMode" },
        { networkType.BOOLEAN, "isDebugWorld" },
        { networkType.BOOLEAN, "isFlat" },
        { networkType.BOOLEAN, "hasDeathLocation" },
        { networkType.VAR_INT, "portalCooldown" },
        { networkType.VAR_INT, "seaLevel" },
        { networkType.BOOLEAN, "enforcesSecureChat" },
    }),
}) :: packet.Packet<Data>

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
