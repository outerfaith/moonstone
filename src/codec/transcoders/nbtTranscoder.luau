--!optimize 2
--!native
--!strict

local byteArrayTag = require("../../nbt/byteArrayTag")
local dataResult = require("../dataResult")
local transcoder = require("../transcoder")
local tags = require("../../nbt/tags")
local byteTag = require("../../nbt/byteTag")
local compoundTag = require("../../nbt/compoundTag")
local doubleTag = require("../../nbt/doubleTag")
local endTag = require("../../nbt/endTag")
local floatTag = require("../../nbt/floatTag")
local intArrayTag = require("../../nbt/intArrayTag")
local intTag = require("../../nbt/intTag")
local listTag = require("../../nbt/listTag")
local longArrayTag = require("../../nbt/longArrayTag")
local longTag = require("../../nbt/longTag")
local shortTag = require("../../nbt/shortTag")
local stringTag = require("../../nbt/stringTag")

local nbtTranscoder = {} :: transcoder.Transcoder<tags.Tag<any>?>
nbtTranscoder.__index = nbtTranscoder

local function create()
    return table.freeze(setmetatable({}, nbtTranscoder)) :: transcoder.Transcoder<tags.Tag<any>?>
end

function nbtTranscoder.createEmpty(self)
    return endTag.create()
end

function nbtTranscoder.getBoolean(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.BYTE then
        return dataResult.err(`Tag is not a boolean`)
    end
    return dataResult.ok(value.value == 1)
end

function nbtTranscoder.createBoolean(self, value)
    return byteTag.create(value and 1 or 0)
end

function nbtTranscoder.getByte(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.BYTE then
        return dataResult.err(`Tag is not a byte`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createByte(self, value)
    return byteTag.create(value)
end

function nbtTranscoder.getShort(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.SHORT then
        return dataResult.err(`Tag is not a short`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createShort(self, value)
    return shortTag.create(value)
end

function nbtTranscoder.getInt(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.INT then
        return dataResult.err(`Tag is not an int`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createInt(self, value)
    return intTag.create(value)
end

function nbtTranscoder.getLong(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.LONG then
        return dataResult.err(`Tag is not a long`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createLong(self, value)
    return longTag.create(value)
end

function nbtTranscoder.getFloat(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.FLOAT then
        return dataResult.err(`Tag is not a float`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createFloat(self, value)
    return floatTag.create(value)
end

function nbtTranscoder.getDouble(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.DOUBLE then
        return dataResult.err(`Tag is not a double`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createDouble(self, value)
    return doubleTag.create(value)
end

function nbtTranscoder.getString(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.STRING then
        return dataResult.err(`Tag is not a string`)
    end
    return dataResult.ok(value.value)
end

function nbtTranscoder.createString(self, value)
    return stringTag.create(value)
end

function nbtTranscoder.getList(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.LIST then
        return dataResult.err("Tag is not a list")
    end
    return value.value
end

function nbtTranscoder.createList(self, size)
    local list = table.create(size)
    local builder = {}
    builder.__index = builder

    function builder.add(self, value)
        table.insert(list, value)
        return self
    end

    function builder.build(self)
        return listTag.create(list :: any)
    end

    return setmetatable({}, builder) :: any
end

function nbtTranscoder.createEmptyList(self)
    return self:createList(0):build()
end

function nbtTranscoder.getMap(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.COMPOUND then
        return dataResult.err("Tag is not a compound")
    end

    local map = {}
    map.__index = map

    function map.keys(self)
        local res = {}
        for key, v in value.value do
            table.insert(res, key)
        end
        return res
    end

    function map.contains(self, key)
        return value.value[key] ~= nil
    end

    function map.get(self, key)
        if value.value[key] == nil then
            return dataResult.err(`No such key: '{key}'`)
        end
        return dataResult.ok(value.value[key])
    end

    return dataResult.ok(setmetatable({}, map))
end

function nbtTranscoder.createMap(self)
    local compound = compoundTag.create({}) :: any
    local builder = {}
    builder.__index = builder

    function builder.put(self, key, value)
        assert(type(key) == "string", "map key must be a string")

        compound:put(key, value)
        return self
    end

    function builder.build(self)
        return compound
    end

    return setmetatable({}, builder) :: any
end

function nbtTranscoder.createEmptyMap(self)
    return compoundTag.create({})
end

function nbtTranscoder.getByteArray(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.BYTE_ARRAY then
        return dataResult.err("Tag is not a byte array")
    end
    return value.value
end

function nbtTranscoder.createByteArray(self, value)
    return byteArrayTag.create(value)
end

function nbtTranscoder.getIntArray(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.INT_ARRAY then
        return dataResult.err("Tag is not an int array")
    end
    return value.value
end

function nbtTranscoder.createIntArray(self, value)
    return intArrayTag.create(value)
end

function nbtTranscoder.getLongArray(self, value)
    assert(value ~= nil, "value cannot be nil")
    if value.id ~= tags.LONG_ARRAY then
        return dataResult.err("Tag is not a long array")
    end
    return value.value
end

function nbtTranscoder.createLongArray(self, value)
    return longArrayTag.create(value)
end

return create()

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
