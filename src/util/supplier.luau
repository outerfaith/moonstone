--!optimize 2
--!strict

export type Supplier<T> = () -> T

local function memoize<T>(supplier: Supplier<T>)
    local value: T? = nil

    return function()
        if value == nil then
            value = supplier()
        end
        return value
    end
end

local function lazyRequire<T>(path: string): Supplier<T>
    return memoize(function()
        return (require)(path)
    end)
end

return table.freeze({
    memoize = memoize,
    lazyRequire = lazyRequire,
})

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
