--!optimize 2
--!native

local codec = require("@self")
local dataResult = require("./dataResult")

local BOOLEAN = codec.new(function(t, v)
    return dataResult.ok(t:createBoolean(v))
end, function(t, d)
    return t:getBoolean(d)
end)

local BYTE = codec.new(function(t, v)
    return dataResult.ok(t:createByte(v))
end, function(t, d)
    return t:getByte(d)
end)

local SHORT = codec.new(function(t, v)
    return dataResult.ok(t:createShort(v))
end, function(t, d)
    return t:getShort(d)
end)

local INT = codec.new(function(t, v)
    return dataResult.ok(t:createInt(v))
end, function(t, d)
    return t:getInt(d)
end)

local LONG = codec.new(function(t, v)
    return dataResult.ok(t:createLong(v))
end, function(t, d)
    return t:getLong(d)
end)

local FLOAT = codec.new(function(t, v)
    return dataResult.ok(t:createFloat(v))
end, function(t, d)
    return t:getFloat(d)
end)

local DOUBLE = codec.new(function(t, v)
    return dataResult.ok(t:createDouble(v))
end, function(t, d)
    return t:getDouble(d)
end)

local STRING = codec.new(function(t, v)
    return dataResult.ok(t:createString(v))
end, function(t, d)
    return t:getString(d)
end)

local LIST = codec.new(function(t, v)
    local list = t:createList(#v)
    for idx, value in v do
        list:add(value)
    end
    return dataResult.ok(list:build())
end, function(t, d)
    return t:getList(d)
end)

local MAP = codec.new(function(t, v)
    local map = t:createMap()
    for key, value in v do
        map:put(key, value)
    end
    return dataResult.ok(map:build())
end, function(t, d)
    return t:getMap(d)
end)

local BYTE_ARRAY = codec.new(function(t, v)
    return dataResult.ok(t:createByteArray(v))
end, function(t, d)
    return t:getByteArray(d)
end)

local INT_ARRAY = codec.new(function(t, v)
    return dataResult.ok(t:createIntArray(v))
end, function(t, d)
    return t:getIntArray(d)
end)

local LONG_ARRAY = codec.new(function(t, v)
    return dataResult.ok(t:createLongArray(v))
end, function(t, d)
    return t:getLongArray(d)
end)

return table.freeze({
    BOOLEAN = BOOLEAN,
    BYTE = BYTE,
    SHORT = SHORT,
    INT = INT,
    LONG = LONG,
    FLOAT = FLOAT,
    DOUBLE = DOUBLE,
    STRING = STRING,
    LIST = LIST,
    MAP = MAP,
    BYTE_ARRAY = BYTE_ARRAY,
    INT_ARRAY = INT_ARRAY,
    LONG_ARRAY = LONG_ARRAY,
})

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
