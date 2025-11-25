--!optimize 2

local packet = require("../packet")
local sharedTypes = require("../sharedTypes")
local clientboundUpdateTags = require("../common/clientboundUpdateTags")
local clientboundFeatureFlags = require("../configuration/clientboundFeatureFlags")
local clientboundRegistryData = require("../configuration/clientboundRegistryData")
local clientboundSelectKnownPacks = require("../configuration/clientboundSelectKnownPacks")
local networkType = require("../../networkType")
local knownPack = require("../../../resources/knownPack")
local enum = require("../../../util/enum")
local identifier = require("../../../util/identifier")

export type Data = nil

return table.freeze({
    networkType = networkType.unit(),
    handle = function(connection: sharedTypes.Connection)
        print("login acknowledged")
        connection.intent = enum.intent.CONFIGURATION
        -- TODO(outerfaith): put all configuration stuff here
        -- need to load these values dynamically at some point
        connection:sendPacket(clientboundFeatureFlags, {
            identifier.withDefaultNamespace("vanilla"),
        })
        connection:sendPacket(clientboundSelectKnownPacks, {
            packs = { knownPack.create("minecraft", "core", "1.21.10") },
        })
        local f = zune.serde.json.decode(zune.fs.readFile("data/networked_registries.json"))
        for registry, fieldData in f do
            local fields = {}
            for idx, ignored in fieldData do
                table.insert(fields, {
                    id = idx,
                    data = nil,
                })
            end
            connection:sendPacket(clientboundRegistryData, {
                id = identifier.parse(registry),
                entries = fields,
            })
        end
        local t = zune.serde.json.decode(zune.fs.readFile("data/tags.json"))
        local compiled = {}
        for registry, tagData in t do
            local rident = identifier.parse(registry)
            local tags = {}
            for idx, entries in tagData do
                local tagidx = identifier.parse(idx)
                local tagentries = {}
                for tidx, ignored in ipairs(entries) do
                    table.insert(tagentries, tidx)
                end
                table.insert(tags, {
                    name = tagidx,
                    entries = tagentries,
                })
            end
            table.insert(compiled, {
                registry = rident,
                tags = tags,
            })
        end
        connection:sendPacket(clientboundUpdateTags, compiled)
    end,
}) :: packet.ServerboundPacket<Data>

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
