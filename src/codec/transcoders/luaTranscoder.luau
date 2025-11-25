--!optimize 2
--!native
--!strict

local dataResult = require("../dataResult")
local transcoder = require("../transcoder")

local INT_MIN_VALUE = -2 ^ 31
local INT_MAX_VALUE = 2 ^ 31 - 1
local LONG_MIN_VALUE = -2 ^ 53
local LONG_MAX_VALUE = 2 ^ 53
local FLOAT_MAX_VALUE = 3.4028235E38
local FLOAT_MIN_VALUE = -FLOAT_MAX_VALUE
local DOUBLE_MAX_VALUE = 1.7976931348623157E308
local DOUBLE_MIN_VALUE = -DOUBLE_MAX_VALUE

local luaTranscoder = {} :: transcoder.Transcoder<any>
luaTranscoder.__index = luaTranscoder

local function create()
    return table.freeze(setmetatable({}, luaTranscoder)) :: transcoder.Transcoder<any>
end

function luaTranscoder.createEmpty(self)
    return nil
end

function luaTranscoder.getBoolean(self, value)
    if type(value) ~= "boolean" then
        return dataResult.err(`'{tostring(value)}' is not a boolean`)
    end
    return dataResult.ok(value)
end

function luaTranscoder.createBoolean(self, value)
    assert(type(value) == "boolean", "value is not a boolean")
    return value
end

