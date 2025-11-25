--!optimize 2
--!strict

local io = zune.io

local ansi = require("./ansi")

local logger = {}
logger.__index = logger

export type Level = "TRACE" | "DEBUG" | "INFO" | "WARN" | "ERROR" | "FATAL"

export type Logger = typeof(setmetatable(
    {} :: {
        read name: string?,
    },
    logger
))

local LEVEL_COLORS: { [Level]: number } = {
    TRACE = ansi.FOREGROUND_COLORS.GREEN,
    DEBUG = ansi.FOREGROUND_COLORS.GREEN,
    INFO = ansi.FOREGROUND_COLORS.GREEN,
    WARN = ansi.FOREGROUND_COLORS.YELLOW,
    ERROR = ansi.FOREGROUND_COLORS.RED,
    FATAL = ansi.FOREGROUND_COLORS.RED,
}

local LEVEL_STYLES: { [Level]: { number }? } = {
    FATAL = { ansi.STYLES.BOLD, ansi.STYLES.BLINK },
}

local function getTimeString(): string
    local time = os.date("*t")
    return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
end

function logger.new(name: string?): Logger
    return setmetatable({
        name = name,
    }, logger)
end

function logger.log(self: Logger, level: Level, msg: string)
    local color = LEVEL_COLORS[level]
    assert(color ~= nil, `Level '{level}' has no color`)
    local styles = LEVEL_STYLES[level]

    local fmtTime = `{ansi.color(ansi.FOREGROUND_COLORS.BLUE)}[{getTimeString()}]{ansi.RESET}`
    local fmtLevel = `{ansi.color(color, nil, styles)}[{level}]{ansi.RESET}`
    local fmtName = if self.name ~= nil
        then `{ansi.color(ansi.FOREGROUND_COLORS.CYAN)}({self.name}){ansi.RESET} `
        else " "

    local fmtMsg = `{fmtTime} {fmtLevel} {fmtName}{msg}\n`

    io.stdout:write(fmtMsg)
end

function logger.trace(self: Logger, msg: string)
    self:log("TRACE", msg)
end

function logger.debug(self: Logger, msg: string)
    self:log("DEBUG", msg)
end

function logger.info(self: Logger, msg: string)
    self:log("INFO", msg)
end

function logger.warn(self: Logger, msg: string)
    self:log("WARN", msg)
end

function logger.error(self: Logger, msg: string)
    self:log("ERROR", msg)
end

function logger.fatal(self: Logger, msg: string)
    self:log("FATAL", msg)
end

return logger

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
