--!optimize 2

local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local networkType = require("../../networkType")

export type Data = {
    read locale: string,
    read viewDistance: number,
    read chatMode: number,
    read chatColors: boolean,
    read displayedSkinParts: number,
    read mainHand: number,
    read enableTextFiltering: boolean,
    read allowServerListings: boolean,
    read particleStatus: number,
}

return table.freeze({
    networkType = networkType.struct({
        { networkType.limitedString(16), "locale" },
        { networkType.BYTE, "viewDistance" },
        { networkType.VAR_INT, "chatMode" },
        { networkType.BOOLEAN, "chatColors" },
        { networkType.UNSIGNED_BYTE, "displayedSkinParts" },
        { networkType.VAR_INT, "mainHand" },
        { networkType.BOOLEAN, "enableTextFiltering" },
        { networkType.BOOLEAN, "allowServerListings" },
        { networkType.VAR_INT, "particleStatus" },
    }),
    handle = function(connection: sharedTypes.Connection, data: Data)
        -- TODO(outerfaith): store all of this somewhere
        print("recieved client information")
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
