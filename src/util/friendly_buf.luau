--!optimize 2
--!native

const assertions = require("@moonstone/util/assertions")

type FriendlyBufProto = {
    __index: FriendlyBufProto,
    get_remaining: (self: FriendlyBuf) -> number,
    get_u8: (self: FriendlyBuf) -> number,
    get_i8: (self: FriendlyBuf) -> number,
    get_u16: (self: FriendlyBuf) -> number,
    get_i16: (self: FriendlyBuf) -> number,
    get_u24: (self: FriendlyBuf) -> number,
    get_i24: (self: FriendlyBuf) -> number,
    get_u32: (self: FriendlyBuf) -> number,
    get_i32: (self: FriendlyBuf) -> number,
    get_f32: (self: FriendlyBuf) -> number,
    get_f64: (self: FriendlyBuf) -> number,
    get_i64: (self: FriendlyBuf) -> integer,
    get_string: (self: FriendlyBuf, length: number) -> string,
    get_slice: (self: FriendlyBuf, length: number) -> FriendlyBuf,
    write_u8: (self: FriendlyBuf, value: number) -> (),
    write_i8: (self: FriendlyBuf, value: number) -> (),
    write_u16: (self: FriendlyBuf, value: number) -> (),
    write_i16: (self: FriendlyBuf, value: number) -> (),
    write_u24: (self: FriendlyBuf, value: number) -> (),
    write_i24: (self: FriendlyBuf, value: number) -> (),
    write_u32: (self: FriendlyBuf, value: number) -> (),
    write_i32: (self: FriendlyBuf, value: number) -> (),
    write_f32: (self: FriendlyBuf, value: number) -> (),
    write_f64: (self: FriendlyBuf, value: number) -> (),
    write_i64: (self: FriendlyBuf, value: integer) -> (),
    write_string: (self: FriendlyBuf, value: string) -> (),
    write_slice: (self: FriendlyBuf, slice: FriendlyBuf | buffer) -> (),
}

export type FriendlyBuf = setmetatable<{
    read _buffer: buffer,
    position: number,
    limit: number,
}, FriendlyBufProto>

const friendly_buf = {} :: FriendlyBufProto
friendly_buf.__index = friendly_buf

const function wrap(buf: buffer): FriendlyBuf
    return setmetatable({
        _buffer = buf,
        position = 0,
        limit = buffer.len(buf),
    }, friendly_buf)
end

const function allocate(size: number): FriendlyBuf
    return wrap(buffer.create(size))
end

const function read_int16(buf: FriendlyBuf, signed: boolean?): number
    assert(buf.position + 2 <= buf.limit, "attempt to read past limit")

    const high = buf:get_u8()
    const low = buf:get_u8()

    local res = high * 256 + low
    if (res >= 0x8000) and signed then
        res -= 0x10000
    end

    return res
end

const function read_int24(buf: FriendlyBuf, signed: boolean?): number
    assert(buf.position + 3 <= buf.limit, "attempt to read past limit")

    const a = buf:get_u8()
    const b = buf:get_u8()
    const c = buf:get_u8()

    local res = a * 65536 + b * 256 + c
    if (res >= 0x800000) and signed then
        res -= 0x1000000
    end

    return res
end

const function read_int32(buf: FriendlyBuf, signed: boolean?): number
    assert(buf.position + 4 <= buf.limit, "attempt to read past limit")

    const a = buf:get_u8()
    const b = buf:get_u8()
    const c = buf:get_u8()
    const d = buf:get_u8()

    local res = a * 16777216 + b * 65536 + c * 256 + d
    if (res >= 0x80000000) and signed then
        res -= 0x100000000
    end

    return res
end

const function read_reversed(buf: FriendlyBuf, size: number): buffer
    assert(buf.position + size <= buf.limit, "attempt to read past limit")

    const out = buffer.create(size)
    for i = size - 1, 0, -1 do
        buffer.writeu8(out, i, buf:get_u8())
    end

    return out
end

const function write_int16(buf: FriendlyBuf, value: number, signed: boolean?)
    assert(buf.position + 2 <= buf.limit, "attempt to write past limit")

    if signed and (value < 0) then
        value += 0x10000
    end

    buf:write_u8(math.floor(value / 256))
    buf:write_u8(value % 256)
end

const function write_int24(buf: FriendlyBuf, value: number, signed: boolean?)
    assert(buf.position + 3 <= buf.limit, "attempt to write past limit")

    if signed and (value < 0) then
        value += 0x1000000
    end

    buf:write_u8(math.floor(value / 65536))
    buf:write_u8(math.floor(value / 256) % 256)
    buf:write_u8(value % 256)
end

const function write_int32(buf: FriendlyBuf, value: number, signed: boolean?)
    assert(buf.position + 4 <= buf.limit, "attempt to write past limit")

    if signed and (value < 0) then
        value += 0x100000000
    end

    buf:write_u8(math.floor(value / 16777216))
    buf:write_u8(math.floor(value / 65536) % 256)
    buf:write_u8(math.floor(value / 256) % 256)
    buf:write_u8(value % 256)
