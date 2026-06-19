--!optimize 2

const data_result = require("@moonstone/codec/data_result")

type DataResult<T> = data_result.DataResult<T>

export type Transcoder<T> = {
    __index: Transcoder<T>,
    create_nil: (self: Transcoder<T>) -> T,
    create_string: (self: Transcoder<T>, value: string) -> T,
    create_i8: (self: Transcoder<T>, value: number) -> T,
    create_i16: (self: Transcoder<T>, value: number) -> T,
    create_i32: (self: Transcoder<T>, value: number) -> T,
    create_i64: (self: Transcoder<T>, value: integer) -> T,
    create_f32: (self: Transcoder<T>, value: number) -> T,
    create_f64: (self: Transcoder<T>, value: number) -> T,
    create_boolean: (self: Transcoder<T>, value: boolean) -> T,
    create_dictionary: (self: Transcoder<T>, value: { read [string]: T }) -> T,
    create_array: (self: Transcoder<T>, value: { T }) -> T,
    create_i8_array: (self: Transcoder<T>, value: { number }) -> T,
    create_i32_array: (self: Transcoder<T>, value: { number }) -> T,
    create_i64_array: (self: Transcoder<T>, value: { integer }) -> T,
    get_string: (self: Transcoder<T>, value: T) -> DataResult<string>,
    get_i8: (self: Transcoder<T>, value: T) -> DataResult<number>,
    get_i16: (self: Transcoder<T>, value: T) -> DataResult<number>,
    get_i32: (self: Transcoder<T>, value: T) -> DataResult<number>,
    get_i64: (self: Transcoder<T>, value: T) -> DataResult<integer>,
    get_f32: (self: Transcoder<T>, value: T) -> DataResult<number>,
    get_f64: (self: Transcoder<T>, value: T) -> DataResult<number>,
    get_boolean: (self: Transcoder<T>, value: T) -> DataResult<boolean>,
    get_dictionary: (self: Transcoder<T>, value: T) -> DataResult<{ read [string]: T }>,
    get_array: (self: Transcoder<T>, value: T) -> DataResult<{ T }>,
    get_i8_array: (self: Transcoder<T>, value: T) -> DataResult<{ number }>,
    get_i32_array: (self: Transcoder<T>, value: T) -> DataResult<{ number }>,
    get_i64_array: (self: Transcoder<T>, value: T) -> DataResult<{ integer }>,
}

export function impl<T>(t: Transcoder<T>): Transcoder<T>
    return table.freeze(setmetatable({}, t) :: any)
end

export function check<T>(value: unknown, expected: string): DataResult<T>
    if type(value) ~= expected then
        return data_result.err(`{tostring(value)} is not a(n) {expected}`)
    end
    return data_result.ok(value)
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
