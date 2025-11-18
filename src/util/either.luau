--!optimize 2
--!strict

local either = {}
either.__index = either

export type Either<L, R> = typeof(setmetatable(
    {} :: {
        read left: L?,
        read right: R?,
    },
    either
))

function either.left<L, R>(value: L): Either<L, R>
    return setmetatable({
        left = value,
        right = nil,
    }, either)
end

function either.right<L, R>(value: R): Either<L, R>
    return setmetatable({
        left = nil,
        right = value,
    }, either)
end

function either.unwrap<V>(either: Either<V, V>): V
    return either:isLeft() and either.left or either.right
end

function either.isLeft<L, R>(self: Either<L, R>): boolean
    return self.left ~= nil
end

function either.isRight<L, R>(self: Either<L, R>): boolean
    return self.right ~= nil
end

function either.swap<L, R>(self: Either<L, R>): Either<R, L>
    return self:isLeft() and either.right(self.left) or either.left(self.right)
end

function either.mapLeft<L, R, L1>(self: Either<L, R>, mapper: (L) -> L1): Either<L1, R>
    return self:isLeft() and either.left(mapper(self.left)) or self :: Either<L1, R>
end

function either.mapRight<L, R, R1>(self: Either<L, R>, mapper: (R) -> R1): Either<L, R1>
    return self:isRight() and either.right(mapper(self.right)) or self :: Either<L, R1>
end

function either.biMap<L, R, L1, R1>(self: Either<L, R>, left: (L) -> L1, right: (R) -> R1): Either<L1, R1>
    return self:isLeft() and either.left(left(self.left)) or either.right(right(self.right))
end

function either.flatMap<L, R, L1>(self: Either<L, R>, mapper: (L) -> Either<L1, R>): Either<L1, R>
    return self:isLeft() and mapper(self.left) or self :: Either<L1, R>
end

function either.__eq<L, R, L1, R1>(self: Either<L, R>, other: Either<L1, R1>): boolean
    return (self:isLeft() and self.left == other.left)
        or (self:isRight() and self.right == other.right)
end

function either.__tostring<L, R>(self: Either<L, R>): string
    return self:isLeft() and `Left({tostring(self.left)})` or `Right({self.right})`
end

return either

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
