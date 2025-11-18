--!optimize 2
--!native
--!strict

local dataResult = require("@self/dataResult")
local transcoder = require("@self/transcoder")
local supplier = require("./util/supplier")

local codec = {}
codec.__index = codec

export type Codec<T> = typeof(setmetatable(
    {} :: {
        encode: <D>(transcoder.Transcoder<D>, T?) -> dataResult.DataResult<D>,
        decode: <D>(transcoder.Transcoder<D>, D) -> dataResult.DataResult<T>,
    },
    codec
))

function codec.new<T, D>(
    encode: (transcoder.Transcoder<D>, T?) -> dataResult.DataResult<D>,
    decode: (transcoder.Transcoder<D>, D) -> dataResult.DataResult<T>
): Codec<T>
    return setmetatable({
        encode = encode,
        decode = decode,
    }, codec)
end

function codec.recursive<T, D>(wrapped: (Codec<T>) -> Codec<T>): Codec<T>
    local codec1: Codec<T>? = nil
    local get = supplier.memoize(function()
        assert(codec1 ~= nil, "wrapped codec has not been initialized yet")
        return wrapped(codec1 :: Codec<T>)
    end) :: () -> Codec<T>

    codec1 = codec.new(function(transcoder: transcoder.Transcoder<D>, value: T?)
        return get().encode(transcoder, value)
    end, function(transcoder: transcoder.Transcoder<D>, value: D)
        return get().decode(transcoder, value)
    end)

    return codec1
end

function codec.comap<T, U, D>(self: Codec<T>, mapper: (U) -> T): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return self.encode(transcoder, mapper(value))
    end, self.decode :: any)
end

function codec.flatComap<T, U, D>(self: Codec<T>, mapper: (U) -> Codec<T>): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return mapper(value).encode(transcoder, value)
    end, self.decode :: any)
end

function codec.map<T, U, D>(self: Codec<T>, mapper: (T) -> U): Codec<U>
    return codec.new(self.encode :: any, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):map(mapper)
    end)
end

function codec.flatMap<T, U, D>(self: Codec<T>, mapper: (T) -> Codec<U>): Codec<U>
    return codec.new(self.encode :: any, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):flatMap(function(v: T)
            return mapper(v).decode(transcoder, value)
        end)
    end)
end

function codec.comapFlatMap<T, U, D>(
    self: Codec<T>,
    to: (T) -> dataResult.DataResult<U>,
    from: (U) -> T
): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return self.encode(transcoder, from(value))
    end, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):flatMap(to)
    end)
end

function codec.flatComapMap<T, U, D>(self: Codec<T>, to: (T) -> U, from: (U) -> Codec<T>): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return from(value).encode(transcoder, value)
    end, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):map(to)
    end)
end

function codec.xmap<T, U, D>(self: Codec<T>, to: (T) -> U, from: (U) -> T): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return self.encode(transcoder, from(value))
    end, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):map(to)
    end)
end

function codec.flatXmap<T, U, D>(
    self: Codec<T>,
    to: (T) -> dataResult.DataResult<U>,
    from: (U) -> dataResult.DataResult<T>
): Codec<U>
    return codec.new(function(transcoder: transcoder.Transcoder<D>, value: U)
        return from(value):flatMap(function(v)
            return self.encode(transcoder, v)
        end)
    end, function(transcoder: transcoder.Transcoder<D>, value: D)
        return self.decode(transcoder, value):flatMap(to)
    end)
end

function codec.validate<T>(self: Codec<T>, checker: (T) -> dataResult.DataResult<T>): Codec<T>
    return self:flatXmap(checker, checker)
end

return codec

--[[
   Copyright 2025 Outerfaith
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
