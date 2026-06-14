--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec/helper")

type BufferCodec<T> = buffer_codec.BufferCodec<T>

type IdentifierProto = {
    __index: IdentifierProto,
    __tostring: (self: Identifier) -> string,
    __eq: (self: Identifier, other: any) -> boolean,
    with_path: (self: Identifier, new_path: string) -> Identifier,
    with_prefix: (self: Identifier, prefix: string) -> Identifier,
    with_suffix: (self: Identifier, suffix: string) -> Identifier,
    to_language_key: (self: Identifier) -> string,
    to_prefixed_language_key: (self: Identifier, prefix: string) -> string,
    to_prefixed_and_suffixed_language_key: (
        self: Identifier,
        prefix: string,
        suffix: string
    ) -> string,
    to_short_language_key: (self: Identifier) -> string,
    to_short_string: (self: Identifier) -> string,
}

export type Identifier = setmetatable<{
    read namespace: string,
    read path: string,
}, IdentifierProto>

const DEFAULT_NAMESPACE = "moonstone"
const MINECRAFT_NAMESPACE = "minecraft"
const NAMESPACE_SEPARATOR = ":"
const NAMESPACE_PATTERN = "[a-z0-9_%.%-]"
const PATH_PATTERN = "[a-z0-9/%.%_%-]"

const identifier = {} :: IdentifierProto
identifier.__index = identifier

const function is_valid_namespace(namespace: string): boolean
    for i = 1, string.len(namespace) do
        const char = string.sub(namespace, i, i)

        if not string.match(char, NAMESPACE_PATTERN) then
            return false
        end
    end

    return true
end

const function is_valid_path(path: string): boolean
    for i = 1, string.len(path) do
        const char = string.sub(path, i, i)

        if not string.match(char, PATH_PATTERN) then
            return false
        end
    end

    return true
end

const function new(namespace: string, path: string): Identifier
    assert(is_valid_namespace(namespace), "namespace contains invalid characters")
    assert(is_valid_path(path), "path contains invalid characters")

    return table.freeze(setmetatable({
        namespace = namespace,
        path = path,
    }, identifier)) :: any
end

const function with_default_namespace(path: string): Identifier
    return new(DEFAULT_NAMESPACE, path)
end

const function with_minecraft_namespace(path: string): Identifier
    return new(MINECRAFT_NAMESPACE, path)
end

const function parse(input: string): Identifier
    const separator = string.find(input, NAMESPACE_SEPARATOR, 1, true)

    if separator ~= nil then
        const namespace = string.sub(input, 1, separator - 1)
        const path = string.sub(input, separator + 1)

        assert(namespace ~= nil, "separator must come before path value")

        return new(namespace, path)
    end

    return with_minecraft_namespace(input)
end

const BUFFER_CODEC = buffer_codec.new<<Identifier>>(function(buf)
    return parse(buffer_codec.UNLIMITED_STRING:read(buf))
end, function(buf, value)
    buffer_codec.UNLIMITED_STRING:write(buf, tostring(value))
end)

function identifier.__tostring(self)
    return `{self.namespace}{NAMESPACE_SEPARATOR}{self.path}`
end

function identifier.__eq(self, other)
    if type(other) ~= "table" then
        return false
    end

    if getmetatable(other) ~= identifier then
        return false
    end

    return self.namespace == other.namespace and self.path == other.path
end

function identifier.with_path(self, newPath)
    return new(self.namespace, newPath)
end

function identifier.with_prefix(self, prefix)
    return new(self.namespace, prefix .. self.path)
end

function identifier.with_suffix(self, suffix)
    return new(self.namespace, self.path .. suffix)
end

function identifier.to_language_key(self)
    return `{self.namespace}.{self.path}`
end

function identifier.to_prefixed_language_key(self, prefix)
    return `{prefix}.{self:to_language_key()}`
end

function identifier.to_prefixed_and_suffixed_language_key(self, prefix, suffix)
    return `{prefix}.{self:to_language_key()}.{suffix}`
end

function identifier.to_short_language_key(self)
    return self.namespace == MINECRAFT_NAMESPACE and self.path or self:to_language_key()
end

function identifier.to_short_string(self)
    return self.namespace == MINECRAFT_NAMESPACE and self.path or self:__tostring()
end

return table.freeze({
    BUFFER_CODEC = BUFFER_CODEC,
    is_valid_namespace = is_valid_namespace,
    is_valid_path = is_valid_path,
    new = new,
    parse = parse,
    with_default_namespace = with_default_namespace,
    with_minecraft_namespace = with_minecraft_namespace,
})

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
