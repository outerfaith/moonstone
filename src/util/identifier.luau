--!optimize 2

type IdentifierProto = {
    __index: IdentifierProto,
    __tostring: (self: Identifier) -> string,
    __eq: (self: Identifier, other: any) -> boolean,
    withPath: (self: Identifier, newPath: string) -> Identifier,
    withPrefix: (self: Identifier, prefix: string) -> Identifier,
    withSuffix: (self: Identifier, suffix: string) -> Identifier,
    toLanguageKey: (self: Identifier) -> string,
    toPrefixedLanguageKey: (self: Identifier, prefix: string) -> string,
    toPrefixedAndSuffixedLanguageKey: (self: Identifier, prefix: string, suffix: string) -> string,
    toShortLanguageKey: (self: Identifier) -> string,
    toShortString: (self: Identifier) -> string,
}

export type Identifier = setmetatable<{
    read namespace: string,
    read path: string,
}, IdentifierProto>

local DEFAULT_NAMESPACE = "minecraft"
local NAMESPACE_SEPARATOR = ":"
local NAMESPACE_PATTERN = "[a-z0-9_%.%-]"
local PATH_PATTERN = "[a-z0-9/%.%_%-]"

local identifier = {} :: IdentifierProto
identifier.__index = identifier

local function isValidNamespace(namespace: string): boolean
    for i = 1, string.len(namespace) do
        local char = string.sub(namespace, i, i)
        if not string.match(char, NAMESPACE_PATTERN) then
            return false
        end
    end

    return true
end

local function isValidPath(path: string): boolean
    for i = 1, string.len(path) do
        local char = string.sub(path, i, i)
        if not string.match(char, PATH_PATTERN) then
            return false
        end
    end

    return true
end

local function new(namespace: string, path: string): Identifier
    assert(isValidNamespace(namespace), "namespace contains invalid characters")
    assert(isValidPath(path), "path contains invalid characters")

    return table.freeze(setmetatable({
        namespace = namespace,
        path = path,
    }, identifier)) :: any
end

local function withDefaultNamespace(path: string): Identifier
    return new(DEFAULT_NAMESPACE, path)
end

local function parse(input: string): Identifier
    local separator = string.find(input, NAMESPACE_SEPARATOR, 1, true)

    if separator ~= nil then
        local namespace = string.sub(input, 1, separator - 1)
        local path = string.sub(input, separator + 1)

        assert(namespace ~= nil, "separator must come before path value")

        return new(namespace, path)
    end

    return withDefaultNamespace(input)
end

function identifier.__tostring(self)
    return self.namespace .. NAMESPACE_SEPARATOR .. self.path
end

function identifier.__eq(self, other)
    if type(other) ~= "table" then
        return false
    end

    -- we assume that since 'other' is a table it's probably an identifier
    -- but just to be super sure we'll double check that the namespace and path fields are present

    assert(self.namespace ~= nil, "not comparable: 'other' is missing a namespace field")
    assert(self.path ~= nil, "not comparable: 'other' is missing a path field")

    return self.namespace == (other :: Identifier).namespace
        and self.path == (other :: Identifier).path
end

function identifier.withPath(self, newPath)
    return new(self.namespace, newPath)
end

function identifier.withPrefix(self, prefix)
    return new(self.namespace, prefix .. self.path)
end

function identifier.withSuffix(self, suffix)
    return new(self.namespace, self.path .. suffix)
end

function identifier.toLanguageKey(self)
    return self.namespace .. "." .. self.path
end

function identifier.toPrefixedLanguageKey(self, prefix)
    return prefix .. "." .. self:toLanguageKey()
end

function identifier.toPrefixedAndSuffixedLanguageKey(self, prefix, suffix)
    return prefix .. "." .. self:toLanguageKey() .. "." .. suffix
end

function identifier.toShortLanguageKey(self)
    return self.namespace == DEFAULT_NAMESPACE and self.path or self:toLanguageKey()
end

function identifier.toShortString(self)
    return self.namespace == DEFAULT_NAMESPACE and self.path or self:__tostring()
end

return table.freeze({
    isValidNamespace = isValidNamespace,
    isValidPath = isValidPath,
    new = new,
    parse = parse,
    withDefaultNamespace = withDefaultNamespace,
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
