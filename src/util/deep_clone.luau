--!optimize 2

const function deep_clone<K, V>(t: { [K]: V }): { [K]: V }
    assert(type(t) == "table", "not a table")

    const new = table.clone(t)
    for key, value in t do
        if type(value) == "table" then
            new[key] = deep_clone(value)
        end
    end

    return new
end

return deep_clone

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
