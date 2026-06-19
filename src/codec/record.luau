--!optimize 2

const codec = require("@moonstone/codec")
const data_result = require("@moonstone/codec/data_result")

type Codec<T> = codec.Codec<T>
type DataResult<T> = data_result.DataResult<T>

export type Field<T> = {
    read name: string,
    read codec: Codec<T>,
    read optional: boolean,
    read default: T?,
}

type RecordCodecProto<T> = {
    __index: RecordCodecProto<T>,
    field: <C>(self: RecordCodec<T>, name: string, codec: Codec<C>) -> RecordCodec<T>,
    optional: <C>(self: RecordCodec<T>, name: string, codec: Codec<C>, default: C?) -> RecordCodec<T>,
    build: (self: RecordCodec<T>) -> Codec<T>,
}

export type RecordCodec<T> = setmetatable<{
    read fields: { Field<unknown> },
}, RecordCodecProto<T>>

const record_codec = {} :: RecordCodec<unknown>
record_codec.__index = record_codec

export function new<T>(): RecordCodec<T>
    return table.freeze(setmetatable({ fields = {} }, record_codec) :: any)
end

const function new_field<T>(name: string, codec: Codec<T>, optional: boolean, default: T?): Field<T>
    return table.freeze({
        name = name,
        codec = codec,
        optional = optional,
        default = default
    })
end

function record_codec.field<C>(self, name, codec)
    table.insert(self.fields, new_field<<C>>(name, codec, false))

    return self
end

function record_codec.optional<C>(self, name, codec, default)
    table.insert(self.fields, new_field<<C>>(name, codec, true, default))

    return self
end

function record_codec.build(self)
    return codec.new<<unknown>>(function(transcoder, value: any)
        if type(value) ~= "table" then
            return data_result.err("value is not a table")
        end

        const dict = {}
        for idx, field in self.fields do
            if value[field.name] == nil and field.optional then
                if field.default ~= nil then 
                    dict[field.name] = field.default :: any
                end
                continue
            elseif value[field.name] == nil then
                return data_result.err(`required field '{field.name}' is not present`)
            end

            const result = field.codec.encode<<unknown>>(transcoder, value[field.name])
            if result:is_error() then
                return data_result.err(`failed to encode field '{field.name}': {result.msg}`)
            end

            dict[field.name] = result.value
        end

        return data_result.ok<<unknown>>(transcoder:create_dictionary(dict))
    end, function(transcoder, value)
        const dict = transcoder:get_dictionary(value)
        if dict:is_error() then
            return dict :: any
        end
        assert(dict.value ~= nil, "unreachable")

        const decoded = {}
        for idx, field in self.fields do
            const encoded_field = dict.value[field.name]
            if encoded_field == nil then
                if field.optional then
                    if field.default ~= nil then 
                        decoded[field.name] = field.default
                    end
                    continue
                end

                return data_result.err(`required field '{field.name}' is not present`)
            end

            const result = field.codec.decode<<unknown>>(transcoder, encoded_field)
            if result:is_error() then
                return result
            end

            decoded[field.name] = result.value
        end

        return data_result.ok<<unknown>>(decoded)
    end)
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
