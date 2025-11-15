--!optimize 2
--!native

local mem = zune.mem

local INT_MAX_SIZE = 2 ^ 32

local BYTE_SIZE_BYTES = 1

local SHORT_SIZE_BYTES = BYTE_SIZE_BYTES * 2
local INT_SIZE_BYTES = SHORT_SIZE_BYTES * 2
local LONG_SIZE_BYTES = INT_SIZE_BYTES * 2

local FLOAT_SIZE_BYTES = INT_SIZE_BYTES
local DOUBLE_SIZE_BYTES = LONG_SIZE_BYTES

type ByteBufProto = {
    __index: ByteBufProto,
    setPosition: (self: ByteBuf, pos: number) -> number,
    setLimit: (self: ByteBuf, limit: number) -> (),
    getCapacity: (self: ByteBuf) -> number,
    clear: (self: ByteBuf) -> (),
    flip: (self: ByteBuf) -> (),
    rewind: (self: ByteBuf) -> (),
    getRemaining: (self: ByteBuf) -> number,
    hasRemaining: (self: ByteBuf) -> boolean,
    compact: (self: ByteBuf) -> (),
    slice: (self: ByteBuf) -> ByteBuf,
    copy: (self: ByteBuf) -> ByteBuf,
    skip: (self: ByteBuf, bytes: number) -> (),
    shift: (self: ByteBuf, start: number, length: number, delta: number) -> (),
    readByte: (self: ByteBuf) -> number,
    readUnsignedByte: (self: ByteBuf) -> number,
    readBytes: (self: ByteBuf, length: number) -> buffer,
    readShort: (self: ByteBuf) -> number,
    readUnsignedShort: (self: ByteBuf) -> number,
    readInt: (self: ByteBuf) -> number,
    readUnsignedInt: (self: ByteBuf) -> number,
    readLong: (self: ByteBuf) -> number,
    readFloat: (self: ByteBuf) -> number,
    readDouble: (self: ByteBuf) -> number,
    putByte: (self: ByteBuf, value: number) -> (),
    putUnsignedByte: (self: ByteBuf, value: number) -> (),
    putBytes: (self: ByteBuf, bytes: buffer) -> (),
    putShort: (self: ByteBuf, value: number) -> (),
    putUnsignedShort: (self: ByteBuf, value: number) -> (),
    putInt: (self: ByteBuf, value: number) -> (),
    putUnsignedInt: (self: ByteBuf, value: number) -> (),
    putLong: (self: ByteBuf, value: number) -> (),
    putFloat: (self: ByteBuf, value: number) -> (),
    putDouble: (self: ByteBuf, value: number) -> (),
}

export type ByteBuf = setmetatable<{
    _buffer: buffer,
    position: number,
    limit: number,
}, ByteBufProto>

local byteBuf = {} :: ByteBufProto
byteBuf.__index = byteBuf

function byteBuf.setPosition(self, pos)
    local current = self.position

    self.position = pos
    return current
end

function byteBuf.setLimit(self, limit)
    assert(limit >= 0, "limit must be non-negative")
    assert(limit <= self:getCapacity(), "limit cannot exceed buffer size")

    self.limit = limit
    if self.position >= limit then
        self.position = limit
    end
end

function byteBuf.getCapacity(self)
    return buffer.len(self._buffer)
end

function byteBuf.clear(self)
    buffer.fill(self._buffer, 0, 0)
    self.position = 0
    self.limit = self:getCapacity()
end

function byteBuf.flip(self)
    self.limit = self.position
    self.position = 0
end

function byteBuf.rewind(self)
    self.position = 0
end

function byteBuf.getRemaining(self)
    return self.limit - self.position
end

function byteBuf.hasRemaining(self)
    return self.position < self.limit
end

function byteBuf.compact(self)
    local remaining = self:getRemaining()

    if remaining > 0 then
        local compacted = buffer.create(remaining)
        buffer.copy(compacted, 0, self._buffer, self.position, remaining)

        self._buffer = compacted
    end

    self.position = remaining
    self.limit = remaining
end

function byteBuf.slice(self)
    local slice = mem.slice(self._buffer, self.position)

    return setmetatable({
        _buffer = slice,
        position = 0,
        limit = buffer.len(slice),
    }, byteBuf)
end

function byteBuf.copy(self)
    local copy = buffer.create(self:getCapacity())
    buffer.copy(copy, 0, self._buffer, 0)

    return setmetatable({
        _buffer = copy,
        position = 0,
        limit = self:getCapacity(),
    }, byteBuf)
end

function byteBuf.skip(self, bytes)
    assert(self.position + bytes <= self.limit, "attempt to skip past limit")
    self.position += bytes
end

function byteBuf:shift(start, length, delta)
    assert(start >= 0, "start must be >= 0")
    assert(length >= 0, "length must be >= 0")
    assert(start + length <= self:getCapacity(), "start + length exceeds buffer capacity")

    if delta == 0 then
        return
    end

    local temp = {}
    for i = 0, length - 1 do
        temp[i + 1] = buffer.readu8(self._buffer, start + i)
    end

    if delta > 0 then
        for i = length, 1, -1 do
            buffer.writeu8(self._buffer, start + i - 1 + delta, temp[i])
        end
    else
        for i = 1, length do
            buffer.writeu8(self._buffer, start + i - 1 + delta, temp[i])
        end
    end
end

