--!optimize 2
--!native

const test = require("@std/test")

const codecs = require("@moonstone/network/buffer_codec/helper")

const helpers = require("./helpers")

test.suite("Array buffer codecs", function(suite)
    suite:case("round-trips length-prefixed byte arrays", function(asserts)
        const value = helpers.friendly_from_bytes({ 0xDE, 0xAD, 0xBE, 0xEF })

        asserts.eq(
            { 0x04, 0xDE, 0xAD, 0xBE, 0xEF },
            helpers.write_to_bytes(5, codecs.BYTE_ARRAY, value)
        )

        const read =
            codecs.BYTE_ARRAY:read(helpers.buf_from_bytes({ 0x04, 0xDE, 0xAD, 0xBE, 0xEF }))
        asserts.eq(0, read.position)
        asserts.eq(4, read.limit)
        asserts.eq({ 0xDE, 0xAD, 0xBE, 0xEF }, helpers.all_bytes(read))
    end)

    suite:case("round-trips terminating byte arrays over remaining bytes", function(asserts)
        const value = helpers.friendly_from_bytes({ 0x01, 0x02, 0x03 })

        asserts.eq(
            { 0x01, 0x02, 0x03 },
            helpers.write_to_bytes(3, codecs.TERMINATING_BYTE_ARRAY, value)
        )

        const buf = helpers.buf_from_bytes({ 0xAA, 0x01, 0x02, 0x03 })
        buf.position = 1

        const read = codecs.TERMINATING_BYTE_ARRAY:read(buf)
        asserts.eq(4, buf.position)
        asserts.eq({ 0x01, 0x02, 0x03 }, helpers.all_bytes(read))
    end)

    suite:case("round-trips generic arrays", function(asserts)
        const codec = codecs.array(codecs.VAR_INT :: any) :: any

        asserts.eq(
            { 0x03, 0x01, 0x80, 0x01, 0xDD, 0xC7, 0x01 },
            helpers.write_to_bytes(7, codec, { 1, 128, 25565 })
        )

        const read =
            codec:read(helpers.buf_from_bytes({ 0x03, 0x01, 0x80, 0x01, 0xDD, 0xC7, 0x01 }))
        asserts.eq({ 1, 128, 25565 }, read)
    end)

    suite:case("handles empty generic arrays", function(asserts)
        const codec = codecs.array(codecs.UNSIGNED_BYTE :: any) :: any

        asserts.eq({ 0x00 }, helpers.write_to_bytes(1, codec, {}))
        asserts.eq({}, codec:read(helpers.buf_from_bytes({ 0x00 })))
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
