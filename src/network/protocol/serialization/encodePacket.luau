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

    local payload = byteBuf.allocate(4096)

    networkType.VAR_INT:write(payload, id)
    pkt.networkType:write(payload, data)

    payload:flip()

    local payloadLen = payload.limit
    local lengthSize = getVarIntSize(payloadLen)
    local out = byteBuf.allocate(lengthSize + payloadLen)

    networkType.VAR_INT:write(out, payloadLen)
    buffer.copy(out._buffer, out.position, payload._buffer, 0, payloadLen)

    out.position = out.position + payloadLen
    out:flip()

    return out
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
