--!optimize 2
--!strict

local dataResult = {}
dataResult.__index = dataResult

export type DataResult<T> = typeof(setmetatable(
    {} :: {
        read value: T?,
        read msg: string?,
    },
    dataResult
))

function dataResult.ok<T>(value: T): DataResult<T>
    return setmetatable({
        value = value,
        msg = nil,
    }, dataResult)
end

function dataResult.err<T>(msg: string): DataResult<T>
    return setmetatable({
        value = nil,
        msg = msg,
    }, dataResult)
end

function dataResult.isSuccess<T>(self: DataResult<T>): boolean
    return self.value ~= nil and self.msg == nil
end

function dataResult.isError<T>(self: DataResult<T>): boolean
    return not self:isSuccess()
end

function dataResult.flatMap<T, R>(self: DataResult<T>, mapper: (T) -> DataResult<R>): DataResult<R>
    return self:isSuccess() and mapper(self.value) or self :: DataResult<R>
end

function dataResult.map<T, R>(self: DataResult<T>, mapper: (T) -> R): DataResult<R>
    return self:isSuccess() and dataResult.ok(mapper(self.value)) or self :: DataResult<R>
end

function dataResult.mapErr<T>(self: DataResult<T>, mapper: (string) -> string): DataResult<T>
    return self:isError() and dataResult.err(mapper(self.msg)) or self
end

function dataResult.orElse<T>(self: DataResult<T>, other: T): T
    return self:isError() and other or self.value
end

function dataResult.__tostring<T>(self: DataResult<T>): string
    return self:isSuccess() and `DataResult({tostring(self.value)})` or self.msg :: string
end

return dataResult

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
