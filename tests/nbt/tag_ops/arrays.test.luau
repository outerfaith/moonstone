--!optimize 2
--!native

const test = require("@std/test")

const tags = require("@moonstone/nbt/tags")
const byte_array_ops = require("@moonstone/nbt/tag_ops/byte_array")
const int_array_ops = require("@moonstone/nbt/tag_ops/int_array")
const long_array_ops = require("@moonstone/nbt/tag_ops/long_array")
const friendly_buf = require("@moonstone/util/friendly_buf")

const helpers = require("../helpers")

const function write_to_bytes(size: number, tag: any, ops: any)
    const buf = friendly_buf.allocate(size)
    ops.write(tag, buf)
    return helpers.written_bytes(buf)
end

test.suite("NBT array tag ops", function(suite)
    suite:case("round-trips byte array payloads", function(asserts)
        const payload = { -1, 0, 127, -128 }

        asserts.eq(
            { 0x00, 0x00, 0x00, 0x04, 0xFF, 0x00, 0x7F, 0x80 },
            write_to_bytes(8, tags.byte_array(payload), byte_array_ops)
        )

        const tag = byte_array_ops
            .read(helpers.buf_from_bytes({ 0x00, 0x00, 0x00, 0x04, 0xFF, 0x00, 0x7F, 0x80 }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_BYTE_ARRAY, payload)

        asserts.eq(
            "length must be non-negative",
            byte_array_ops.read(helpers.buf_from_bytes({ 0xFF, 0xFF, 0xFF, 0xFF })):unwrap_err()
        )

        asserts.throwsWith("not a byte array tag", function()
            byte_array_ops.write(tags.int_array({ 1 }) :: any, friendly_buf.allocate(8))
        end)
    end)

    suite:case("round-trips int array payloads", function(asserts)
        const payload = { -1, 0, 0x7FFFFFFF, -0x80000000 }

        asserts.eq({
            0x00,
            0x00,
            0x00,
            0x04,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0x00,
            0x00,
            0x00,
            0x00,
            0x7F,
            0xFF,
            0xFF,
            0xFF,
            0x80,
            0x00,
            0x00,
            0x00,
        }, write_to_bytes(20, tags.int_array(payload), int_array_ops))

        const tag = int_array_ops
            .read(helpers.buf_from_bytes({
                0x00,
                0x00,
                0x00,
                0x04,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x00,
                0x00,
                0x7F,
                0xFF,
                0xFF,
                0xFF,
                0x80,
                0x00,
                0x00,
                0x00,
            }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_INT_ARRAY, payload)

        asserts.eq(
            "length must be non-negative",
            int_array_ops.read(helpers.buf_from_bytes({ 0xFF, 0xFF, 0xFF, 0xFF })):unwrap_err()
        )

        asserts.throwsWith("not an int array tag", function()
            int_array_ops.write(tags.byte_array({ 1 }) :: any, friendly_buf.allocate(8))
        end)
    end)

    suite:case("round-trips long array payloads", function(asserts)
        const payload = { integer.create(-1), integer.create(2 ^ 40) }

        asserts.eq({
            0x00,
            0x00,
            0x00,
            0x02,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0xFF,
            0x00,
            0x00,
            0x01,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
        }, write_to_bytes(20, tags.long_array(payload), long_array_ops))

        const tag = long_array_ops
            .read(helpers.buf_from_bytes({
                0x00,
                0x00,
                0x00,
                0x02,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x01,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
            }))
            :unwrap()
        helpers.assert_tag(asserts, tag, tags.TAG_LONG_ARRAY, payload)

        asserts.eq(
            "length must be non-negative",
            long_array_ops.read(helpers.buf_from_bytes({ 0xFF, 0xFF, 0xFF, 0xFF })):unwrap_err()
        )

        asserts.throwsWith("not a long array tag", function()
            long_array_ops.write(tags.int_array({ 1 }) :: any, friendly_buf.allocate(12))
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
