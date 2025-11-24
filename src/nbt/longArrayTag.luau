--!optimize 2
--!strict

local tags = require("./tags")

local longArrayTag = {} :: tags.ArrayTagOps<number>
longArrayTag.__index = longArrayTag

export type LongArrayTag = typeof(setmetatable({} :: tags.Tag<{ number }>, longArrayTag))

function longArrayTag.create(value)
    return setmetatable({
        value = value,
        id = tags.LONG_ARRAY,
    }, longArrayTag)
end

function longArrayTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.LONG_ARRAY,
        name = name,
    }, longArrayTag)
end

function longArrayTag.read(buf)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readLong()
    end

    return longArrayTag.create(res)
end

function longArrayTag.write(buf, instance)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putLong(value)
    end
end

function longArrayTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readLong()
    end

    return longArrayTag.createNamed(res, name)
end

function longArrayTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putLong(value)
    end
end

function longArrayTag.clear(self)
    table.clear(self.value)
end

function longArrayTag.set(self, index, value)
    self.value[index] = value
end

function longArrayTag.add(self, value)
    table.insert(self.value, value)
end

function longArrayTag.remove(self, index)
    return table.remove(self.value)
end

return longArrayTag

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
