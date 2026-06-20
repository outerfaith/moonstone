--!optimize 2
--!native

const test = require("@std/test")

const codecs = require("@moonstone/network/buffer_codec/helper")

const helpers = require("./helpers")

test.suite("String buffer codecs", function(suite)
    suite:case("round-trips unlimited strings", function(asserts)
        const codec = codecs.UNLIMITED_STRING

        asserts.eq(
            { 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F },
            helpers.write_to_bytes(6, codec, "hello")
        )
        asserts.eq(
            "hello",
            codec:read(helpers.buf_from_bytes({ 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F }))
        )
    end)

    suite:case("round-trips limited strings with multibyte characters", function(asserts)
        const codec = codecs.limited_string(5)

        asserts.eq(
            { 0x07, 0x73, 0x6E, 0x6F, 0x77, 0xE2, 0x98, 0x83 },
            helpers.write_to_bytes(8, codec, "snow☃")
        )
        asserts.eq(
            "snow☃",
            codec:read(helpers.buf_from_bytes({ 0x07, 0x73, 0x6E, 0x6F, 0x77, 0xE2, 0x98, 0x83 }))
        )
    end)

    suite:case("rejects invalid string limits", function(asserts)
        asserts.throwsWith("max length must be at least 1 and at most 32767", function()
            codecs.limited_string(0)
        end)

        asserts.throwsWith("max length must be at least 1 and at most 32767", function()
            codecs.limited_string(32768)
        end)
    end)

    suite:case("rejects strings that exceed character or byte limits", function(asserts)
        const codec = codecs.limited_string(3)

        asserts.throwsWith(
            "string is too long, expected at most 3 characters but found 4 characters",
            function()
                codec:write(helpers.buf_from_bytes({ 0x00, 0x00, 0x00, 0x00 }), "four")
            end
        )

        asserts.throwsWith("decoded string is too long", function()
            codec:read(helpers.buf_from_bytes({ 0x04, 0x66, 0x6F, 0x75, 0x72 }))
        end)

        asserts.throwsWith("string must be at most 12 bytes", function()
            codec:read(helpers.buf_from_bytes({ 0x0D }))
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
