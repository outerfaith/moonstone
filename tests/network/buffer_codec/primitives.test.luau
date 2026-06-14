--!optimize 2
--!native

const test = require("@std/test")

const codecs = require("@moonstone/network/buffer_codec/helper")

const helpers = require("./helpers")

test.suite("Primitive buffer codecs", function(suite)
    suite:case("round-trips booleans", function(asserts)
        asserts.eq(
            { 0x01, 0x00 },
            helpers.write_to_bytes(2, {
                write = function(_, buf, value)
                    codecs.BOOLEAN:write(buf, value[1])
                    codecs.BOOLEAN:write(buf, value[2])
                end,
            }, { true, false })
        )

        const buf = helpers.buf_from_bytes({ 0x01, 0x00, 0x02 })

        asserts.eq(true, codecs.BOOLEAN:read(buf))
        asserts.eq(false, codecs.BOOLEAN:read(buf))
        asserts.eq(true, codecs.BOOLEAN:read(buf))
        asserts.eq(3, buf.position)
    end)

    suite:case("round-trips byte codecs", function(asserts)
        const buf = helpers.buf_from_bytes({ 0xFE, 0xAB })

        asserts.eq({ 0xFE }, helpers.write_to_bytes(1, codecs.BYTE, -2))
        asserts.eq({ 0xAB }, helpers.write_to_bytes(1, codecs.UNSIGNED_BYTE, 0xAB))

        asserts.eq(-2, codecs.BYTE:read(buf))
        asserts.eq(0xAB, codecs.UNSIGNED_BYTE:read(buf))
        asserts.eq(2, buf.position)
    end)

    suite:case("round-trips short codecs", function(asserts)
        const buf = helpers.buf_from_bytes({ 0xCF, 0xC7, 0xC0, 0xDE })

        asserts.eq({ 0xCF, 0xC7 }, helpers.write_to_bytes(2, codecs.SHORT, -12345))
        asserts.eq({ 0xC0, 0xDE }, helpers.write_to_bytes(2, codecs.UNSIGNED_SHORT, 0xC0DE))

        asserts.eq(-12345, codecs.SHORT:read(buf))
        asserts.eq(0xC0DE, codecs.UNSIGNED_SHORT:read(buf))
        asserts.eq(4, buf.position)
    end)

    suite:case("round-trips int and long codecs", function(asserts)
        const long_value = integer.create(2 ^ 52)
        const buf = helpers.buf_from_bytes({
            0xF8,
            0xA4,
            0x32,
            0xEB,
            0x00,
            0x10,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
            0x00,
        })

        asserts.eq({ 0xF8, 0xA4, 0x32, 0xEB }, helpers.write_to_bytes(4, codecs.INT, -123456789))
        asserts.eq(
            { 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 },
            helpers.write_to_bytes(8, codecs.LONG, long_value)
        )

        asserts.eq(-123456789, codecs.INT:read(buf))
        asserts.eq(long_value, codecs.LONG:read(buf))
        asserts.eq(12, buf.position)
    end)

    suite:case("round-trips floating point codecs", function(asserts)
        const buf = helpers.buf_from_bytes({
            0x42,
            0xF7,
            0x00,
            0x00,
            0x40,
            0x5E,
            0xDC,
            0xCC,
            0xCC,
            0xCC,
            0xCC,
            0xCD,
        })

        asserts.eq({ 0x42, 0xF7, 0x00, 0x00 }, helpers.write_to_bytes(4, codecs.FLOAT, 123.5))
        asserts.eq(
            { 0x40, 0x5E, 0xDC, 0xCC, 0xCC, 0xCC, 0xCC, 0xCD },
            helpers.write_to_bytes(8, codecs.DOUBLE, 123.45)
        )

        asserts.eq(123.5, codecs.FLOAT:read(buf))
        asserts.eq(123.45, codecs.DOUBLE:read(buf))
        asserts.eq(12, buf.position)
    end)
end)
