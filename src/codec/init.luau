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

export function validate<T>(codec: Codec<T>, check: (T) -> DataResult<T>): Codec<T>
    return flat_xmap(codec, check, check)
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
