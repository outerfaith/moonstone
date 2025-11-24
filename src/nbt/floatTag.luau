--!optimize 2
--!strict

local tags = require("./tags")

local floatTag = {} :: tags.TagOps<number>
floatTag.__index = floatTag

export type FloatTag = typeof(setmetatable({} :: tags.Tag<number>, floatTag))

function floatTag.create(value)
    return setmetatable({
        value = value,
        id = tags.FLOAT,
    }, floatTag)
end

function floatTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.FLOAT,
        name = name,
    }, floatTag)
end

function floatTag.read(buf)
    return floatTag.create(buf:readFloat())
end

function floatTag.write(buf, instance)
    buf:putFloat(instance.value)
end

function floatTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readFloat()

    return floatTag.createNamed(payload, name)
end

function floatTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putFloat(instance.value)
end

return floatTag

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
