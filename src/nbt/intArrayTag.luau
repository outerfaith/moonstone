--!optimize 2
--!strict

local tags = require("./tags")

local intArrayTag = {} :: tags.ArrayTagOps<number>
intArrayTag.__index = intArrayTag

export type IntArrayTag = typeof(setmetatable({} :: tags.Tag<{ number }>, intArrayTag))

function intArrayTag.create(value)
    return setmetatable({
        value = value,
        id = tags.INT_ARRAY,
    }, intArrayTag)
end

function intArrayTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.INT_ARRAY,
        name = name,
    }, intArrayTag)
end

function intArrayTag.read(buf)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readInt()
    end

    return intArrayTag.create(res)
end

function intArrayTag.write(buf, instance)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putInt(value)
    end
end

function intArrayTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readInt()
    end

    return intArrayTag.createNamed(res, name)
end

function intArrayTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putInt(value)
    end
end

function intArrayTag.clear(self)
    table.clear(self.value)
end

function intArrayTag.set(self, index, value)
    self.value[index] = value
end

function intArrayTag.add(self, value)
    table.insert(self.value, value)
end

function intArrayTag.remove(self, index)
    return table.remove(self.value)
end

return intArrayTag

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
