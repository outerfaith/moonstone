--!optimize 2
--!strict

local tags = require("./tags")

local endTag = {} :: tags.TagOps<nil>
endTag.__index = endTag

export type EndTag = typeof(setmetatable({} :: tags.Tag<nil>, endTag))

function endTag.create(value)
    return setmetatable({
        value = value,
        id = tags.END,
    }, endTag)
end

function endTag.createNamed(value, name)
    return setmetatable({
        value = value,
        id = tags.END,
        name = name,
    }, endTag)
end

function endTag.read(buf)
    return endTag.create(nil)
end

function endTag.write(buf, instance)
    return
end

function endTag.readNamed(buf)
    local nameLen = buf:readShort()
    local name = buf:readString(nameLen)

    return endTag.createNamed(nil, name)
end

function endTag.writeNamed(buf, instance)
    buf:putShort(string.len(instance.name))
    buf:putString(instance.name)
end

return endTag

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
