--!optimize 2
--!native

local byteBuf = require("../../../util/byteBuf")
local packet = require("../packet")
local networkType = require("../../networkType")

local function getVarIntSize(value: number): number
    local size = 0
    local v = value

    repeat
        v = bit32.rshift(v, 7)
        size += 1
    until v == 0

    return size
end

local function encodePacket<T>(pkt: packet.Packet<T>, data: T, id: number): byteBuf.ByteBuf
    assert(id >= 0, "id must be non-negative")

    local buf = byteBuf.allocate(8192)
    local lengthIndex = buf.position

    buf:skip(3)
    networkType.VAR_INT:write(buf, id)
    pkt.networkType:write(buf, data)

    local payloadLength = buf.position - (lengthIndex + 3)
    local lengthBytes = getVarIntSize(payloadLength)

    if lengthBytes ~= 3 then
        local delta = lengthBytes - 3
        local payloadStart = lengthIndex + 3
        local payloadLength1 = buf.position - payloadStart

        buf:shift(payloadStart, payloadLength1, delta)
        buf:setPosition(buf.position + delta)
    end

    networkType.VAR_INT:writeAtOffset(buf, lengthIndex, payloadLength)
    buf:flip()

    return buf
end

return encodePacket

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
