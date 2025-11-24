--!optimize 2
--!strict

local tags = require("./tags")

local doubleTag = {} :: tags.TagOps<number>
doubleTag.__index = doubleTag

export type DoubleTag = typeof(setmetatable({} :: tags.Tag<number>, doubleTag))

function doubleTag.create(value)
    return setmetatable({
        value = value,
        id = tags.DOUBLE,
    }, doubleTag)
end

function doubleTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.DOUBLE,
        name = name,
    }, doubleTag)
end

function doubleTag.read(buf)
    return doubleTag.create(buf:readDouble())
end

function doubleTag.write(buf, instance)
    buf:putDouble(instance.value)
end

function doubleTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)
    local payload = buf:readDouble()

    return doubleTag.createNamed(payload, name)
end

function doubleTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
    buf:putDouble(instance.value)
end

return doubleTag

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
