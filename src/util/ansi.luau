--!optimize 2
--!strict

local ESCAPE = "\27"
local RESET = `{ESCAPE}[0m`

local STYLES = table.freeze({
    RESET = 0,
    BOLD = 1,
    DIM = 2,
    ITALIC = 3,
    UNDERLINE = 4,
    BLINK = 5,
})

local FOREGROUND_COLORS = table.freeze({
    BLACK = 30,
    RED = 31,
    GREEN = 32,
    YELLOW = 33,
    BLUE = 34,
    MAGENTA = 35,
    CYAN = 36,
    WHITE = 37,
    DEFAULT = 39,
})

local BACKGROUND_COLORS = table.freeze({
    BLACK = 40,
    RED = 41,
    GREEN = 42,
    YELLOW = 43,
    BLUE = 44,
    MAGENTA = 45,
    CYAN = 46,
    WHITE = 47,
    DEFAULT = 49,
})

local function color(foreground: number, background: number?, styles: { number }?)
    local codes = {}
    if styles then
        for idx, style in styles do
            table.insert(codes, tostring(style))
        end
    end
    table.insert(codes, tostring(foreground))
    if background then
        table.insert(codes, tostring(background))
    end
    if #codes == 0 then
        return RESET
    end
    return `{ESCAPE}[{table.concat(codes, ";")}m`
end

return table.freeze({
    ESCAPE = ESCAPE,
    RESET = RESET,
    STYLES = STYLES,
    FOREGROUND_COLORS = FOREGROUND_COLORS,
    BACKGROUND_COLORS = BACKGROUND_COLORS,
    color = color,
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
