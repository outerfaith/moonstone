--!optimize 2
--!strict

local tags = require("./tags")

local byteArrayTag = {} :: tags.ArrayTagOps<number>
byteArrayTag.__index = byteArrayTag

export type ByteArrayTag = typeof(setmetatable({} :: tags.Tag<{ number }>, byteArrayTag))

function byteArrayTag.create(value)
    return setmetatable({
        value = value,
        id = tags.BYTE_ARRAY,
    }, byteArrayTag)
end

function byteArrayTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.BYTE_ARRAY,
        name = name,
    }, byteArrayTag)
end

function byteArrayTag.read(buf)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readByte()
    end

    return byteArrayTag.create(res)
end

function byteArrayTag.write(buf, instance)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putByte(value)
    end
end

function byteArrayTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local length = buf:readInt()
    local res = table.create(length, 0)

    for i = 1, length do
        res[i] = buf:readByte()
    end

    return byteArrayTag.createNamed(res, name)
end

function byteArrayTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putInt(#instance.value)
    for idx, value in instance.value do
        buf:putByte(value)
    end
end

function byteArrayTag.clear(self)
    table.clear(self.value)
end

function byteArrayTag.set(self, index, value)
    self.value[index] = value
end

function byteArrayTag.add(self, value)
    table.insert(self.value, value)
end

function byteArrayTag.remove(self, index)
    return table.remove(self.value)
end

return byteArrayTag

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
