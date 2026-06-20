--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec")
const arrays = require("@moonstone/network/buffer_codec/arrays")
const primitive_codecs = require("@moonstone/network/buffer_codec/primitives")
const string_codecs = require("@moonstone/network/buffer_codec/string")
const variable_sized = require("@moonstone/network/buffer_codec/variable_sized")

export type BufferCodec<T> = buffer_codec.BufferCodec<T>

const function unit<T>()
    return buffer_codec.new(function(buf)
        return nil :: T
    end, function() end)
end

const function struct<T>(t: { { string | BufferCodec<unknown> } }): BufferCodec<T>
    return buffer_codec.new(function(buf)
        const result = {}
        for idx, entry in ipairs(t) do
            const name = entry[2] :: string
            const codec = entry[1] :: BufferCodec<unknown>

            const read = codec:read(buf)

            result[name] = read
        end

        return result
    end, function(buf, v)
        for idx, entry in ipairs(t) do
            const name = entry[2] :: string
            const codec = entry[1] :: BufferCodec<unknown>

            const value = (v :: { read [string]: unknown })[name]

            codec:write(buf, value)
        end
    end)
end

return table.freeze({
    BOOLEAN = primitive_codecs.BOOLEAN,
    BYTE = primitive_codecs.BYTE,
    UNSIGNED_BYTE = primitive_codecs.UNSIGNED_BYTE,
    SHORT = primitive_codecs.SHORT,
    UNSIGNED_SHORT = primitive_codecs.UNSIGNED_SHORT,
    INT = primitive_codecs.INT,
    LONG = primitive_codecs.LONG,
    FLOAT = primitive_codecs.FLOAT,
    DOUBLE = primitive_codecs.DOUBLE,
    UNLIMITED_STRING = string_codecs.UNLIMITED,
    VAR_INT = variable_sized.VAR_INT,
    VAR_LONG = variable_sized.VAR_LONG,
    BYTE_ARRAY = arrays.BYTE_ARRAY,
    TERMINATING_BYTE_ARRAY = arrays.TERMINATING_BYTE_ARRAY,
    limited_string = string_codecs.limited,
    array = arrays.array,
    new = buffer_codec.new,
    unit = unit,
    struct = struct,
})

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
