--!optimize 2

local enum = require("../../util/enum")
local packet = require("./packet")
local sharedTypes = require("./sharedTypes")

local serverboundPluginMessage = require("./common/serverboundPluginMessage")

local serverboundHandshakePacket = require("./handshake/serverboundHandshakePacket")

local clientboundPongResponse = require("./status/clientboundPongResponse")
local clientboundStatusResponse = require("./status/clientboundStatusResponse")
local serverboundPingRequest = require("./status/serverboundPingRequest")
local serverboundStatusRequest = require("./status/serverboundStatusRequest")

local clientboundEncryptionRequest = require("./login/clientboundEncryptionRequest")
local clientboundLoginFinished = require("./login/clientboundLoginFinished")
local serverboundLoginAcknowledged = require("./login/serverboundLoginAcknowledged")
local serverboundLoginStart = require("./login/serverboundLoginStart")

local clientboundFeatureFlags = require("./configuration/clientboundFeatureFlags")
local serverboundClientInformation = require("./configuration/serverboundClientInformation")

type PacketRegistryProto = sharedTypes.PacketRegistryProto
export type PacketRegistry = sharedTypes.PacketRegistry

local packetRegistry = {} :: PacketRegistryProto
packetRegistry.__index = packetRegistry

function packetRegistry.register<T>(self: PacketRegistry, id: number, packet: packet.Packet<T>)
    assert(id >= 0, "id must be non-negative")
    assert(self.idToType[id] == nil, "id has already been registered to another packet")
    assert(self.typeToId[packet] == nil, "packet has already been registered to another id")

    self.idToType[id] = packet
    self.typeToId[packet] = id

    return self
end

function packetRegistry.getId<T>(self: PacketRegistry, packet: packet.Packet<T>)
    return self.typeToId[packet]
end

function packetRegistry.get<T>(self: PacketRegistry, id: number)
    assert(id ~= nil, "id must be non-negative")
    assert(self.idToType[id] ~= nil, `no packet has been registered with id '{id}'`)

    return self.idToType[id]
end

local function create(): PacketRegistry
    return table.freeze(setmetatable({
        idToType = {},
        typeToId = {},
    }, packetRegistry))
end

--stylua: ignore start
local SERVERBOUND_HANDSHAKE_PACKETS = create()
    :register(0x00, serverboundHandshakePacket)
local SERVERBOUND_STATUS_PACKETS = create()
    :register(0x00, serverboundStatusRequest)
    :register(0x01, serverboundPingRequest)
local CLIENTBOUND_STATUS_PACKETS = create()
    :register(0x00, clientboundStatusResponse)
    :register(0x01, clientboundPongResponse)
local SERVERBOUND_LOGIN_PACKETS = create()
    :register(0x00, serverboundLoginStart)
    :register(0x03, serverboundLoginAcknowledged)
local CLIENTBOUND_LOGIN_PACKETS = create()
    :register(0x01, clientboundEncryptionRequest)
    :register(0x02, clientboundLoginFinished)
local SERVERBOUND_CONFIGURATION_PACKETS = create()
    :register(0x00, serverboundClientInformation)
    :register(0x02, serverboundPluginMessage)
local CLIENTBOUND_CONFIGURATION_PACKETS = create()
    :register(0x0C, clientboundFeatureFlags)
--stylua: ignore end

local SERVERBOUND_REGISTRIES: { [number]: PacketRegistry } = {
    [enum.intent.HANDSHAKE] = SERVERBOUND_HANDSHAKE_PACKETS,
    [enum.intent.STATUS] = SERVERBOUND_STATUS_PACKETS,
    [enum.intent.LOGIN] = SERVERBOUND_LOGIN_PACKETS,
    [enum.intent.CONFIGURATION] = SERVERBOUND_CONFIGURATION_PACKETS,
}

local CLIENTBOUND_REGISTRIES: { [number]: PacketRegistry } = {
    [enum.intent.STATUS] = CLIENTBOUND_STATUS_PACKETS,
    [enum.intent.LOGIN] = CLIENTBOUND_LOGIN_PACKETS,
    [enum.intent.CONFIGURATION] = CLIENTBOUND_CONFIGURATION_PACKETS,
}

local function serverboundForIntent(intent: number): PacketRegistry
    return SERVERBOUND_REGISTRIES[intent] or error(`No serverbound packets for intent '{intent}'`)
end

local function clientboundForIntent(intent: number): PacketRegistry
    return CLIENTBOUND_REGISTRIES[intent] or error(`No clientbound packets for intent '{intent}'`)
end

return table.freeze({
    create = create,
    serverboundForIntent = serverboundForIntent,
    clientboundForIntent = clientboundForIntent,
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
