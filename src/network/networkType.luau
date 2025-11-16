--!optimize 2
--!native

local jsonOps = zune.serde.json

local byteBuf = require("../util/byteBuf")

export type NetworkType<T> = {
    read: (self: NetworkType<T>, buf: byteBuf.ByteBuf) -> T,
    write: (self: NetworkType<T>, buf: byteBuf.ByteBuf, value: T) -> (),
    writeAtOffset: (self: NetworkType<T>, buf: byteBuf.ByteBuf, offset: number, value: T) -> (),
}

local function simple<T>(
    read: (buf: byteBuf.ByteBuf) -> T,
    write: (buf: byteBuf.ByteBuf, value: T) -> ()
): NetworkType<T>
    local instance = {} :: NetworkType<T>

    function instance.read(self: NetworkType<T>, buf: byteBuf.ByteBuf): T
        return read(buf)
    end

    function instance.write(self: NetworkType<T>, buf: byteBuf.ByteBuf, value: T)
        write(buf, value)
    end

    function instance.writeAtOffset(
        self: NetworkType<T>,
        buf: byteBuf.ByteBuf,
        offset: number,
        value: T
    )
        local pos = buf.position

        buf:setPosition(offset)
        write(buf, value)
        buf:setPosition(pos)
    end

    return table.freeze(instance) :: NetworkType<T>
end

local BOOLEAN = simple(function(buf: byteBuf.ByteBuf)
    return buf:readByte() ~= 0
end, function(buf: byteBuf.ByteBuf, val: boolean)
    buf:putByte(val and 1 or 0)
end)

local BYTE = simple(function(buf: byteBuf.ByteBuf)
    return buf:readByte()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putByte(val)
end)

local UNSIGNED_BYTE = simple(function(buf: byteBuf.ByteBuf)
    return buf:readUnsignedByte()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putUnsignedByte(val)
end)

local SHORT = simple(function(buf: byteBuf.ByteBuf)
    return buf:readShort()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putShort(val)
end)

local UNSIGNED_SHORT = simple(function(buf: byteBuf.ByteBuf)
    return buf:readUnsignedShort()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putUnsignedShort(val)
end)

local INT = simple(function(buf: byteBuf.ByteBuf)
    return buf:readInt()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putInt(val)
end)

local LONG = simple(function(buf: byteBuf.ByteBuf)
    return buf:readLong()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putLong(val)
end)

local FLOAT = simple(function(buf: byteBuf.ByteBuf)
    return buf:readFloat()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putFloat(val)
end)

local DOUBLE = simple(function(buf: byteBuf.ByteBuf)
    return buf:readDouble()
end, function(buf: byteBuf.ByteBuf, val: number)
    buf:putDouble(val)
end)

local VAR_INT = simple(function(buf: byteBuf.ByteBuf)
    local result = 0
    local shift = 0

    while true do
        local byte = buf:readUnsignedByte()
        local value = bit32.band(byte, 0x7F)

        result = bit32.bor(result, bit32.lshift(value, shift))

        if bit32.band(byte, 0x80) == 0 then
            break
        end

        shift = shift + 7
        if shift > 28 then
            error("VarInt too big")
        end
    end

    return result
end, function(buf: byteBuf.ByteBuf, val: number)
    local v = val

    while true do
        if bit32.band(v, bit32.bnot(0x7F)) == 0 then
            buf:putByte(v)
            break
        end

        buf:putByte(bit32.bor(bit32.band(v, 0x7F), 0x80))
        v = bit32.rshift(v, 7)
    end
end)

local VAR_LONG = simple(function(buf: byteBuf.ByteBuf)
    local result = 0
    local shift = 0

    while true do
        local byte = buf:readUnsignedByte()
        local value = bit32.band(byte, 0x7F)

        result = bit32.bor(result, bit32.lshift(value, shift))

        if bit32.band(byte, 0x80) == 0 then
            break
        end

        shift = shift + 7
        if shift > 63 then
            error("VarLong too big")
        end
    end

    return result
end, function(buf: byteBuf.ByteBuf, val: number)
    local v = val

    while true do
        if bit32.band(v, bit32.bnot(0x7F)) == 0 then
            buf:putByte(v)
            break
        end

        buf:putByte(bit32.bor(bit32.band(v, 0x7F), 0x80))
        v = bit32.rshift(v, 7)
    end
end)

