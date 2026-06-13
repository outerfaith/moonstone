--!optimize 2
--!native

const test = require("@std/test")

const tags = require("@moonstone/nbt/tags")

test.suite("NBT tags", function(suite)
    suite:case("exports canonical tag ids", function(asserts)
        asserts.eq(0x00, tags.TAG_END)
        asserts.eq(0x01, tags.TAG_BYTE)
        asserts.eq(0x02, tags.TAG_SHORT)
        asserts.eq(0x03, tags.TAG_INT)
        asserts.eq(0x04, tags.TAG_LONG)
        asserts.eq(0x05, tags.TAG_FLOAT)
        asserts.eq(0x06, tags.TAG_DOUBLE)
        asserts.eq(0x07, tags.TAG_BYTE_ARRAY)
        asserts.eq(0x08, tags.TAG_STRING)
        asserts.eq(0x09, tags.TAG_LIST)
        asserts.eq(0x0A, tags.TAG_COMPOUND)
        asserts.eq(0x0B, tags.TAG_INT_ARRAY)
        asserts.eq(0x0C, tags.TAG_LONG_ARRAY)
    end)

    suite:case("validates tag ids", function(asserts)
        asserts.eq(tags.TAG_END, tags.assert_tag_id(tags.TAG_END))
        asserts.eq(tags.TAG_LONG_ARRAY, tags.assert_tag_id(tags.TAG_LONG_ARRAY))

        asserts.throwsWith("'-1' is not a valid NBT tag id", function()
            tags.assert_tag_id(-1)
        end)

        asserts.throwsWith("'13' is not a valid NBT tag id", function()
            tags.assert_tag_id(tags.TAG_LONG_ARRAY + 1)
        end)
    end)

    suite:case("constructs scalar tags with validated payloads", function(asserts)
        asserts.eq({ id = tags.TAG_BYTE, value = -128 }, tags.byte(-128))
        asserts.eq({ id = tags.TAG_SHORT, value = 0x7FFF }, tags.short(0x7FFF))
        asserts.eq({ id = tags.TAG_INT, value = -0x80000000 }, tags.int(-0x80000000))
        asserts.eq(
            { id = tags.TAG_LONG, value = integer.create(2 ^ 40) },
            tags.long(integer.create(2 ^ 40))
        )
        asserts.eq({ id = tags.TAG_FLOAT, value = 12.5 }, tags.float(12.5))
        asserts.eq({ id = tags.TAG_DOUBLE, value = math.pi }, tags.double(math.pi))
        asserts.eq({ id = tags.TAG_STRING, value = "hello" }, tags.str("hello"))

        asserts.throws(function()
            tags.byte(128)
        end)

        asserts.throws(function()
            tags.short(-0x8001)
        end)

        asserts.throws(function()
            tags.int(0x80000000)
        end)
    end)

    suite:case("constructs array tags", function(asserts)
        asserts.eq(
            { id = tags.TAG_BYTE_ARRAY, value = { -1, 0, 1 } },
            tags.byte_array({ -1, 0, 1 })
        )
        asserts.eq({ id = tags.TAG_INT_ARRAY, value = { -1, 0, 1 } }, tags.int_array({ -1, 0, 1 }))
        asserts.eq(
            { id = tags.TAG_LONG_ARRAY, value = { integer.create(-1), integer.create(2 ^ 33) } },
            tags.long_array({ integer.create(-1), integer.create(2 ^ 33) })
        )

        asserts.throwsWith("not an integer", function()
            tags.int_array({ 0x80000000 })
        end)
    end)

    suite:case("constructs named, list, and compound tags", function(asserts)
        const byte = tags.byte(1)
        const short = tags.short(2)
        const list = tags.list({ byte }, tags.TAG_BYTE)
        const empty_list = tags.list({}, nil)
        const named = tags.named("value", short)
        const compound = tags.compound({ named })

        asserts.eq({ id = tags.TAG_LIST, value = { byte }, element_id = tags.TAG_BYTE }, list)
        asserts.eq({ id = tags.TAG_LIST, value = {}, element_id = nil }, empty_list)
        asserts.eq({ name = "value", tag = short }, named)
        asserts.eq({ id = tags.TAG_COMPOUND, value = { named } }, compound)

        asserts.throwsWith("list tags must be homogeneous", function()
            tags.list({ byte, short }, tags.TAG_BYTE)
        end)
    end)
end)
