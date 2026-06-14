--!optimize 2
--!native

const test = require("@std/test")

const codecs = require("@moonstone/network/buffer_codec/helper")

const helpers = require("./helpers")

test.suite("Variable-sized buffer codecs", function(suite)
    suite:case("round-trips VarInt values", function(asserts)
        const cases = {
            { value = 0, bytes = { 0x00 } },
            { value = 1, bytes = { 0x01 } },
            { value = 127, bytes = { 0x7F } },
            { value = 128, bytes = { 0x80, 0x01 } },
            { value = 255, bytes = { 0xFF, 0x01 } },
            { value = 25565, bytes = { 0xDD, 0xC7, 0x01 } },
            { value = 2097151, bytes = { 0xFF, 0xFF, 0x7F } },
            { value = 2147483647, bytes = { 0xFF, 0xFF, 0xFF, 0xFF, 0x07 } },
        }

        for _, case in ipairs(cases) do
            asserts.eq(case.bytes, helpers.write_to_bytes(#case.bytes, codecs.VAR_INT, case.value))
            asserts.eq(case.value, codecs.VAR_INT:read(helpers.buf_from_bytes(case.bytes)))
        end
    end)

    suite:case("rejects oversized VarInt values while decoding", function(asserts)
        asserts.throwsWith("VarInt is too big", function()
            codecs.VAR_INT:read(helpers.buf_from_bytes({ 0x80, 0x80, 0x80, 0x80, 0x80 }))
        end)
    end)

    suite:case("round-trips VarLong values", function(asserts)
        const cases = {
            { value = 0i, bytes = { 0x00 } },
            { value = 1i, bytes = { 0x01 } },
            { value = 127i, bytes = { 0x7F } },
            { value = 128i, bytes = { 0x80, 0x01 } },
            { value = 255i, bytes = { 0xFF, 0x01 } },
            { value = integer.create(2 ^ 35), bytes = { 0x80, 0x80, 0x80, 0x80, 0x80, 0x01 } },
        }

        for _, case in ipairs(cases) do
            asserts.eq(case.bytes, helpers.write_to_bytes(#case.bytes, codecs.VAR_LONG, case.value))
            asserts.eq(case.value, codecs.VAR_LONG:read(helpers.buf_from_bytes(case.bytes)))
        end
    end)

    suite:case("rejects oversized VarLong values while decoding", function(asserts)
        asserts.throwsWith("VarLong is too big", function()
            codecs.VAR_LONG:read(helpers.buf_from_bytes({
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
                0x80,
            }))
        end)
    end)
end)