local function limitedString(maxLength: number)
    assert(maxLength >= 1, "maxLength must be >= 1")
    assert(maxLength <= 32767, "maxLength must be <= 32767")

    return simple(function(buf: byteBuf.ByteBuf)
        local maxBytes = maxLength * 4
        local len = VAR_INT:read(buf)

        assert(len >= 0, "Encoded string length is negative")
        assert(len <= maxBytes, `String too long ({len} bytes > {maxBytes} bytes)`)
        assert(
            buf.position + len <= buf:getCapacity(),
            `Not enough bytes in buffer (expected {len}, got {buf:getCapacity() - buf.position})`
        )

        local str = buf:readString(len)

        assert(
            (utf8.len(str) and (utf8.len(str) :: number) <= maxLength),
            `Decoded string too long ({utf8.len(str)} chars > {maxLength} chars)`
        )

        return str
    end, function(buf: byteBuf.ByteBuf, val: string)
        local charLen = utf8.len(val)
        local byteLen = string.len(val)
        local maxBytes = maxLength * 4

        assert(
            charLen and charLen <= maxLength,
            `String too long ({charLen} chars > {maxLength} chars)`
        )
        assert(
            byteLen <= maxBytes,
            `Encoded string too large ({byteLen} bytes > {maxLength} bytes)`
        )

        VAR_INT:write(buf, byteLen)
        buf:putString(val)
    end)
end

local UNLIMITED_STRING = limitedString(32767)

local BYTE_ARRAY = simple(function(buf: byteBuf.ByteBuf)
    local length = VAR_INT:read(buf)
    local bytes = buf:readBytes(length)

    return bytes
end, function(buf: byteBuf.ByteBuf, val: buffer)
    if val == nil then
        VAR_INT:write(buf, 0)
        return
    end

    VAR_INT:write(buf, buffer.len(val))
    buf:putBytes(val)
end)

local UUID = simple(function(buf: byteBuf.ByteBuf)
    local bytes = {}
    for i = 1, 16 do
        bytes[i] = buf:readUnsignedByte()
    end

    local hex = {}
    for i = 1, 16 do
        hex[#hex + 1] = string.format("%02x", bytes[i])
    end

    local s = table.concat(hex)

    return string.format(
        "%s-%s-%s-%s-%s",
        s:sub(1, 8),
        s:sub(9, 12),
        s:sub(13, 16),
        s:sub(17, 20),
        s:sub(21, 32)
    )
end, function(buf: byteBuf.ByteBuf, value: string)
    local hex = value:gsub("-", ""):lower()

    for i = 1, 32, 2 do
        local byteHex = hex:sub(i, i + 1)
        local byte = tonumber(byteHex, 16)

        buf:putUnsignedByte(byte)
    end
end)

local function json<T>(): NetworkType<T>
    return simple(function(buf: byteBuf.ByteBuf)
        local json = UNLIMITED_STRING:read(buf)
        return jsonOps.decode(json)
    end, function(buf: byteBuf.ByteBuf, value: T)
        local json = jsonOps.encode(value)
        UNLIMITED_STRING:write(buf, json)
    end)
end

local function struct<T>(types: { { string | NetworkType<any> } })
    return simple(function(buf: byteBuf.ByteBuf)
        local ret = {}
        for idx, entry in ipairs(types) do
            local name, type = entry[2] :: string, entry[1] :: NetworkType<any>

            local read = type:read(buf)
            assert(ret[name] == nil, `'{name}' has already been read`)
            ret[name] = read
        end
        return ret :: T
    end, function(buf: byteBuf.ByteBuf, toWrite: T)
        for idx, entry in ipairs(types) do
            local name, type = entry[2] :: string, entry[1] :: NetworkType<any>

            local value = (toWrite :: any)[name]
            type:write(buf, value)
        end
    end)
end

local function unit<T>()
    return simple(function()
        return nil :: T
    end, function() end)
end

return table.freeze({
    BOOLEAN = BOOLEAN,
    BYTE = BYTE,
    UNSIGNED_BYTE = UNSIGNED_BYTE,
    SHORT = SHORT,
    UNSIGNED_SHORT = UNSIGNED_SHORT,
    INT = INT,
    LONG = LONG,
    FLOAT = FLOAT,
    DOUBLE = DOUBLE,
    VAR_INT = VAR_INT,
    VAR_LONG = VAR_LONG,
    limitedString = limitedString,
    UNLIMITED_STRING = UNLIMITED_STRING,
    BYTE_ARRAY = BYTE_ARRAY,
    UUID = UUID,
    json = json,
    struct = struct,
    unit = unit,
})

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
