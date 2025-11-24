--!optimize 2
--!strict

local endTag = require("./endTag")
local tags = require("./tags")
local tagIO = require("./tagIO")

local EMPTY_LIST_EXPECTS = -1

local listTag = {} :: tags.ArrayTagOps<tags.Tag<any>>
listTag.__index = listTag

export type ListTag = typeof(setmetatable({} :: tags.Tag<any> & { expects: number }, listTag))

local function getFirstTagId(tags: { tags.Tag<any> }): number
    if #tags == 0 then
        return EMPTY_LIST_EXPECTS
    end

    return tags[1].id
end

function listTag.create(value): ListTag
    return setmetatable({
        value = value,
        id = tags.LIST,
        expects = getFirstTagId(value),
    }, listTag)
end

function listTag.createNamed(value, name): ListTag
    return setmetatable({
        value = value,
        id = tags.LIST,
        name = name,
        expects = getFirstTagId(value),
    }, listTag)
end

function listTag.read(buf)
    local expects = buf:readByte()
    local length = buf:readInt()

    if length <= 0 then
        return listTag.create({ endTag.create() })
    end

    local res = table.create(length) :: { tags.Tag<any> }
    for i = 1, length do
        res[i] = tagIO.TAG_OPS_TABLE[expects]().read(buf)
    end

    return listTag.create(res)
end

function listTag.write(buf, instance)
    buf:putByte((instance :: any).expects)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        tagIO.TAG_OPS_TABLE[value.id]().write(buf, value)
    end
end

function listTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local expects = buf:readByte()
    local length = buf:readInt()

    if length <= 0 then
        return listTag.createNamed({ endTag.create() }, name)
    end

    local res = table.create(length) :: { tags.Tag<any> }
    for i = 1, length do
        res[i] = tagIO.TAG_OPS_TABLE[expects]().read(buf)
    end

    return listTag.createNamed(res, name)
end

function listTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putByte((instance :: any).expects)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        tagIO.TAG_OPS_TABLE[value.id]().write(buf, value)
    end
end

function listTag.clear(self)
    table.clear(self.value)
end

function listTag.set(self, index, value)
    if (self :: any).expects == EMPTY_LIST_EXPECTS then
        (self :: any).expects = value.id
        self.value[index] = value
        return
    end

    assert((self :: any).expects == value.id, "value type mismatch")

    self.value[index] = value
end

function listTag.add(self, value)
    if (self :: any).expects == EMPTY_LIST_EXPECTS then
        (self :: any).expects = value.id
        table.insert(self.value, value)
        return
    end

    assert((self :: any).expects == value.id, "value type mismatch")

    table.insert(self.value, value)
end

function listTag.remove(self, index)
    return table.remove(self.value, index)
end

return listTag

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
