--!optimize 2

const data_result = require("@moonstone/codec/data_result")
const transcoder = require("@moonstone/codec/transcoder")
const memo = require("@moonstone/util/memo")

type DataResult<T> = data_result.DataResult<T>
type Transcoder<T> = transcoder.Transcoder<T>

export type Codec<T> = {
    read encode: <D>(Transcoder<D>, T?) -> DataResult<D>,
    read decode: <D>(Transcoder<D>, D) -> DataResult<T>,
}

export function new<T, D>(
    encode: (Transcoder<D>, T?) -> DataResult<D>,
    decode: (Transcoder<D>, D) -> DataResult<T>
): Codec<T>
    return table.freeze({ encode = encode, decode = decode }) :: any
end

export function recursive<T, D>(apply: (Codec<T>) -> Codec<T>): Codec<T>
    local result: Codec<T>? = nil
    const getter = memo(function()
        assert(result ~= nil, "codec result has not yet been initialized")
        return apply(result)
    end)

    result = new(function(transcoder: Transcoder<D>, value)
        return getter().encode(transcoder, value)
    end, function(transcoder, value)
        return getter().decode(transcoder, value)
    end)

    return result
end

export function comap<T, U>(codec: Codec<T>, mapper: (U) -> T): Codec<U>
    return new(function(transcoder, value)
        return codec.encode(transcoder, mapper(value))
    end, codec.decode :: any)
end

export function flat_comap<T, U>(codec: Codec<T>, mapper: (U) -> Codec<T>): Codec<U>
    return new(function(transcoder, value)
        return mapper(value).encode(transcoder, value)
    end, codec.decode :: any)
end

export function map<T, U>(codec: Codec<T>, mapper: (T) -> U): Codec<U>
    return new(codec.encode, function(transcoder, value)
        return data_result.map(codec.decode(transcoder, value), mapper)
    end)
end

export function flat_map<T, U>(codec: Codec<T>, mapper: (T) -> Codec<U>): Codec<U>
    return new(codec.encode, function(transcoder, value)
        return data_result.flat_map(codec.decode(transcoder, value), function(v)
            return mapper(v).decode(transcoder, value)
        end)
    end)
end

export function comap_flat_map<T, U, D>(codec: Codec<T>, to: (T) -> DataResult<U>, from: (U) -> T): Codec<U>
    return new(function(transcoder: Transcoder<D>, value)
        return codec.encode(transcoder, from(value))
    end, function(transcoder, value)
        return data_result.flat_map(codec.decode(transcoder, value), to)
    end)
end

export function flat_comap_map<T, U, D>(codec: Codec<T>, to: (T) -> U, from: (U) -> Codec<T>): Codec<U>
    return new(function(transcoder: Transcoder<D>, value)
        return from(value).encode(transcoder, value)
    end, function(transcoder, value)
        return data_result.map(codec.decode(transcoder, value), to)
    end)
end

export function xmap<T, U, D>(codec: Codec<T>, to: (T) -> U, from: (U) -> T): Codec<U>
    return new(function(transcoder: Transcoder<D>, value)
        return codec.encode(transcoder, from(value))
    end, function(transcoder, value)
        return data_result.map(codec.decode(transcoder, value), to)
    end)
end

export function flat_xmap<T, U, D>(
    codec: Codec<T>,
    to: (T) -> DataResult<U>,
    from: (U) -> DataResult<T>
): Codec<U>
    return new(function(transcoder: Transcoder<D>, value)
        return data_result.flat_map(from(value), function(v)
            return codec.encode(transcoder, v)
        end)
    end, function(transcoder, value)
        return data_result.flat_map(codec.decode(transcoder, value), to)
    end)
end

export function union<T>(a: Codec<T>, b: Codec<T>): Codec<T>
    return new<<T>>(function(transcoder, value)
        const first = a.encode(transcoder, value)
        if first:is_success() then
            return first
        end

        return b.encode(transcoder, value)
    end, function(transcoder, value)
        const first = a.decode(transcoder, value)
        if first:is_success() then
            return first
        end

        return b.decode(transcoder, value)
    end)
end

export function list<T>(codec: Codec<T>): Codec<{T}>
    return new<<{T}, unknown>>(function(transcoder, value)
        assert(value ~= nil, "value cannot be nil")

        const encoded: { T } = table.create(#value)
        for idx, entry in value do 
            const result = codec.encode(transcoder, entry)
            if result:is_error() then
                return result
            end

            table.insert(encoded, result.value)
        end

        return data_result.ok(transcoder:create_array(encoded))
    end, function(transcoder, value)
        const array = transcoder:get_array(value)
        if array:is_error() then
            return array
        end

        const decoded = table.create(#array.value :: any)
        for idx, entry in array.value :: any do
            const result = codec.decode(transcoder, entry)
            if result:is_error() then
                return result
            end

            table.insert(decoded, result.value)
        end

        return data_result.ok(decoded)
    end)
end

export function validate<T>(codec: Codec<T>, check: (T) -> DataResult<T>): Codec<T>
    return flat_xmap(codec, check, check)
end

export const BOOLEAN = new<<boolean, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_boolean(value))
end, function(transcoder, result)
    return transcoder:get_boolean(result)
end)

export const BYTE = new<<number, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i8(value))
end, function(transcoder, result)
    return transcoder:get_i8(result)
end)

export const SHORT = new<<number, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i16(value))
end, function(transcoder, result)
    return transcoder:get_i16(result)
end)

export const INT = new<<number, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i32(value))
end, function(transcoder, result)
    return transcoder:get_i32(result)
end)

export const LONG = new<<integer, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i64(value))
end, function(transcoder, result)
    return transcoder:get_i64(result)
end)

export const FLOAT = new<<number, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_f32(value))
end, function(transcoder, result)
    return transcoder:get_f32(result)
end)

export const DOUBLE = new<<number, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_f64(value))
end, function(transcoder, result)
    return transcoder:get_f64(result)
end)

export const STRING = new<<string, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_string(value))
end, function(transcoder, result)
    return transcoder:get_string(result)
end)

export const BYTE_ARRAY = new<<{ number }, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i8_array(value))
end, function(transcoder, result)
    return transcoder:get_i8_array(result)
end)

export const INT_ARRAY = new<<{ number }, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i32_array(value))
end, function(transcoder, result)
    return transcoder:get_i32_array(result)
end)

export const LONG_ARRAY = new<<{ integer }, unknown>>(function(transcoder, value)
    assert(value ~= nil, "value cannot be nil")

    return data_result.ok(transcoder:create_i64_array(value))
end, function(transcoder, result)
    return transcoder:get_i64_array(result)
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
