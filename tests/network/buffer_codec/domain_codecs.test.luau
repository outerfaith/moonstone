--!optimize 2
--!native

const test = require("@std/test")

const identifier = require("@moonstone/resources/identifier")
const tag_io = require("@moonstone/nbt/tag_io")
const tags = require("@moonstone/nbt/tags")

const helpers = require("./helpers")

const function prefixed_string_bytes(value: string): { number }
    const bytes = { string.len(value) }

    for _, byte in ipairs(helpers.string_bytes(value)) do
        table.insert(bytes, byte)
    end

    return bytes
end

test.suite("Domain buffer codecs", function(suite)
    suite:case("round-trips identifiers", function(asserts)
        const value = identifier.with_default_namespace("systems/tick")
        const encoded = prefixed_string_bytes("moonstone:systems/tick")

        asserts.eq(encoded, helpers.write_to_bytes(#encoded, identifier.BUFFER_CODEC, value))
        asserts.eq(value, identifier.BUFFER_CODEC:read(helpers.buf_from_bytes(encoded)))
    end)

    suite:case("identifier codec parses minecraft shorthand", function(asserts)
        const encoded = prefixed_string_bytes("stone")
        const read = identifier.BUFFER_CODEC:read(helpers.buf_from_bytes(encoded))

        asserts.eq(identifier.with_minecraft_namespace("stone"), read)
    end)

    suite:case("round-trips unnamed NBT scalar tags", function(asserts)
        asserts.eq(
            { tags.TAG_INT, 0x00, 0x00, 0x00, 0x2A },
            helpers.write_to_bytes(5, tag_io.BUFFER_CODEC, tags.int(42))
        )

        const read = tag_io.BUFFER_CODEC:read(
            helpers.buf_from_bytes({ tags.TAG_INT, 0x00, 0x00, 0x00, 0x2A })
        )
        asserts.eq(tags.TAG_INT, read.id)
        asserts.eq(42, read.value)
    end)

    suite:case("round-trips unnamed NBT compound tags", function(asserts)
        const value = tags.compound({
            tags.named("name", tags.str("Alex")),
            tags.named("level", tags.int(7)),
        })
        const encoded = {
            tags.TAG_COMPOUND,
            tags.TAG_STRING,
            0x00,
            0x04,
            0x6E,
            0x61,
            0x6D,
            0x65,
            0x00,
            0x04,
            0x41,
            0x6C,
            0x65,
            0x78,
            tags.TAG_INT,
            0x00,
            0x05,
            0x6C,
            0x65,
            0x76,
            0x65,
            0x6C,
            0x00,
            0x00,
            0x00,
            0x07,
            tags.TAG_END,
        }

        asserts.eq(encoded, helpers.write_to_bytes(#encoded, tag_io.BUFFER_CODEC, value))

        const read = tag_io.BUFFER_CODEC:read(helpers.buf_from_bytes(encoded)) :: any
        asserts.eq(tags.TAG_COMPOUND, read.id)
        asserts.eq(2, #read.value)
        asserts.eq("name", read.value[1].name)
        asserts.eq(tags.TAG_STRING, read.value[1].tag.id)
        asserts.eq("Alex", read.value[1].tag.value)
        asserts.eq("level", read.value[2].name)
        asserts.eq(tags.TAG_INT, read.value[2].tag.id)
        asserts.eq(7, read.value[2].tag.value)
    end)
end)
