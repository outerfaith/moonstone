--!optimize 2
--!native

const test = require("@std/test")

const tags = require("@moonstone/nbt/tags")
const list_ops = require("@moonstone/nbt/tag_ops/list")
const compound_ops = require("@moonstone/nbt/tag_ops/compound")
const friendly_buf = require("@moonstone/util/friendly_buf")

const helpers = require("../helpers")

const function write_to_bytes(size: number, tag: any, ops: any)
    const buf = friendly_buf.allocate(size)
    ops.write(tag, buf)
    return helpers.written_bytes(buf)
end

test.suite("NBT structured tag ops", function(suite)
    suite:case("round-trips empty list payloads", function(asserts)
        const tag = tags.list({}, nil)

        asserts.eq({ tags.TAG_END, 0x00, 0x00, 0x00, 0x00 }, write_to_bytes(5, tag, list_ops))

        const read = list_ops
            .read(helpers.buf_from_bytes({ tags.TAG_END, 0x00, 0x00, 0x00, 0x00 }))
            :unwrap() :: any
        asserts.eq(tags.TAG_LIST, read.id)
        asserts.eq(tags.TAG_END, read.element_id)
        asserts.eq({}, read.value)
    end)

    suite:case("round-trips homogeneous list payloads", function(asserts)
        const tag = tags.list({ tags.int(1), tags.int(-2), tags.int(3) }, tags.TAG_INT)

        asserts.eq({
            tags.TAG_INT,
            0x00,
            0x00,
            0x00,
            0x03,
            0x00,
            0x00,
            0x00,
            0x01,
            0xFF,
            0xFF,
            0xFF,
            0xFE,
            0x00,
            0x00,
            0x00,
            0x03,
        }, write_to_bytes(17, tag, list_ops))

        const read = (
            list_ops
                .read(helpers.buf_from_bytes({
                    tags.TAG_INT,
                    0x00,
                    0x00,
                    0x00,
                    0x03,
                    0x00,
                    0x00,
                    0x00,
                    0x01,
                    0xFF,
                    0xFF,
                    0xFF,
                    0xFE,
                    0x00,
                    0x00,
                    0x00,
                    0x03,
                }))
                :unwrap()
        ) :: any

        asserts.eq(tags.TAG_LIST, read.id)
        asserts.eq(tags.TAG_INT, read.element_id)
        asserts.eq({ tags.int(1), tags.int(-2), tags.int(3) }, read.value)
    end)

    suite:case("rejects malformed list payloads", function(asserts)
        asserts.eq(
            "list tag length must be non-negative",
            list_ops
                .read(helpers.buf_from_bytes({ tags.TAG_INT, 0xFF, 0xFF, 0xFF, 0xFF }))
                :unwrap_err()
        )

        asserts.eq(
            "non-empty list tag cannot have end tags",
            list_ops
                .read(helpers.buf_from_bytes({ tags.TAG_END, 0x00, 0x00, 0x00, 0x01 }))
                :unwrap_err()
        )

        asserts.throwsWith("non-empty list tag cannot have end tags", function()
            list_ops.write(
                { id = tags.TAG_LIST, value = { tags.byte(1) }, element_id = tags.TAG_END } :: any,
                friendly_buf.allocate(8)
            )
        end)

        asserts.throwsWith("list tags must be homogeneous", function()
            list_ops.write(
                {
                    id = tags.TAG_LIST,
                    value = { tags.byte(1), tags.short(2) },
                    element_id = tags.TAG_BYTE,
                } :: any,
                friendly_buf.allocate(16)
            )
        end)
    end)

    suite:case("round-trips compound payloads", function(asserts)
        const tag = tags.compound({
            tags.named("byte", tags.byte(-2)),
            tags.named("name", tags.str("Alex")),
            tags.named(
                "coords",
                tags.list({ tags.int(1), tags.int(64), tags.int(-3) }, tags.TAG_INT)
            ),
        })

        const expected = {
            tags.TAG_BYTE,
            0x00,
            0x04,
            0x62,
            0x79,
            0x74,
            0x65,
            0xFE,
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
            tags.TAG_LIST,
            0x00,
            0x06,
            0x63,
            0x6F,
            0x6F,
            0x72,
            0x64,
            0x73,
            tags.TAG_INT,
            0x00,
            0x00,
            0x00,
            0x03,
            0x00,
            0x00,
            0x00,
            0x01,
            0x00,
            0x00,
            0x00,
            0x40,
            0xFF,
            0xFF,
            0xFF,
            0xFD,
            tags.TAG_END,
        }

        asserts.eq(expected, write_to_bytes(#expected, tag, compound_ops))

        const read = compound_ops.read(helpers.buf_from_bytes(expected)):unwrap() :: any
        asserts.eq(tags.TAG_COMPOUND, read.id)
        asserts.eq(3, #read.value)
        helpers.assert_named_tag(asserts, read.value[1], "byte", tags.TAG_BYTE, -2)
        helpers.assert_named_tag(asserts, read.value[2], "name", tags.TAG_STRING, "Alex")
        asserts.eq("coords", read.value[3].name)
        asserts.eq(tags.TAG_LIST, read.value[3].tag.id)
        asserts.eq(tags.TAG_INT, read.value[3].tag.element_id)
        asserts.eq({ tags.int(1), tags.int(64), tags.int(-3) }, read.value[3].tag.value)
    end)
end)