end

const function write_reversed(buf: FriendlyBuf, value: buffer)
    const length = buffer.len(value)
    assert(buf.position + length <= buf.limit, "attempt to write past limit")

    for i = 0, length - 1 do
        buf:write_u8(buffer.readu8(value, length - 1 - i))
    end
end

const function swap_u32(n: number): number
    return bit32.bor(
        bit32.lshift(bit32.band(n, 0xFF), 24),
        bit32.lshift(bit32.band(n, 0xFF00), 8),
        bit32.rshift(bit32.band(n, 0xFF0000), 8),
        bit32.rshift(n, 24)
    )
end

function friendly_buf.get_remaining(self)
    return self.limit - self.position
end

function friendly_buf.get_u8(self)
    assert(self.position + 1 <= self.limit, "attempt to read past limit")

    self.position += 1
    return buffer.readu8(self._buffer, self.position - 1)
end

function friendly_buf.get_i8(self)
    assert(self.position + 1 <= self.limit, "attempt to read past limit")

    self.position += 1
    return buffer.readi8(self._buffer, self.position - 1)
end

function friendly_buf.get_u16(self)
    return read_int16(self)
end

function friendly_buf.get_i16(self)
    return read_int16(self, true)
end

function friendly_buf.get_u32(self)
    return read_int32(self)
end

function friendly_buf.get_u24(self)
    return read_int24(self)
end

function friendly_buf.get_i24(self)
    return read_int24(self, true)
end

function friendly_buf.get_i32(self)
    return read_int32(self, true)
end

function friendly_buf.get_f32(self)
    return buffer.readf32(read_reversed(self, 4), 0)
end

function friendly_buf.get_f64(self)
    return buffer.readf64(read_reversed(self, 8), 0)
end

function friendly_buf.get_i64(self)
    assert(self.position + 8 <= self.limit, "attempt to read past limit")

    const high = integer.create(swap_u32(buffer.readu32(self._buffer, self.position)))
    const low = integer.create(swap_u32(buffer.readu32(self._buffer, self.position + 4)))

    self.position += 8

    return integer.bor(integer.lshift(high, integer.create(32)), low)
end

function friendly_buf.get_string(self, length)
    assert(self.position + length <= self.limit, "attempt to read past limit")

    self.position += length
    return buffer.readstring(self._buffer, self.position - length, length)
end

function friendly_buf.get_slice(self, length)
    assert(length >= 0, "length must be positive")
    assert(self.position + length <= self.limit, "attempt to read past limit")

    const slice = buffer.create(length)
    buffer.copy(slice, 0, self._buffer, self.position, length)

    self.position += length

    return wrap(slice)
end

function friendly_buf.write_u8(self, value)
    assert(self.position + 1 <= self.limit, "attempt to write past limit")

    buffer.writeu8(self._buffer, self.position, assertions.is_u8(value))
    self.position += 1
end

function friendly_buf.write_i8(self, value)
    assert(self.position + 1 <= self.limit, "attempt to write past limit")

    buffer.writei8(self._buffer, self.position, assertions.is_i8(value))
    self.position += 1
end

function friendly_buf.write_u16(self, value)
    write_int16(self, assertions.is_u16(value))
end

function friendly_buf.write_i16(self, value)
    write_int16(self, assertions.is_i16(value), true)
end

function friendly_buf.write_u24(self, value)
    write_int24(self, assertions.is_u24(value))
end

function friendly_buf.write_i24(self, value)
    write_int24(self, assertions.is_i24(value), true)
end

function friendly_buf.write_u32(self, value)
    write_int32(self, assertions.is_u32(value))
end

function friendly_buf.write_i32(self, value)
    write_int32(self, assertions.is_i32(value), true)
end

function friendly_buf.write_f32(self, value)
    const temp = buffer.create(4)
    buffer.writef32(temp, 0, assertions.is_f32(value))

    write_reversed(self, temp)
end

function friendly_buf.write_f64(self, value)
    const temp = buffer.create(8)
    buffer.writef64(temp, 0, assertions.is_f64(value))

    write_reversed(self, temp)
end

function friendly_buf.write_i64(self, value)
    assert(self.position + 8 <= self.limit, "attempt to write past limit")

    const mask = integer.create(0xFFFFFFFF)

    const high = integer.band(integer.rshift(value, integer.create(32)), mask)
    const low = integer.band(value, mask)

    write_int32(self, integer.tonumber(high))
    write_int32(self, integer.tonumber(low))
end

function friendly_buf.write_string(self, value)
    const length = string.len(value)

    assert(self.position + length <= self.limit, "attempt to write past limit")

    buffer.writestring(self._buffer, self.position, value)
    self.position += length
end

function friendly_buf.write_slice(self, slice)
    const src = if type(slice) == "buffer" then slice else slice._buffer
    const length = buffer.len(src)

    assert(self.position + length <= self.limit, "attempt to write past limit")

    buffer.copy(self._buffer, self.position, src, 0, length)
    self.position += length
end

return table.freeze({
    wrap = wrap,
    allocate = allocate,
})

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
