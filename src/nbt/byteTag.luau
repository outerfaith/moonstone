--!optimize 2
--!strict

local tags = require("./tags")

local byteTag = {} :: tags.TagOps<number>
byteTag.__index = byteTag

export type ByteTag = typeof(setmetatable({} :: tags.Tag<number>, byteTag))

function byteTag.create(value)
    return setmetatable({
        value = value,
        id = tags.BYTE,
    }, byteTag)
end

function byteTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.BYTE,
        name = name,
    }, byteTag)
end

function byteTag.read(buf)
    return byteTag.create(buf:readByte())
end

function byteTag.write(buf, instance)
    buf:putByte(instance.value)
end

function byteTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readByte()

    return byteTag.createNamed(payload, name)
end

function byteTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putByte(instance.value)
end

return byteTag

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
