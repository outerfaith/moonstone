--!optimize 2
--!native

local codec = require("./")
local dataResult = require("./dataResult")

local structCodec = {}
structCodec.__index = structCodec

export type StructCodec = typeof(setmetatable(
    {} :: {
        read fields: { { name: string, codec: codec.Codec<any>, optional: boolean } },
    },
    structCodec
))

function structCodec.new(): StructCodec
    return table.freeze(setmetatable({ fields = {} }, structCodec))
end

function structCodec.requiredField(
    self: StructCodec,
    name: string,
    codec: codec.Codec<any>
): StructCodec
    table.insert(self.fields :: any, table.freeze({ name = name, codec = codec, optional = false }))
    return self
end

function structCodec.optionalField(
    self: StructCodec,
    name: string,
    codec: codec.Codec<any>
): StructCodec
    table.insert(self.fields :: any, table.freeze({ name = name, codec = codec, optional = true }))
    return self
end

function structCodec.build(self: StructCodec): codec.Codec<{ [string]: any }>
    return codec.new(function(t, value)
        local encoded = t:createMap()
        for idx, field in self.fields do
            if value[field.name] == nil and field.optional then
                continue
            elseif value[field.name] == nil then
                return dataResult.err(`Required field '{field.name}' is not present`)
            end
            local result = field.codec.encode(t, value[field.name])
            if result:isError() then
                return dataResult.err(`Failed to encode field '{field.name}': {result.msg}`)
            end
            encoded:put(field.name, result.value)
        end
        return dataResult.ok(encoded:build())
    end, function(t, data)
        local encoded = t:getMap(data)
        if encoded:isError() then
            return encoded
        end
        encoded = encoded.value
        local decoded = {}
        for idx, field in self.fields do
            local r = encoded:get(field.name)
            if r:isError() then
                if field.optional then
                    continue
                else
                    return r
                end
            end
            local res = field.codec.decode(t, r.value)
            if res:isError() then
                return res
            end
            decoded[field.name] = res.value
        end
        return dataResult.ok(decoded)
    end)
end

return structCodec

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
