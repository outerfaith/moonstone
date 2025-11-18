--!optimize 2
--!native

local dataResult = require("./dataResult")

export type Transcoder<T> = {
    createEmpty: (self: Transcoder<T>) -> T,
    getBoolean: (self: Transcoder<T>, value: T) -> dataResult.DataResult<boolean>,
    createBoolean: (self: Transcoder<T>, value: boolean) -> T,
    getByte: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createByte: (self: Transcoder<T>, value: number) -> T,
    getShort: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createShort: (self: Transcoder<T>, value: number) -> T,
    getInt: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createInt: (self: Transcoder<T>, value: number) -> T,
    getLong: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createLong: (self: Transcoder<T>, value: number) -> T,
    getFloat: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createFloat: (self: Transcoder<T>, value: number) -> T,
    getDouble: (self: Transcoder<T>, value: T) -> dataResult.DataResult<number>,
    createDouble: (self: Transcoder<T>, value: number) -> T,
    getString: (self: Transcoder<T>, value: T) -> dataResult.DataResult<string>,
    createString: (self: Transcoder<T>, value: string) -> T,
    getList: (self: Transcoder<T>, value: T) -> dataResult.DataResult<{ T }>,
    createList: (self: Transcoder<T>, size: number) -> T,
    createEmptyList: (self: Transcoder<T>) -> T,
    getMap: (self: Transcoder<T>, value: T) -> dataResult.DataResult<{ [string]: T }>,
    createMap: (self: Transcoder<T>) -> { [string]: T },
    createEmptyMap: (self: Transcoder<T>) -> { [string]: T },
    getByteArray: (self: Transcoder<T>, value: T) -> dataResult.DataResult<buffer>,
    createByteArray: (self: Transcoder<T>, value: buffer) -> T,
    getIntArray: (self: Transcoder<T>, value: T) -> dataResult.DataResult<{ number }>,
    createIntArray: (self: Transcoder<T>, value: { number }) -> T,
    getLongArray: (self: Transcoder<T>, value: T) -> dataResult.DataResult<{ number }>,
    createLongArray: (self: Transcoder<T>, value: { number }) -> T,
}

return nil

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
