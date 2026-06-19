--!optimize 2

const tag_ops = require("@moonstone/nbt/tag_ops")
const assertions = require("@moonstone/util/assertions")

export type Tag<T> = tag_ops.Tag<T>
export type ListTag<T> = tag_ops.ListTag<T>
export type NamedTag<T> = tag_ops.NamedTag<T>

export const TAG_END = 0x00
export const TAG_BYTE = 0x01
export const TAG_SHORT = 0x02
export const TAG_INT = 0x03
export const TAG_LONG = 0x04
export const TAG_FLOAT = 0x05
export const TAG_DOUBLE = 0x06
export const TAG_BYTE_ARRAY = 0x07
export const TAG_STRING = 0x08
export const TAG_LIST = 0x09
export const TAG_COMPOUND = 0x0A
export const TAG_INT_ARRAY = 0x0B
export const TAG_LONG_ARRAY = 0x0C

export function assert_tag_id(id: number)
    assert(id >= TAG_END and id <= TAG_LONG_ARRAY, `'{id}' is not a valid NBT tag id`)

    return id
end

export function tag<T>(id: number, value: T): Tag<T>
    return table.freeze({ id = id, value = value })
end

export function named<T>(name: string, tag: ListTag<T> | Tag<T>): NamedTag<T>
    return table.freeze({ name = name, tag = tag })
end

export function end_tag(): Tag<nil>
    return tag(TAG_END, nil)
end

export function byte(value: number): Tag<number>
    return tag(TAG_BYTE, assertions.is_i8(value))
end

export function short(value: number): Tag<number>
    return tag(TAG_SHORT, assertions.is_i16(value))
end

export function int(value: number): Tag<number>
    return tag(TAG_INT, assertions.is_i32(value))
end

export function long(value: integer): Tag<integer>
    return tag(TAG_LONG, value)
end

export function float(value: number): Tag<number>
    return tag(TAG_FLOAT, assertions.is_f32(value))
end

export function double(value: number): Tag<number>
    return tag(TAG_DOUBLE, assertions.is_f64(value))
end

export function byte_array(value: { number }): Tag<{ number }>
    return tag(TAG_BYTE_ARRAY, value)
end

export function str(value: string): Tag<string>
    return tag(TAG_STRING, value)
end

export function list<T>(value: { Tag<T> }, element_id: number?): ListTag<{ Tag<T> }>
    for idx, tag in value do
        assert(tag.id == element_id, "list tags must be homogeneous")
    end

    return table.freeze({ id = TAG_LIST, value = value, element_id = element_id })
end

export function compound(value: { NamedTag<any> }): Tag<{ NamedTag<any> }>
    return tag(TAG_COMPOUND, value)
end

export function int_array(value: { number }): Tag<{ number }>
    for idx, element in value do
        assertions.is_i32(element, "not an integer")
    end

    return tag(TAG_INT_ARRAY, value)
end

export function long_array(value: { integer }): Tag<{ integer }>
    return tag(TAG_LONG_ARRAY, value)
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
