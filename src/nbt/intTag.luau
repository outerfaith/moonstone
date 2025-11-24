--!optimize 2
--!strict

local tags = require("./tags")

local intTag = {} :: tags.TagOps<number>
intTag.__index = intTag

export type IntTag = typeof(setmetatable({} :: tags.Tag<number>, intTag))

function intTag.create(value)
    return setmetatable({
        value = value,
        id = tags.INT,
    }, intTag)
end

function intTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.INT,
        name = name,
    }, intTag)
end

function intTag.read(buf)
    return intTag.create(buf:readInt())
end

function intTag.write(buf, instance)
    buf:putInt(instance.value)
end

function intTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readInt()

    return intTag.createNamed(payload, name)
end

function intTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putInt(instance.value)
end

return intTag

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
