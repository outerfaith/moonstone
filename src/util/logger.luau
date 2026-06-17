--!optimize 2

const io = require("@std/io")

const ansi = require("@moonstone/util/ansi")

export type Level = "TRACE" | "DEBUG" | "INFO" | "WARN" | "ERROR" | "FATAL"

type LoggerProto = {
    __index: LoggerProto,
    log: (self: Logger, level: Level, msg: string) -> (),
    trace: (self: Logger, msg: string) -> (),
    debug: (self: Logger, msg: string) -> (),
    info: (self: Logger, msg: string) -> (),
    warn: (self: Logger, msg: string) -> (),
    error: (self: Logger, msg: string) -> (),
    fatal: (self: Logger, msg: string) -> (),
}

export type Logger = setmetatable<{
    read name: string?,
}, LoggerProto>

const LEVEL_COLORS: { [Level]: number } = table.freeze({
    TRACE = ansi.FOREGROUND_COLORS.GREEN,
    DEBUG = ansi.FOREGROUND_COLORS.GREEN,
    INFO = ansi.FOREGROUND_COLORS.GREEN,
    WARN = ansi.FOREGROUND_COLORS.YELLOW,
    ERROR = ansi.FOREGROUND_COLORS.RED,
    FATAL = ansi.FOREGROUND_COLORS.RED,
} :: any)

const LEVEL_STYLES: { [Level]: { number }? } = table.freeze({
    FATAL = { ansi.STYLES.BOLD, ansi.STYLES.BLINK },
} :: any)

export function get_time_string(): string
    const time = os.date("*t")
    return string.format("%02d:%02d:%02d", time.hour, time.min, time.sec)
end

const logger = {} :: LoggerProto
logger.__index = logger

export function new(name: string?): Logger
    return table.freeze(setmetatable({ name = name }, logger))
end

function logger.log(self: Logger, level: Level, msg: string)
    const color = assert(LEVEL_COLORS[level], `Level '{level}' has no color`)
    const styles = LEVEL_STYLES[level]

    const fmt_time = `{ansi.color(ansi.FOREGROUND_COLORS.BLUE)}[{get_time_string()}]{ansi.RESET}`
    const fmt_level = `{ansi.color(color, nil, styles)}[{level}]{ansi.RESET}`
    const fmt_name = if self.name ~= nil
        then `{ansi.color(ansi.FOREGROUND_COLORS.CYAN)}({self.name}){ansi.RESET} `
        else " "

    const fmt_msg = `{fmt_time} {fmt_level} {fmt_name}{msg}\n`

    io.write(fmt_msg)
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
