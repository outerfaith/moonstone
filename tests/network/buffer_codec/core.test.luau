--!optimize 2
--!native

const test = require("@std/test")

const buffer_codec = require("@moonstone/network/buffer_codec")
const codecs = require("@moonstone/network/buffer_codec/helper")
const friendly_buf = require("@moonstone/util/friendly_buf")

const helpers = require("./helpers")

test.suite("BufferCodec core", function(suite)
    suite:case("creates codecs from reader and writer functions", function(asserts)
        const codec = buffer_codec.new(function(buf)
            return buf:get_u8() + 1
        end, function(buf, value: number)
            buf:write_u8(value - 1)
        end)

        asserts.eq({ 0x2A }, helpers.write_to_bytes(1, codec, 0x2B))
        asserts.eq(0x2B, codec:read(helpers.buf_from_bytes({ 0x2A })))
    end)

    suite:case("read_at_offset restores the original cursor", function(asserts)
        const buf = helpers.buf_from_bytes({ 0x01, 0x02, 0x03 })

        buf.position = 1

        asserts.eq(0x03, codecs.UNSIGNED_BYTE:read_at_offset(buf, 2))
        asserts.eq(1, buf.position)
        asserts.eq(0x02, codecs.UNSIGNED_BYTE:read(buf))
        asserts.eq(2, buf.position)
    end)

    suite:case("write_at_offset restores the original cursor", function(asserts)
        const buf = helpers.buf_from_bytes({ 0x00, 0x00, 0x00 })

        buf.position = 3
        codecs.UNSIGNED_BYTE:write_at_offset(buf, 0xAB, 1)

        asserts.eq(3, buf.position)
        asserts.eq({ 0x00, 0xAB, 0x00 }, helpers.all_bytes(buf))
    end)

    suite:case("optional codecs encode presence markers", function(asserts)
        const optional = codecs.INT:as_optional()
        const buf = friendly_buf.allocate(10)

        optional:write(buf, nil)
        optional:write(buf, 0x12345678)

        asserts.eq({ 0x00, 0x01, 0x12, 0x34, 0x56, 0x78 }, helpers.written_bytes(buf))

        buf.position = 0

        asserts.eq(nil, optional:read(buf))
        asserts.eq(0x12345678, optional:read(buf))
        asserts.eq(6, buf.position)
    end)

    suite:case("optional offset methods preserve the original cursor", function(asserts)
        const optional = codecs.UNSIGNED_BYTE:as_optional()
        const buf = helpers.buf_from_bytes({ 0x00, 0x01, 0xFE, 0x00 })

        buf.position = 4

        asserts.eq(0xFE, optional:read_at_offset(buf, 1))
        asserts.eq(4, buf.position)

        optional:write_at_offset(buf, nil, 0)
        optional:write_at_offset(buf, 0x7F, 1)

        asserts.eq(4, buf.position)
        asserts.eq({ 0x00, 0x01, 0x7F, 0x00 }, helpers.all_bytes(buf))
    end)

    suite:case("unit codec reads nil and writes no bytes", function(asserts)
        const unit = codecs.unit()
        const buf = friendly_buf.allocate(1)

        unit:write(buf, nil)

        asserts.eq(0, buf.position)
        asserts.eq(nil, unit:read(buf))
        asserts.eq(0, buf.position)
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
