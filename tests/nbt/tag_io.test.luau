--!optimize 2
--!native

const test = require("@std/test")

const tags = require("@moonstone/nbt/tags")
const tag_io = require("@moonstone/nbt/tag_io")
const friendly_buf = require("@moonstone/util/friendly_buf")

const helpers = require("./helpers")

const function write_to_bytes(size: number, tag: any, preserve_name: boolean?)
    const buf = friendly_buf.allocate(size)
    tag_io.write(buf, tag, preserve_name)
    return helpers.written_bytes(buf)
end

test.suite("NBT tag IO", function(suite)
    suite:case("writes and reads unnamed tags with id and payload", function(asserts)
        const tag = tags.int(-123456789)

        asserts.eq({ tags.TAG_INT, 0xF8, 0xA4, 0x32, 0xEB }, write_to_bytes(5, tag))

        const read = tag_io.read(helpers.buf_from_bytes({ tags.TAG_INT, 0xF8, 0xA4, 0x32, 0xEB }))
        helpers.assert_tag(asserts, read, tags.TAG_INT, -123456789)
    end)

    suite:case("writes and reads named tags when name preservation is requested", function(asserts)
        const named = tags.named("health", tags.short(20))

        asserts.eq({
            tags.TAG_SHORT,
            0x00,
            0x06,
            0x68,
            0x65,
            0x61,
            0x6C,
            0x74,
            0x68,
            0x00,
            0x14,
        }, write_to_bytes(11, named, true))

        const read = tag_io.read(
            helpers.buf_from_bytes({
                tags.TAG_SHORT,
                0x00,
                0x06,
                0x68,
                0x65,
                0x61,
                0x6C,
                0x74,
                0x68,
                0x00,
                0x14,
            }),
            true
        )
        helpers.assert_named_tag(asserts, read, "health", tags.TAG_SHORT, 20)
    end)

    suite:case("can write named tag payloads without preserving the name", function(asserts)
        const named = tags.named("ignored", tags.byte(-1))

        asserts.eq({ tags.TAG_BYTE, 0xFF }, write_to_bytes(2, named, false))

        const read = tag_io.read(helpers.buf_from_bytes({ tags.TAG_BYTE, 0xFF }))
        helpers.assert_tag(asserts, read, tags.TAG_BYTE, -1)
    end)

    suite:case("writes and reads payload-only tags", function(asserts)
        const buf = friendly_buf.allocate(7)

        tag_io.write_payload(buf, tags.str("hello"))
        asserts.eq({ 0x00, 0x05, 0x68, 0x65, 0x6C, 0x6C, 0x6F }, helpers.written_bytes(buf))

        buf.position = 0
        helpers.assert_tag(
            asserts,
            tag_io.read_payload(buf, tags.TAG_STRING),
            tags.TAG_STRING,
            "hello"
        )
        asserts.eq(7, buf.position)
    end)

    suite:case("round-trips a nested named compound", function(asserts)
        const root = tags.named(
            "Player",
            tags.compound({
                tags.named("Health", tags.short(20)),
                tags.named("Name", tags.str("Alex")),
                tags.named(
                    "Pos",
                    tags.list(
                        { tags.double(1.25), tags.double(64), tags.double(-9.5) },
                        tags.TAG_DOUBLE
                    )
                ),
                tags.named("Inventory", tags.list({}, nil)),
            })
        )

        const buf = friendly_buf.allocate(128)
        tag_io.write(buf, root, true)

        buf.limit = buf.position
        buf.position = 0

        const read = tag_io.read(buf, true) :: any
        asserts.eq("Player", read.name)
        asserts.eq(tags.TAG_COMPOUND, read.tag.id)
        asserts.eq(4, #read.tag.value)

        helpers.assert_named_tag(asserts, read.tag.value[1], "Health", tags.TAG_SHORT, 20)
        helpers.assert_named_tag(asserts, read.tag.value[2], "Name", tags.TAG_STRING, "Alex")

        asserts.eq("Pos", read.tag.value[3].name)
        asserts.eq(tags.TAG_LIST, read.tag.value[3].tag.id)
        asserts.eq(tags.TAG_DOUBLE, read.tag.value[3].tag.element_id)
        asserts.eq(
            { tags.double(1.25), tags.double(64), tags.double(-9.5) },
            read.tag.value[3].tag.value
        )

        asserts.eq("Inventory", read.tag.value[4].name)
        asserts.eq(tags.TAG_LIST, read.tag.value[4].tag.id)
        asserts.eq(tags.TAG_END, read.tag.value[4].tag.element_id)
        asserts.eq({}, read.tag.value[4].tag.value)
    end)

    suite:case("rejects invalid tag ids on read and write dispatch", function(asserts)
        asserts.throwsWith("'13' is not a valid NBT tag id", function()
            tag_io.write(
                friendly_buf.allocate(1),
                { id = tags.TAG_LONG_ARRAY + 1, value = 0 } :: any
            )
        end)

        asserts.throwsWith("'13' is not a valid NBT tag id", function()
            tag_io.read(helpers.buf_from_bytes({ tags.TAG_LONG_ARRAY + 1 }))
        end)

        asserts.throwsWith("'13' is not a valid NBT tag id", function()
            tag_io.read_payload(friendly_buf.allocate(0), tags.TAG_LONG_ARRAY + 1)
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
