--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec")

export const VAR_INT = buffer_codec.new<<number>>(function(buf)
    local result = 0
    local shift = 0

    while true do
        const byte = buf:get_u8()
        const value = bit32.band(byte, 0x7F)

        result = bit32.bor(result, bit32.lshift(value, shift))
        if bit32.band(byte, 0x80) == 0 then
            break
        end

        shift += 7
        assert(shift <= 28, "VarInt is too big")
    end

    return result
end, function(buf, value)
    local remaining = value

    while bit32.band(remaining, bit32.bnot(0x7F)) ~= 0 do
        buf:write_u8(bit32.bor(bit32.band(remaining, 0x7F), 0x80))
        remaining = bit32.rshift(remaining, 7)
    end
    buf:write_u8(remaining)
end)

export const VAR_LONG = buffer_codec.new<<integer>>(function(buf)
    local result = 0i
    local shift = 0

    while true do
        const byte = buf:get_u8()
        const value = bit32.band(byte, 0x7F)

        result = integer.bor(result, integer.lshift(integer.create(value), integer.create(shift)))
        if bit32.band(byte, 0x80) == 0 then
            break
        end

        shift += 7
        assert(shift <= 63, "VarLong is too big")
    end

    return result
end, function(buf, value)
    local remaining = value

    while integer.band(remaining, integer.bnot(0x7Fi)) ~= 0i do
        buf:write_u8(integer.tonumber(integer.bor(integer.band(remaining, 0x7Fi), 0x80i)))
        remaining = integer.rshift(remaining, 7i)
    end
    buf:write_u8(integer.tonumber(remaining))
end)

--[[
   Copyright 2025-2026 Outerfaith
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
