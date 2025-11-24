--!optimize 2

local byteArrayTag = require("./byteArrayTag")
local endTag = require("./endTag")
local byteTag = require("./byteTag")
local doubleTag = require("./doubleTag")
local floatTag = require("./floatTag")
local intArrayTag = require("./intArrayTag")
local intTag = require("./intTag")
local longArrayTag = require("./longArrayTag")
local longTag = require("./longTag")
local shortTag = require("./shortTag")
local stringTag = require("./stringTag")
local tags = require("./tags")
local tagIO = require("./tagIO")

local compoundTag = {} :: tags.MapTagOps
compoundTag.__index = compoundTag

export type CompoundTag = typeof(setmetatable(
    {} :: tags.Tag<{ [string]: tags.Tag<any> }>,
    compoundTag
))

function compoundTag.create(value): CompoundTag
    return setmetatable({
        value = value,
        id = tags.COMPOUND,
    }, compoundTag)
end

function compoundTag.createNamed(value, name): CompoundTag
    return setmetatable({
        value = value,
        id = tags.COMPOUND,
        name = name,
    }, compoundTag)
end

function compoundTag.read(buf)
    local values = {}

    while true do
        local t = buf:readByte()
        if t == tags.END then
            break
        end

        local keyLength = buf:readUnsignedShort()
        local key = buf:readString(keyLength)

        assert(values[key] == nil, `Key '{key}' has already been read`)

        local opsSupplier = tagIO.TAG_OPS_TABLE[t]
        assert(opsSupplier ~= nil, `no TagOps found for type {t}`)

        local ops = opsSupplier()

        values[key] = ops.read(buf)
    end

    return compoundTag.create(values)
end

function compoundTag.write(buf, instance)
    for key, value in instance.value do
        tagIO.write(buf, value, true)
    end

    tagIO.write(buf, endTag.create())
end

function compoundTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local values = {}

    while true do
        local t = buf:readByte()
        if t == tags.END then
            break
        end

        local keyLength = buf:readUnsignedShort()
        local key = buf:readString(keyLength)

        assert(values[key] == nil, `Key '{key}' has already been read`)

        local opsSupplier = tagIO.TAG_OPS_TABLE[t]
        assert(opsSupplier ~= nil, `no TagOps found for type {t}`)

        local ops = opsSupplier()

        values[key] = ops.read(buf)
    end

    return compoundTag.createNamed(values, name)
end

function compoundTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)

    for key, value in instance.value do
        tagIO.write(buf, value, true)
    end

    tagIO.write(buf, endTag.create())
end

function compoundTag.clear(self)
    table.clear(self.value)
end

function compoundTag.contains(self, key)
    return self.value[key] ~= nil
end

function compoundTag.copy(self)
    return compoundTag.createNamed(table.clone(self.value), (self :: tags.NamedTag<any>).name)
end

function compoundTag.put(self, key, value)
    assert(self.value[key] == nil, `Key '{key}' has already been assigned a value`)
    assert(value ~= nil, "value cannot be nil")

    self.value[key] = value
end

function compoundTag.putByte(self, key, value)
    self:put(key, byteTag.createNamed(value, key))
end

function compoundTag.putShort(self, key, value)
    self:put(key, shortTag.createNamed(value, key))
end

function compoundTag.putInt(self, key, value)
    self:put(key, intTag.createNamed(value, key))
end

function compoundTag.putLong(self, key, value)
    self:put(key, longTag.createNamed(value, key))
end

function compoundTag.putFloat(self, key, value)
    self:put(key, floatTag.createNamed(value, key))
end

function compoundTag.putDouble(self, key, value)
    self:put(key, doubleTag.createNamed(value, key))
end

function compoundTag.putString(self, key, value)
    self:put(key, stringTag.createNamed(value, key))
end

function compoundTag.putByteArray(self, key, value)
    self:put(key, byteArrayTag.createNamed(value, key))
end

function compoundTag.putIntArray(self, key, value)
    self:put(key, intArrayTag.createNamed(value, key))
end

function compoundTag.putLongArray(self, key, value)
    self:put(key, longArrayTag.createNamed(value, key))
end

function compoundTag.putBoolean(self, key, value)
    self:putByte(key, value and 1 or 0)
end

function compoundTag.get(self, key)
    return self.value[key]
end

function compoundTag.getByte(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.BYTE, "not a byte tag")

    return tag.value
end

function compoundTag.getInt(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.INT, "not an int tag")

    return tag.value
end

function compoundTag.getLong(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.LONG, "not a long tag")

    return tag.value
end

function compoundTag.getFloat(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.FLOAT, "not a float tag")

    return tag.value
end

function compoundTag.getDouble(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.DOUBLE, "not a double tag")

    return tag.value
end

function compoundTag.getString(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.STRING, "not a string tag")

    return tag.value
end

function compoundTag.getByteArray(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.BYTE_ARRAY, "not a byte array tag")

    return tag.value
end

function compoundTag.getIntArray(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.INT_ARRAY, "not an int array tag")

    return tag.value
end

function compoundTag.getLongArray(self, key)
    local tag = self:get(key)
    if tag == nil then
        return nil
    end

    assert(tag.id == tags.LONG_ARRAY, "not a long array tag")

    return tag.value
end

function compoundTag.getBoolean(self, key)
    local byte = self:getByte(key)
    if byte == nil then
        return nil
    end

    return byte ~= 0
end

return compoundTag

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
