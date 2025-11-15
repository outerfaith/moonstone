--!optimize 2
--!native

local byteBuf = require("../../../util/byteBuf")
local packet = require("../packet")
local packetRegistry = require("../packetRegistry")
local networkType = require("../../networkType")

local function decodePacket<T>(
    buf: byteBuf.ByteBuf,
    registry: packetRegistry.PacketRegistry
): (packet.ServerboundPacket<T>, T)
    -- TODO(outerfaith): consume and check packet length

    local id = networkType.VAR_INT:read(buf)
    local type = registry:get(id)

    return type :: packet.ServerboundPacket<T>, type.networkType:read(buf)
end

return decodePacket

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
