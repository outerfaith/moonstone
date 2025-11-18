--!optimize 2
--!strict

local pair = {}
pair.__index = pair

export type Pair<L, R> = typeof(setmetatable(
    {} :: {
        read left: L,
        read right: R,
    },
    pair
))

function pair.new<L, R>(left: L, right: R): Pair<L, R>
    return setmetatable({
        left = left,
        right = right,
    }, pair)
end

function pair.swap<L, R>(self: Pair<L, R>): Pair<R, L>
    return pair.new(self.right, self.left)
end

function pair.mapLeft<L, R, L1>(self: Pair<L, R>, mapper: (L) -> L1): Pair<L1, R>
    return pair.new(mapper(self.left), self.right)
end

function pair.mapRight<L, R, R1>(self: Pair<L, R>, mapper: (R) -> R1): Pair<L, R1>
    return pair.new(self.left, mapper(self.right))
end

function pair.biMap<L, R, L1, R1>(self: Pair<L, R>, left: (L) -> L1, right: (R) -> R1): Pair<L1, R1>
    return pair.new(left(self.left), right(self.right))
end

function pair.__eq<L, R, L1, R1>(self: Pair<L, R>, other: Pair<L1, R1>): boolean
    return (self.left == other.left) and (self.right == other.right)
end

function pair.__tostring<L, R>(self: Pair<L, R>): string
    return `({tostring(self.left)}, {tostring(self.right)})`
end

return pair

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
