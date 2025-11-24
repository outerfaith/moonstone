--!optimize 2
--!strict

local tags = require("./tags")

local stringTag = {} :: tags.TagOps<string>
stringTag.__index = stringTag

export type StringTag = typeof(setmetatable({} :: tags.Tag<string>, stringTag))

function stringTag.create(value)
    return setmetatable({
        value = value,
        id = tags.STRING,
    }, stringTag)
end

function stringTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.STRING,
        name = name,
    }, stringTag)
end

function stringTag.read(buf)
    local payloadLen = buf:readUnsignedShort()
    local payload = buf:readString(payloadLen)

    return stringTag.create(payload)
end

function stringTag.write(buf, instance)
    buf:putUnsignedShort(string.len(instance.value))
    buf:putString(instance.value)
end

function stringTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payloadLen = buf:readUnsignedShort()
    local payload = buf:readString(payloadLen)

    return stringTag.createNamed(payload, name)
end

function stringTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putUnsignedShort(string.len(instance.value))
    buf:putString(instance.value)
end

return stringTag

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
