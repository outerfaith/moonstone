--!optimize 2
--!strict

local tags = require("./tags")

local longTag = {} :: tags.TagOps<number>
longTag.__index = longTag

export type LongTag = typeof(setmetatable({} :: tags.Tag<number>, longTag))

function longTag.create(value)
    return setmetatable({
        value = value,
        id = tags.LONG,
    }, longTag)
end

function longTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.LONG,
        name = name,
    }, longTag)
end

function longTag.read(buf)
    return longTag.create(buf:readLong())
end

function longTag.write(buf, instance)
    buf:putLong(instance.value)
end

function longTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readLong()

    return longTag.createNamed(payload, name)
end

function longTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putLong(instance.value)
end

return longTag

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
