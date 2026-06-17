--!optimize 2

const tags = require("@moonstone/nbt/tags")
const tag_ops = require("@moonstone/nbt/tag_ops")
const buffer_codec = require("@moonstone/network/buffer_codec/helper")
const friendly_buf = require("@moonstone/util/friendly_buf")
const lazy_require = require("@moonstone/util/lazy_require")

type Tag<T> = tag_ops.Tag<T>
type TagOps<T> = tag_ops.TagOps<T>
type NamedTag<T> = tag_ops.NamedTag<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

type AnyTag<T> = {
    read value: T?,
    read id: number?,
    read element_id: number?,
    read name: string?,
    read tag: Tag<T>?,
}

const DISPATCH_TABLE: { read [number]: () -> TagOps<any> } = table.freeze({
    [tags.TAG_BYTE] = lazy_require<<TagOps<number>>>("@moonstone/nbt/tag_ops/byte"),
    [tags.TAG_SHORT] = lazy_require<<TagOps<number>>>("@moonstone/nbt/tag_ops/short"),
    [tags.TAG_INT] = lazy_require<<TagOps<number>>>("@moonstone/nbt/tag_ops/int"),
    [tags.TAG_LONG] = lazy_require<<TagOps<integer>>>("@moonstone/nbt/tag_ops/long"),
    [tags.TAG_FLOAT] = lazy_require<<TagOps<number>>>("@moonstone/nbt/tag_ops/float"),
    [tags.TAG_DOUBLE] = lazy_require<<TagOps<number>>>("@moonstone/nbt/tag_ops/double"),
    [tags.TAG_BYTE_ARRAY] = lazy_require<<TagOps<{ number }>>>("@moonstone/nbt/tag_ops/byte_array"),
    [tags.TAG_STRING] = lazy_require<<TagOps<string>>>("@moonstone/nbt/tag_ops/string"),
    [tags.TAG_LIST] = lazy_require<<TagOps<{ unknown }>>>("@moonstone/nbt/tag_ops/list"),
    [tags.TAG_COMPOUND] = lazy_require<<TagOps<NamedTag<any>>>>("@moonstone/nbt/tag_ops/compound"),
    [tags.TAG_INT_ARRAY] = lazy_require<<TagOps<{ number }>>>("@moonstone/nbt/tag_ops/int_array"),
    [tags.TAG_LONG_ARRAY] = lazy_require<<TagOps<{ integer }>>>(
        "@moonstone/nbt/tag_ops/long_array"
    ),
})

export function write_payload<T>(buf: FriendlyBuf, tag: Tag<T>)
    const id = tags.assert_tag_id(tag.id)
    const ops = DISPATCH_TABLE[id]()

    ops.write(tag :: Tag<T>, buf)
end

export function read_payload<T>(buf: FriendlyBuf, id: number): Tag<T>
    const validated_id = tags.assert_tag_id(id)
    const ops = DISPATCH_TABLE[validated_id]()

    return ops.read(buf):unwrap()
end

export function write<T>(buf: FriendlyBuf, tag: AnyTag<T>, preserve_name: boolean?)
    const id = tags.assert_tag_id(if tag.id ~= nil then tag.id else (tag.tag :: any).id)
    const ops = DISPATCH_TABLE[id]()

    buf:write_u8(id)

    if tag.name ~= nil and preserve_name then
        const length = string.len(tag.name)

        buf:write_u16(length)
        buf:write_string(tag.name)
    end

    if tag.name ~= nil then
        ops.write((tag :: NamedTag<T>).tag, buf)
        return
    end

    ops.write(tag :: Tag<T>, buf)
end

export function read<T>(buf: FriendlyBuf, named: boolean?): AnyTag<T>
    const id = tags.assert_tag_id(buf:get_u8())
    const ops = DISPATCH_TABLE[id]()

    if named then
        const name_length = buf:get_u16()
        const name = buf:get_string(name_length)

        const tag = ops.read(buf):unwrap()

        return tags.named(name, tag)
    end

    return ops.read(buf):unwrap()
end

export const BUFFER_CODEC = buffer_codec.new<<Tag<unknown>>>(function(buf)
    return read(buf) :: Tag<unknown>
end, function(buf, value)
    write(buf, value, false)
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
