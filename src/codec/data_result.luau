--!optimize 2

type DataResultProto<T> = {
    __index: DataResultProto<T>,
    __tostring: (self: DataResult<T>) -> string,
    is_success: (self: DataResult<T>) -> boolean,
    is_error: (self: DataResult<T>) -> boolean,
    is_partial: (self: DataResult<T>) -> boolean,
    or_else: (self: DataResult<T>, other: T) -> T,
}

export type DataResult<T> = setmetatable<{
    read value: T?,
    read msg: string?,
}, DataResultProto<T>>

const data_result = {} :: DataResultProto<unknown>
data_result.__index = data_result

export function ok<T>(value: T): DataResult<T>
    return table.freeze(setmetatable({
        value = value,
        msg = nil,
    }, data_result))
end

export function err<T>(msg: string): DataResult<T>
    return table.freeze(setmetatable({
        value = nil,
        msg = msg,
    }, data_result))
end

export function flat_map<T, R>(result: DataResult<T>, mapper: (T) -> DataResult<R>): DataResult<R>
    return if result:is_success() then mapper(result.value) else result
end

export function map<T, R>(result: DataResult<T>, mapper: (T) -> R): DataResult<R>
    return if result:is_success() then ok(mapper(result.value)) else result
end

export function map_err<T, R>(result: DataResult<T>, mapper: (string) -> string): DataResult<R>
    return if result:is_error() or result:is_partial()
        then err(mapper(result.msg :: string))
        else result
end

function data_result.__tostring(self)
    return if self:is_success() then `DataResult({tostring(self.value)})` else self.msg :: string
end

function data_result.is_success(self)
    return self.value ~= nil and self.msg == nil
end

function data_result.is_error(self)
    return not self:is_success()
end

function data_result.is_partial(self)
    return self.value ~= nil and self.msg ~= nil
end

function data_result.or_else(self, other)
    return if self:is_error() or self:is_partial() then other else self.value
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
