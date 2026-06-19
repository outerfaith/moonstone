--!optimize 2
--!nolint UnknownType

const data_result = require("@moonstone/codec/data_result")
const transcoder = require("@moonstone/codec/transcoder")
const tags = require("@moonstone/nbt/tags")
const assertions = require("@moonstone/util/assertions")

type DataResult<T> = data_result.DataResult<T>
type Transcoder<T> = transcoder.Transcoder<T>
type Tag<T> = tags.Tag<T>
type ListTag<T> = tags.ListTag<T>
type NamedTag<T> = tags.NamedTag<T>

type Dictionary<T> = { read [string]: T }

const nbt_transcoder = {} :: Transcoder<Tag<unknown>>
nbt_transcoder.__index = nbt_transcoder

function nbt_transcoder.create_nil(self)
    return tags.end_tag()
end

function nbt_transcoder.create_string(self, value)
    assert(type(value) == "string", "value is not a string")

    return tags.str(value)
end

function nbt_transcoder.create_i8(self, value)
    assert(type(value) == "number", "value is not a number")

    return tags.byte(value)
end

function nbt_transcoder.create_i16(self, value)
    assert(type(value) == "number", "value is not a number")

    return tags.short(value)
end

function nbt_transcoder.create_i32(self, value)
    assert(type(value) == "number", "value is not a number")

    return tags.int(value)
end

function nbt_transcoder.create_i64(self, value)
    assert(type(value) == "integer", "value is not an integer")

    return tags.long(value)
end

function nbt_transcoder.create_f32(self, value)
    assert(type(value) == "number", "value is not a number")

    return tags.float(value)
end

function nbt_transcoder.create_f64(self, value)
    assert(type(value) == "number", "value is not a number")

    return tags.double(value)
end

function nbt_transcoder.create_boolean(self, value)
    assert(type(value) == "boolean", "value is not a boolean")

    return tags.byte(if value then 1 else 0)
end

function nbt_transcoder.create_dictionary(self, value)
    assert(type(value) == "table", "value is not a table")

    const result = {}
    for name, tag in value do
        assert(type(name) == "string", "dictionary key must be a string")
        assert(type(tag) == "table", "entry is not a table")

        table.insert(result, tags.named(name, tag))
    end

    return tags.compound(result)
end

function nbt_transcoder.create_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(idx) == "number", "entry key is not a number")
    end

    if #value > 0 then
        return tags.list(value, value[1].id)
    end
    return tags.list(value)
end

function nbt_transcoder.create_i8_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "number", "entry is not a number")
        assertions.is_i8(entry, "entry is not within range")
    end

    return tags.byte_array(value)
end

function nbt_transcoder.create_i32_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "number", "entry is not a number")
        assertions.is_i32(entry, "entry is not within range")
    end

    return tags.int_array(value)
end

function nbt_transcoder.create_i64_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "integer", "entry is not an integer")
    end

    return tags.long_array(value)
end

function nbt_transcoder.get_string(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_STRING then
        return data_result.err<<string>>("tag is not a string")
    end

    return data_result.ok(value.value :: string)
end

function nbt_transcoder.get_i8(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_BYTE then
        return data_result.err<<number>>("tag is not a byte")
    end

    return data_result.ok(value.value :: number)
end

function nbt_transcoder.get_i16(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_SHORT then
        return data_result.err<<number>>("tag is not a short")
    end

    return data_result.ok(value.value :: number)
end

function nbt_transcoder.get_i32(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_INT then
        return data_result.err<<number>>("tag is not an integer")
    end

    return data_result.ok(value.value :: number)
end

function nbt_transcoder.get_i64(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_LONG then
        return data_result.err<<integer>>("tag is not a long")
    end

    return data_result.ok(value.value :: integer)
end

function nbt_transcoder.get_f32(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_FLOAT then
        return data_result.err<<number>>("tag is not a float")
    end

    return data_result.ok(value.value :: number)
end

function nbt_transcoder.get_f64(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_DOUBLE then
        return data_result.err<<number>>("tag is not a double")
    end

    return data_result.ok(value.value :: number)
end

function nbt_transcoder.get_boolean(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_BYTE then
        return data_result.err<<boolean>>("tag is not a byte")
    end

    return data_result.ok(value.value == 1)
end

function nbt_transcoder.get_dictionary(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_COMPOUND then
        return data_result.err<<Dictionary<Tag<unknown>>>>("tag is not a compound")
    end

    const result: { [string]: Tag<unknown> } = table.create(#value.value :: any) :: any
    for idx, entry: NamedTag<unknown> in value.value :: any do
        result[entry.name] = entry.tag
    end

    return data_result.ok(result :: any)
end

function nbt_transcoder.get_array(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_LIST then
        return data_result.err<<{ Tag<unknown> }>>("tag is not a list")
    end

    const result: { Tag<unknown> } = table.create(#value.value :: any) :: any
    for idx, entry in value.value :: any do
        table.insert(result, entry)
    end

    return data_result.ok(result)
end

function nbt_transcoder.get_i8_array(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_BYTE_ARRAY then
        return data_result.err<<{ number }>>("tag is not a byte array")
    end

    return data_result.ok(value.value :: { number })
end

function nbt_transcoder.get_i32_array(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_INT_ARRAY then
        return data_result.err<<{ number }>>("tag is not an integer array")
    end

    return data_result.ok(value.value :: { number })
end

function nbt_transcoder.get_i64_array(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.TAG_LONG_ARRAY then
        return data_result.err<<{ integer }>>("tag is not a long array")
    end

    return data_result.ok(value.value :: { integer })
end

return transcoder.impl(nbt_transcoder)

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
