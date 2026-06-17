--!optimize 2

const result = require("@pkg/result")

const tags = require("@moonstone/nbt/tags")
const tag_io = require("@moonstone/nbt/tag_io")
const tag_ops = require("@moonstone/nbt/tag_ops")
const friendly_buf = require("@moonstone/util/friendly_buf")

type Result<R, E> = result.Result<R, E>
type Tag<T> = tag_ops.Tag<T>
type TagOps<T> = tag_ops.TagOps<T>
type NamedTag<T> = tag_ops.NamedTag<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

export function write(tag: Tag<{ NamedTag<any> }>, buf: FriendlyBuf)
    assert(tag.value ~= nil and tag.id ~= nil, "not a valid tag")
    assert(tag.id == tags.TAG_COMPOUND, "not a compound tag")

    for idx, entry in tag.value do
        tag_io.write(buf, entry, true)
    end
    buf:write_u8(tags.TAG_END)
end

export function read(buf: FriendlyBuf): Result<Tag<{ NamedTag<any> }>, string>
    const read = {}

    while true do
        const id = buf:get_i8()
        if id == tags.TAG_END then
            break
        end
        buf.position -= 1

        table.insert(read, tag_io.read(buf, true) :: NamedTag<any>)
    end

    return result.ok(tags.compound(read))
end

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
