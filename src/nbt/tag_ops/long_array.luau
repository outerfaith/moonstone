--!optimize 2

const result = require("@pkg/result")

const tags = require("@moonstone/nbt/tags")
const tag_ops = require("@moonstone/nbt/tag_ops")
const friendly_buf = require("@moonstone/util/friendly_buf")

type Result<R, E> = result.Result<R, E>
type Tag<T> = tag_ops.Tag<T>
type TagOps<T> = tag_ops.TagOps<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

export function write(tag: Tag<{ integer }>, buf: FriendlyBuf)
    assert(tag.value ~= nil and tag.id ~= nil, "not a valid tag")
    assert(tag.id == tags.TAG_LONG_ARRAY, "not a long array tag")

    buf:write_i32(#tag.value)
    for idx, value in ipairs(tag.value) do
        buf:write_i64(value)
    end
end

export function read(buf: FriendlyBuf): Result<Tag<{ integer }>, string>
    const length = buf:get_i32()
    if length < 0 then
        return result.err("length must be non-negative")
    end

    const read = table.create(length)
    for i = 1, length do
        const value = buf:get_i64()

        read[i] = value
    end

    return result.ok(tags.long_array(read :: { integer }))
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
