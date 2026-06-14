--!optimize 2
--!native

const test = require("@std/test")

const tags = require("@moonstone/nbt/tags")
const byte_ops = require("@moonstone/nbt/tag_ops/byte")
const short_ops = require("@moonstone/nbt/tag_ops/short")
const int_ops = require("@moonstone/nbt/tag_ops/int")
const long_ops = require("@moonstone/nbt/tag_ops/long")
const float_ops = require("@moonstone/nbt/tag_ops/float")
const double_ops = require("@moonstone/nbt/tag_ops/double")
const string_ops = require("@moonstone/nbt/tag_ops/string")
const friendly_buf = require("@moonstone/util/friendly_buf")

const helpers = require("../helpers")

const function write_to_bytes(size: number, tag: any, ops: any)
    const buf = friendly_buf.allocate(size)
    ops.write(tag, buf)
    return helpers.written_bytes(buf)
end

test.suite("NBT scalar tag ops", function(suite)
    suite:case("round-trips byte payloads", function(asserts)
        asserts.eq({ 0xFE }, write_to_bytes(1, tags.byte(-2), byte_ops))

        const tag = byte_ops.read(helpers.buf_from_bytes({ 0xFE })):unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_BYTE, -2)

        asserts.throwsWith("not a byte tag", function()
            byte_ops.write(tags.short(1) :: any, friendly_buf.allocate(2))
        end)
    end)

    suite:case("round-trips short payloads", function(asserts)
        asserts.eq({ 0xCF, 0xC7 }, write_to_bytes(2, tags.short(-12345), short_ops))

        const tag = short_ops.read(helpers.buf_from_bytes({ 0xCF, 0xC7 })):unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_SHORT, -12345)

        asserts.throwsWith("not a short tag", function()
            short_ops.write(tags.int(1) :: any, friendly_buf.allocate(4))
        end)
    end)

    suite:case("round-trips int payloads", function(asserts)
        asserts.eq({ 0xF8, 0xA4, 0x32, 0xEB }, write_to_bytes(4, tags.int(-123456789), int_ops))

        const tag = int_ops.read(helpers.buf_from_bytes({ 0xF8, 0xA4, 0x32, 0xEB })):unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_INT, -123456789)

        asserts.throwsWith("not an int tag", function()
            int_ops.write(tags.short(1) :: any, friendly_buf.allocate(4))
        end)
    end)

    suite:case("round-trips long payloads", function(asserts)
        const value = integer.create(2 ^ 52)

        asserts.eq(
            { 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
            write_to_bytes(8, tags.long(value), long_ops)
        )

        const tag = long_ops
            .read(helpers.buf_from_bytes({ 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_LONG, value)

        asserts.throwsWith("not a long tag", function()
            long_ops.write(tags.int(1) :: any, friendly_buf.allocate(8))
        end)
    end)

    suite:case("round-trips float payloads", function(asserts)
        asserts.eq({ 0x42, 0xF7, 0x00, 0x00 }, write_to_bytes(4, tags.float(123.5), float_ops))

        const tag = float_ops.read(helpers.buf_from_bytes({ 0x42, 0xF7, 0x00, 0x00 })):unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_FLOAT, 123.5)

        asserts.throwsWith("not a float tag", function()
            float_ops.write(tags.double(1) :: any, friendly_buf.allocate(4))
        end)
    end)

    suite:case("round-trips double payloads", function(asserts)
        asserts.eq(
            { 0x40, 0x5E, 0xDC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCD },
            write_to_bytes(8, tags.double(123.45), double_ops)
        )

        const tag = double_ops
            .read(helpers.buf_from_bytes({ 0x40, 0x5E, 0xDC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCD }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_DOUBLE, 123.45)

        asserts.throwsWith("not a double tag", function()
            double_ops.write(tags.float(1) :: any, friendly_buf.allocate(8))
        end)
    end)

    suite:case("round-trips string payloads", function(asserts)
        asserts.eq(
            { 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F },
            write_to_bytes(7, tags.str("hello"), string_ops)
        )

        const tag = string_ops
            .read(helpers.buf_from_bytes({ 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_STRING, "hello")

        asserts.throwsWith("not a string tag", function()
            string_ops.write(tags.byte(1) :: any, friendly_buf.allocate(8))
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
