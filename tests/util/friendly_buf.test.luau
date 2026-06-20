--!optimize 2
--!native

const test = require("@std/test")

const friendly_buf = require("@moonstone/util/friendly_buf")

const function read_all_bytes(buf: buffer): { number }
    const bytes = {}

    for i = 0, buffer.len(buf) - 1 do
        table.insert(bytes, buffer.readu8(buf, i))
    end

    return bytes
end

test.suite("FriendlyBuf", function(suite)
    suite:case("allocate and wrap initialize cursor state", function(asserts)
        const allocated = friendly_buf.allocate(4)

        asserts.eq(4, buffer.len(allocated._buffer))
        asserts.eq(0, allocated.position)
        asserts.eq(4, allocated.limit)

        const raw = buffer.create(3)
        buffer.writeu8(raw, 0, 0xAA)

        const wrapped = friendly_buf.wrap(raw)
        asserts.eq(raw, wrapped._buffer)
        asserts.eq(0, wrapped.position)
        asserts.eq(3, wrapped.limit)
        asserts.eq(0xAA, wrapped:get_u8())
    end)

    suite:case("round-trips 8-bit integers", function(asserts)
        const bytes = friendly_buf.allocate(4)

        bytes:write_u8(0xAB)
        bytes:write_i8(-2)
        bytes:write_u8(0)
        bytes:write_i8(127)

        asserts.eq(4, bytes.position)
        asserts.eq({ 0xAB, 0xFE, 0x00, 0x7F }, read_all_bytes(bytes._buffer))

        bytes.position = 0

        asserts.eq(0xAB, bytes:get_u8())
        asserts.eq(-2, bytes:get_i8())
        asserts.eq(0, bytes:get_u8())
        asserts.eq(127, bytes:get_i8())
        asserts.eq(4, bytes.position)
    end)

    suite:case("round-trips 16-bit integers", function(asserts)
        const bytes = friendly_buf.allocate(8)

        bytes:write_u16(0xC0DE)
        bytes:write_i16(-12345)
        bytes:write_u16(0)
        bytes:write_i16(-0x8000)

        asserts.eq(8, bytes.position)
        asserts.eq(
            { 0xC0, 0xDE, 0xCF, 0xC7, 0x00, 0x00, 0x80, 0x00 },
            read_all_bytes(bytes._buffer)
        )

        bytes.position = 0

        asserts.eq(0xC0DE, bytes:get_u16())
        asserts.eq(-12345, bytes:get_i16())
        asserts.eq(0, bytes:get_u16())
        asserts.eq(-0x8000, bytes:get_i16())
        asserts.eq(8, bytes.position)
    end)

    suite:case("round-trips 24-bit integers", function(asserts)
        const bytes = friendly_buf.allocate(12)

        bytes:write_u24(0x123456)
        bytes:write_i24(-1)
        bytes:write_u24(0)
        bytes:write_i24(-0x800000)

        asserts.eq(12, bytes.position)
        asserts.eq({
            0x12,
            0x34,
            0x56,
            0xFF,
            0xFF,
            0xFF,
            0x00,
            0x00,
            0x00,
            0x80,
            0x00,
            0x00,
        }, read_all_bytes(bytes._buffer))

        bytes.position = 0

        asserts.eq(0x123456, bytes:get_u24())
        asserts.eq(-1, bytes:get_i24())
        asserts.eq(0, bytes:get_u24())
        asserts.eq(-0x800000, bytes:get_i24())
        asserts.eq(12, bytes.position)
    end)

    suite:case("round-trips 32-bit integers", function(asserts)
        const bytes = friendly_buf.allocate(16)

        bytes:write_u32(0xDEADBEEF)
        bytes:write_i32(-123456789)
        bytes:write_u32(0)
        bytes:write_i32(-0x80000000)

        asserts.eq(16, bytes.position)
        asserts.eq({
            0xDE,
            0xAD,
            0xBE,
            0xEF,
            0xF8,
            0xA4,
            0x32,
            0xEB,
            0x00,
            0x00,
            0x00,
            0x00,
            0x80,
            0x00,
            0x00,
            0x00,
        }, read_all_bytes(bytes._buffer))

        bytes.position = 0

        asserts.eq(0xDEADBEEF, bytes:get_u32())
        asserts.eq(-123456789, bytes:get_i32())
        asserts.eq(0, bytes:get_u32())
        asserts.eq(-0x80000000, bytes:get_i32())
        asserts.eq(16, bytes.position)
    end)

    suite:case("round-trips 64-bit integers", function(asserts)
        const bytes = friendly_buf.allocate(16)
        const positive = integer.create(2 ^ 52)
        const negative = integer.create(-1)

        bytes:write_i64(positive)
        bytes:write_i64(negative)

        asserts.eq(16, bytes.position)
        asserts.eq({
            0x00,
            0x10,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
        }, read_all_bytes(bytes._buffer))

        bytes.position = 0

        asserts.eq(positive, bytes:get_i64())
        asserts.eq(negative, bytes:get_i64())
        asserts.eq(16, bytes.position)
    end)

    suite:case("round-trips floating point values", function(asserts)
        const bytes = friendly_buf.allocate(24)

        bytes:write_f32(123.5)
        bytes:write_f32(-0.25)
        bytes:write_f64(math.pi)
        bytes:write_f64(-1.0 / 3.0)

        asserts.eq(24, bytes.position)

        bytes.position = 0

        asserts.eq(123.5, bytes:get_f32())
        asserts.eq(-0.25, bytes:get_f32())
        asserts.eq(math.pi, bytes:get_f64())
        asserts.eq(-1.0 / 3.0, bytes:get_f64())
        asserts.eq(24, bytes.position)
    end)

    suite:case("round-trips strings and slices", function(asserts)
        const bytes = friendly_buf.allocate(16)
        const raw_slice = buffer.create(3)

        buffer.writeu8(raw_slice, 0, 0x11)
        buffer.writeu8(raw_slice, 1, 0x22)
        buffer.writeu8(raw_slice, 2, 0x33)

        const friendly_slice = friendly_buf.allocate(4)
        friendly_slice:write_string("tail")

        bytes:write_string("moon")
        bytes:write_slice(raw_slice)
        bytes:write_string("stone")
        bytes:write_slice(friendly_slice)

        asserts.eq(16, bytes.position)
        asserts.eq({
            0x6D,
            0x6F,
            0x6F,
            0x6E,
            0x11,
            0x22,
            0x33,
            0x73,
            0x74,
            0x6F,
            0x6E,
            0x65,
            0x74,
            0x61,
            0x69,
            0x6C,
        }, read_all_bytes(bytes._buffer))

        bytes.position = 0

        asserts.eq("moon", bytes:get_string(4))

        const slice = bytes:get_slice(3)
        asserts.eq(0, slice.position)
        asserts.eq(3, slice.limit)
        asserts.eq({ 0x11, 0x22, 0x33 }, read_all_bytes(slice._buffer))

        asserts.eq("stone", bytes:get_string(5))
        asserts.eq("tail", bytes:get_string(4))
        asserts.eq(16, bytes.position)
    end)

    suite:case("extends without reallocating when capacity is available", function(asserts)
        const bytes = friendly_buf.allocate(6)
        const original_buffer = bytes._buffer
        const raw = buffer.create(2)

        buffer.writeu8(raw, 0, 0xCC)
        buffer.writeu8(raw, 1, 0xDD)

        bytes:write_u8(0xAA)
        bytes:write_u8(0xBB)
        bytes:extend(raw)

        asserts.eq(original_buffer, bytes._buffer)
        asserts.eq(4, bytes.position)
        asserts.eq(6, bytes.limit)
        asserts.eq({ 0xAA, 0xBB, 0xCC, 0xDD, 0x00, 0x00 }, read_all_bytes(bytes._buffer))
    end)

    suite:case("extends by growing to the next power of two", function(asserts)
        const bytes = friendly_buf.allocate(4)
        const raw = buffer.create(3)

        buffer.writeu8(raw, 0, 0x04)
        buffer.writeu8(raw, 1, 0x05)
        buffer.writeu8(raw, 2, 0x06)

        bytes:write_u8(0x01)
        bytes:write_u8(0x02)
        bytes:write_u8(0x03)
        bytes:extend(raw)

        asserts.eq(6, bytes.position)
        asserts.eq(8, bytes.limit)
        asserts.eq({ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x00, 0x00 }, read_all_bytes(bytes._buffer))
    end)

    suite:case("extends from friendly buffers", function(asserts)
        const bytes = friendly_buf.allocate(2)
        const source = friendly_buf.allocate(3)

        source:write_u8(0x11)
        source:write_u8(0x22)
        source:write_u8(0x33)

        bytes:write_u8(0xAA)
        bytes:extend(source)

        asserts.eq(4, bytes.limit)
        asserts.eq(4, bytes.position)
        asserts.eq({ 0xAA, 0x11, 0x22, 0x33 }, read_all_bytes(bytes._buffer))
        asserts.eq(3, source.position)
    end)

    suite:case("compacts unread bytes to the beginning", function(asserts)
        const bytes = friendly_buf.allocate(6)

        bytes:write_u8(0x01)
        bytes:write_u8(0x02)
        bytes:write_u8(0x03)
        bytes:write_u8(0x04)
        bytes:write_u8(0x05)
        bytes:write_u8(0x06)

        bytes.position = 2
        bytes:compact()

        asserts.eq(0, bytes.position)
        asserts.eq(4, bytes.limit)
        asserts.eq({ 0x03, 0x04, 0x05, 0x06 }, read_all_bytes(bytes._buffer))
        asserts.eq(0x03, bytes:get_u8())
        asserts.eq(0x04, bytes:get_u8())
    end)

    suite:case("compact clears fully consumed buffers without reallocating", function(asserts)
        const bytes = friendly_buf.allocate(4)
        const original_buffer = bytes._buffer

        bytes:write_u8(0xAA)
        bytes:write_u8(0xBB)
        bytes:write_u8(0xCC)
        bytes:write_u8(0xDD)

        bytes:compact()

        asserts.eq(original_buffer, bytes._buffer)
        asserts.eq(0, bytes.position)
        asserts.eq(4, bytes.limit)
        asserts.eq({ 0x00, 0x00, 0x00, 0x00 }, read_all_bytes(bytes._buffer))
    end)

    suite:case("compact is a no-op at the beginning of the buffer", function(asserts)
        const bytes = friendly_buf.allocate(3)
        const original_buffer = bytes._buffer

        bytes:write_u8(0xAA)
        bytes:write_u8(0xBB)
        bytes.position = 0

        bytes:compact()

        asserts.eq(original_buffer, bytes._buffer)
        asserts.eq(0, bytes.position)
        asserts.eq(3, bytes.limit)
        asserts.eq({ 0xAA, 0xBB, 0x00 }, read_all_bytes(bytes._buffer))
    end)

    suite:case("throws when reads and writes exceed limits", function(asserts)
        const bytes = friendly_buf.allocate(1)

        bytes:write_u8(1)

        asserts.throwsWith("attempt to write past limit", function()
            bytes:write_u8(2)
        end)

        bytes.position = 0

        asserts.eq(1, bytes:get_u8())

        asserts.throwsWith("attempt to read past limit", function()
            bytes:get_u8()
        end)

        asserts.throwsWith("length must be positive", function()
            bytes:get_slice(-1)
        end)
    end)
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