function luaTranscoder.getByte(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > 127 or value < -128 then
        return dataResult.err(`{value} is out of range for byte`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createByte(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(value <= 127 and value >= -128, `{value} is out of range for byte`)
    return value
end

function luaTranscoder.getShort(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > 32767 or value < -32768 then
        return dataResult.err(`{value} is out of range for short`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createShort(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(value <= 32767 and value >= -32768, `{value} is out of range for short`)
    return value
end

function luaTranscoder.getInt(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > INT_MAX_VALUE or value < INT_MIN_VALUE then
        return dataResult.err(`{value} is out of range for int`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createInt(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(value <= INT_MAX_VALUE and value >= INT_MIN_VALUE, `{value} is out of range for int`)
    return value
end

function luaTranscoder.getLong(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > LONG_MAX_VALUE or value < LONG_MIN_VALUE then
        return dataResult.err(`{value} is out of range for long (exceeds precision limit)`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createLong(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(
        value <= LONG_MAX_VALUE and value >= LONG_MIN_VALUE,
        `{value} is out of range for long (exceeds precision limit)`
    )
    return value
end

function luaTranscoder.getFloat(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > FLOAT_MAX_VALUE or value < FLOAT_MIN_VALUE then
        return dataResult.err(`{value} is out of range for float`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createFloat(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(
        value <= FLOAT_MAX_VALUE and value >= FLOAT_MIN_VALUE,
        `{value} is out of range for float`
    )
    return value
end

function luaTranscoder.getDouble(self, value)
    if type(value) ~= "number" then
        return dataResult.err(`'{tostring(value)}' is not a number`)
    end
    if value > DOUBLE_MAX_VALUE or value < DOUBLE_MIN_VALUE then
        return dataResult.err(`{value} is out of range for double`)
    end

    return dataResult.ok(value)
end

function luaTranscoder.createDouble(self, value)
    assert(type(value) == "number", "value is not a number")
    assert(
        value <= DOUBLE_MAX_VALUE and value >= DOUBLE_MIN_VALUE,
        `{value} is out of range for double`
    )
    return value
end

function luaTranscoder.getString(self, value)
    if type(value) ~= "string" then
        return dataResult.err(`'{tostring(value)}' is not a string`)
    end
    return dataResult.ok(value)
end

function luaTranscoder.createString(self, value)
    assert(type(value) == "string", "value is not a string")
    return value
end

function luaTranscoder.getList(self, value)
    if type(value) ~= "table" then
        return dataResult.err(`'{tostring(value)}' is not a list`)
    end
    for idx, v in value do
        if type(idx) ~= "number" then
            return dataResult.err("table contains non-numeric keys")
        end
    end
    return dataResult.ok(value)
end

function luaTranscoder.createList(self, size)
    local list = table.create(size)
    local builder = {}
    builder.__index = builder

    function builder.add(self, value)
        table.insert(list, value)
        return self
    end

    function builder.build(self)
        return list
    end

    return setmetatable({}, builder) :: any
end

function luaTranscoder.createEmptyList(self)
    return self:createList(0)
end

function luaTranscoder.getMap(self, value)
    if type(value) ~= "table" then
        return dataResult.err(`'{tostring(value)}' is not a map`)
    end
    for key, v in value do
        if type(key) ~= "string" then
            return dataResult.err("table contains non-string keys")
        end
    end

    local map = {}

    function map.keys(self)
        local res = {}
        for key, v in value do
            table.insert(res, key)
        end
        return res
    end

    function map.contains(self, key)
        return value[key] ~= nil
    end

    function map.get(self, key)
        if value[key] == nil then
            return dataResult.err(`No such key: '{key}'`)
        end
        return dataResult.ok(value[key])
    end

    return dataResult.ok(setmetatable({}, map))
end

function luaTranscoder.createMap(self)
    local map = {}
    local builder = {}

    function builder.put(self, key, value)
        assert(type(key) == "string", "map key must be a string")

        map[key] = value
        return self
    end

    function builder.build(self)
        return map
    end

    return setmetatable({}, builder) :: any
end

function luaTranscoder.createEmptyMap(self)
    return table.freeze({}) :: any
end

function luaTranscoder.getByteArray(self, value)
    if type(value) ~= "table" then
        return dataResult.err(`'{tostring(value)}' is not an array`)
    end
    for idx, v in value do
        if type(idx) ~= "number" then
            return dataResult.err("table contains non-numeric keys")
        end
        if type(v) ~= "number" then
            return dataResult.err("table contains non-numeric values")
        end
        if v > 127 or v < -128 then
            return dataResult.err(`value at index '{idx}' is not within range for byte`)
        end
    end
    return dataResult.ok(value)
end

function luaTranscoder.createByteArray(self, value)
    assert(type(value) == "table", "value must be a table")
    for idx, v in value do
        assert(type(idx) == "number", "value contains non-numeric keys")
        assert(type(v) == "number", "table contains non-numeric values")
        assert(v <= 127 and v >= -128, `value at index '{idx}' is not within range for byte`)
    end
    return value
end

function luaTranscoder.getIntArray(self, value)
    if type(value) ~= "table" then
        return dataResult.err(`'{tostring(value)}' is not an array`)
    end
    for idx, v in value do
        if type(idx) ~= "number" then
            return dataResult.err("table contains non-numeric keys")
        end
        if type(v) ~= "number" then
            return dataResult.err("table contains non-numeric values")
        end
        if v > INT_MAX_VALUE or v < INT_MIN_VALUE then
            return dataResult.err(`value at index '{idx}' is not within range for int`)
        end
    end
    return dataResult.ok(value)
end

function luaTranscoder.createIntArray(self, value)
    assert(type(value) == "table", "value must be a table")
    for idx, v in value do
        assert(type(idx) == "number", "value contains non-numeric keys")
        assert(type(v) == "number", "table contains non-numeric values")
        assert(
            v <= INT_MAX_VALUE and v >= INT_MIN_VALUE,
            `value at index '{idx}' is not within range for int`
        )
    end
    return value
end

function luaTranscoder.getLongArray(self, value)
    if type(value) ~= "table" then
        return dataResult.err(`'{tostring(value)}' is not an array`)
    end
    for idx, v in value do
        if type(idx) ~= "number" then
            return dataResult.err("table contains non-numeric keys")
        end
        if type(v) ~= "number" then
            return dataResult.err("table contains non-numeric values")
        end
        if v > LONG_MAX_VALUE or v < LONG_MIN_VALUE then
            return dataResult.err(`value at index '{idx}' is not within range for long`)
        end
    end
    return dataResult.ok(value)
end

function luaTranscoder.createLongArray(self, value)
    assert(type(value) == "table", "value must be a table")
    for idx, v in value do
        assert(type(idx) == "number", "value contains non-numeric keys")
        assert(type(v) == "number", "table contains non-numeric values")
        assert(
            v <= LONG_MAX_VALUE and v >= LONG_MIN_VALUE,
            `value at index '{idx}' is not within range for long`
        )
    end
    return value
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
