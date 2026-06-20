--!optimize 2

const result = require("@pkg/result")

const tags = require("@moonstone/nbt/tags")
const tag_ops = require("@moonstone/nbt/tag_ops")

type Result<R, E> = result.Result<R, E>
type Tag<T> = tag_ops.Tag<T>

export function write(tag: Tag<nil>)
    return
end

export function read(): Result<Tag<nil>, string>
    return result.ok(tags.end_tag())
end

--[[
   Copyright 2025-2026 Outerfaith
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
