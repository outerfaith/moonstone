--!optimize 2

const tableext = require("@std/tableext")

local jecs = require("@vendor/jecs")
const typeforge = require("@vendor/typeforge")

const world = require("@moonstone/ecs/world")
const deep_clone = require("@moonstone/util/deep_clone")

type Id<T> = jecs.Id<T>
type Entity = jecs.Entity

const function patch<T>(entity: Entity, component: Id<T>, data: T, patch: typeforge.Partial<T>)
    const new_data = tableext.combine(deep_clone(data), patch)

    world:set(entity, component, new_data)
end

return patch

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