function byteBuf.readByte(self)
    assert(self.position + BYTE_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += BYTE_SIZE_BYTES
    return buffer.readi8(self._buffer, self.position - BYTE_SIZE_BYTES)
end

function byteBuf.readUnsignedByte(self)
    assert(self.position + BYTE_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += BYTE_SIZE_BYTES
    return buffer.readu8(self._buffer, self.position - BYTE_SIZE_BYTES)
end

function byteBuf.readBytes(self, length)
    assert(self.position + length <= self.limit, "attempt to read past limit")

    local read = buffer.create(length)

    self.position += length

    buffer.copy(read, 0, self._buffer, self.position, length)
    return read
end

function byteBuf.readShort(self)
    assert(self.position + SHORT_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += SHORT_SIZE_BYTES
    return buffer.readi16(self._buffer, self.position - SHORT_SIZE_BYTES)
end

function byteBuf.readUnsignedShort(self)
    assert(self.position + SHORT_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += SHORT_SIZE_BYTES
    return buffer.readu16(self._buffer, self.position - SHORT_SIZE_BYTES)
end

function byteBuf.readInt(self)
    assert(self.position + INT_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += INT_SIZE_BYTES
    return buffer.readi32(self._buffer, self.position - INT_SIZE_BYTES)
end

function byteBuf.readUnsignedInt(self)
    assert(self.position + INT_MAX_SIZE <= self.limit, "attempt to read past limit")

    self.position += INT_SIZE_BYTES
    return buffer.readu32(self._buffer, self.position - INT_SIZE_BYTES)
end

function byteBuf.readLong(self)
    assert(self.position + LONG_SIZE_BYTES <= self.limit, "attempt to read past limit")

    local read = 0
    for i = 1, LONG_SIZE_BYTES do
        read = bit32.bor(bit32.lshift(read, 8), self:readUnsignedByte())
    end

    return read
end

function byteBuf.readFloat(self)
    assert(self.position + FLOAT_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += FLOAT_SIZE_BYTES
    return buffer.readf32(self._buffer, self.position - FLOAT_SIZE_BYTES)
end

function byteBuf.readDouble(self)
    assert(self.position + DOUBLE_SIZE_BYTES <= self.limit, "attempt to read past limit")

    self.position += DOUBLE_SIZE_BYTES
    return buffer.readf64(self._buffer, self.position - DOUBLE_SIZE_BYTES)
end

function byteBuf.putByte(self, value)
    assert(self.position + BYTE_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += BYTE_SIZE_BYTES
    buffer.writei8(self._buffer, self.position - BYTE_SIZE_BYTES, value)
end

function byteBuf.putUnsignedByte(self, value)
    assert(self.position + BYTE_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += BYTE_SIZE_BYTES
    buffer.writeu8(self._buffer, self.position - BYTE_SIZE_BYTES, value)
end

function byteBuf.putBytes(self, bytes)
    local length = buffer.len(bytes)

    assert(self.position + length <= self.limit, "attempt to write past limit")

    self.position += length
    buffer.copy(self._buffer, self.position, bytes, length)
end

function byteBuf.putShort(self, value)
    assert(self.position + SHORT_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += SHORT_SIZE_BYTES
    buffer.writei16(self._buffer, self.position - SHORT_SIZE_BYTES, value)
end

function byteBuf.putUnsignedShort(self, value)
    assert(self.position + SHORT_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += SHORT_SIZE_BYTES
    buffer.writeu16(self._buffer, self.position - SHORT_SIZE_BYTES, value)
end

function byteBuf.putInt(self, value)
    assert(self.position + INT_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += INT_SIZE_BYTES
    buffer.writei32(self._buffer, self.position - INT_SIZE_BYTES, value)
end

function byteBuf.putUnsignedInt(self, value)
    assert(self.position + INT_MAX_SIZE <= self.limit, "attempt to write past limit")

    self.position += INT_SIZE_BYTES
    buffer.writeu32(self._buffer, self.position - INT_SIZE_BYTES, value)
end

function byteBuf.putLong(self, value)
    assert(self.position + LONG_SIZE_BYTES <= self.limit, "attempt to write past limit")

    local high = math.floor(value / INT_MAX_SIZE)
    local low = value % INT_MAX_SIZE

    for i = 3, 0, -1 do
        self:putUnsignedByte(bit32.rshift(high, i * LONG_SIZE_BYTES) % 256)
    end
    for i = 3, 0, -1 do
        self:putUnsignedByte(bit32.lshift(low, i * LONG_SIZE_BYTES) % 256)
    end
end

function byteBuf.putFloat(self, value)
    assert(self.position + FLOAT_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += FLOAT_SIZE_BYTES
    buffer.writef32(self._buffer, self.position - FLOAT_SIZE_BYTES, value)
end

function byteBuf.putDouble(self, value)
    assert(self.position + DOUBLE_SIZE_BYTES <= self.limit, "attempt to write past limit")

    self.position += DOUBLE_SIZE_BYTES
    buffer.writef64(self._buffer, self.position - DOUBLE_SIZE_BYTES, value)
end

local function wrap(buf: buffer): ByteBuf
    return setmetatable({
        _buffer = buf,
        position = 0,
        limit = buffer.len(buf),
    }, byteBuf)
end

local function allocate(size: number): ByteBuf
    return wrap(buffer.create(size))
end

return table.freeze({
    wrap = wrap,
    allocate = allocate,
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
