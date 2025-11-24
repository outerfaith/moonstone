--!optimize 2
--!strict

local tags = require("./tags")

local shortTag = {} :: tags.TagOps<number>
shortTag.__index = shortTag

export type ShortTag = typeof(setmetatable({} :: tags.Tag<number>, shortTag))

function shortTag.create(value)
    return setmetatable({
        value = value,
        id = tags.SHORT,
    }, shortTag)
end

function shortTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.SHORT,
        name = name,
    }, shortTag)
end

function shortTag.read(buf)
    return shortTag.create(buf:readShort())
end

function shortTag.write(buf, instance)
    buf:putShort(instance.value)
end

function shortTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readShort()

    return shortTag.createNamed(payload, name)
end

function shortTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putShort(instance.value)
end

return shortTag

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
