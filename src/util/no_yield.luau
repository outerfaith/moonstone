--!optimize 2

local function no_yield0<O...>(thread: thread, ok: boolean, ...: O...): O...
    if not ok then
        local message: string = (...) :: any

        error(debug.traceback(thread, message), 2)
    end

    if coroutine.status(thread) == "dead" then
        return ...
    end

    error(debug.traceback(thread, "This coroutine cannot yield"), 2)
end

local function no_yield<I..., O...>(cb: (I...) -> O..., ...: I...): O...
    local thread = coroutine.create(cb)

    return no_yield0(thread, coroutine.resume(thread, ...))
end

return no_yield

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
