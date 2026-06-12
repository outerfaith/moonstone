--!optimize 2

const result = require("@pkg/result")

const tags = require("@moonstone/nbt/tags")
const tag_io = require("@moonstone/nbt/tag_io")
const tag_ops = require("@moonstone/nbt/tag_ops")
const friendly_buf = require("@moonstone/util/friendly_buf")

type Result<R, E> = result.Result<R, E>
type Tag<T> = tag_ops.Tag<T>
type ListTag<T> = tag_ops.ListTag<T>
type TagOps<T> = tag_ops.TagOps<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

const function write<T>(tag: ListTag<{ Tag<T> }>, buf: FriendlyBuf)
    assert(tag.value ~= nil and tag.id ~= nil, "not a valid tag")
    assert(tag.id == tags.TAG_LIST, "not a list tag")

    const element_id = if tag.element_id ~= nil
        then tags.assert_tag_id(tag.element_id)
        else tags.TAG_END
    assert(element_id ~= tags.TAG_END or #tag.value == 0, "non-empty list tag cannot have end tags")

    buf:write_u8(element_id)
    buf:write_i32(#tag.value)

    for idx, entry in tag.value do
        assert(entry.id == element_id, "list tags must be homogeneous")

        tag_io.write_payload(buf, entry)
    end
end

const function read<T>(buf: FriendlyBuf): Result<ListTag<{ Tag<T> }>, string>
    const element_id = buf:get_u8()
    const length = buf:get_i32()
    if length < 0 then
        return result.err("list tag length must be non-negative")
    end
    if not (element_id ~= tags.TAG_END or length == 0) then
        return result.err("non-empty list tag cannot have end tags")
    end

    const read = table.create(length)
    for i = 1, length do
        read[i] = tag_io.read_payload(buf, element_id)
    end

    return result.ok(tags.list(read :: any, element_id))
end

return table.freeze({
    write = write,
    read = read,
}) :: TagOps<{ unknown }>

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
