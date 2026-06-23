--!optimize 2

const handler = require("@moonstone/network/protocol/handler")
const packet = require("@moonstone/network/protocol/packet")
const handshake_handler = require("@moonstone/network/protocol/handshake/handshake_handler")
const serverbound_handshake = require("@moonstone/network/protocol/handshake/serverbound_handshake")
const clientbound_ping_response = require("@moonstone/network/protocol/status/clientbound_ping_response")
const clientbound_status_response = require("@moonstone/network/protocol/status/clientbound_status_response")
const serverbound_ping_request = require("@moonstone/network/protocol/status/serverbound_ping_request")
const serverbound_status_request = require("@moonstone/network/protocol/status/serverbound_status_request")
const status_handler = require("@moonstone/network/protocol/status/status_handler")
const enum = require("@moonstone/util/enum")

type PacketHandler = handler.PacketHandler
type Packet<T> = packet.Packet<T>

type PacketRegistryProto = {
    __index: PacketRegistryProto,
    register: (self: PacketRegistry, packet: Packet<any>) -> PacketRegistry,
    register_handler: (self: PacketRegistry, handler: PacketHandler) -> PacketRegistry,
    lookup: (self: PacketRegistry, id: number) -> Packet<unknown>?,
    get_handler: (self: PacketRegistry) -> PacketHandler,
    freeze: (self: PacketRegistry) -> PacketRegistry,
}

export type PacketRegistry = setmetatable<{
    read id_to_type: { read [number]: Packet<unknown> },
    read type_to_id: { [Packet<unknown>]: number },
    read handler: PacketHandler,
}, PacketRegistryProto>

const packet_registry = {} :: PacketRegistryProto
packet_registry.__index = packet_registry

const function create(): PacketRegistry
    return setmetatable({
        id_to_type = {},
        type_to_id = {},
        handler = (nil :: any) :: PacketHandler,
    }, packet_registry)
end

function packet_registry.register(self: any, packet)
    const id = packet.id

    assert(id >= 0, "packet id must not be negative")
    assert(self.id_to_type[id] == nil, "id has already been registered")
    assert(self.type_to_id[packet] == nil, "packet has already been registered to another id")

    self.id_to_type[id] = packet

    return self
end

function packet_registry.register_handler(self: any, handler)
    assert(self.handler == nil, "this registry already has a packet handler")

    self.handler = handler

    return self
end

function packet_registry.lookup(self, id)
    return self.id_to_type[id]
end

function packet_registry.get_handler(self)
    return assert(self.handler, "no packet handler registered")
end

function packet_registry.freeze(self)
    table.freeze(self.id_to_type)
    table.freeze(self.type_to_id)
    table.freeze(self)

    return self
end

-- stylua: ignore start
const SERVERBOUND_HANDSHAKE = create()
    :register_handler(handshake_handler :: PacketHandler)
    :register(serverbound_handshake)
    :freeze()
const SERVERBOUND_STATUS = create()
    :register_handler(status_handler :: PacketHandler)
    :register(serverbound_status_request)
    :register(serverbound_ping_request)
    :freeze()
const CLIENTBOUND_STATUS = create()
    :register(clientbound_status_response)
    :register(clientbound_ping_response)
    :freeze()
const SERVERBOUND_LOGIN = create()
    :freeze()
const CLIENTBOUND_LOGIN = create()
    :freeze()
const SERVERBOUND_CONFIGURATION = create()
    :freeze()
const CLIENTBOUND_CONFIGURATION = create()
    :freeze()
const SERVERBOUND_PLAY = create()
    :freeze()
const CLIENTBOUND_PLAY = create()
    :freeze()
-- stylua: ignore end

const SERVERBOUND: { read [number]: PacketRegistry } = table.freeze({
    [enum.CONNECTION_INTENT.HANDSHAKE] = SERVERBOUND_HANDSHAKE,
    [enum.CONNECTION_INTENT.STATUS] = SERVERBOUND_STATUS,
    [enum.CONNECTION_INTENT.CONFIGURATION] = SERVERBOUND_CONFIGURATION,
    [enum.CONNECTION_INTENT.LOGIN] = SERVERBOUND_LOGIN,
    [enum.CONNECTION_INTENT.PLAY] = SERVERBOUND_PLAY,
})

const CLIENTBOUND: { read [number]: PacketRegistry } = table.freeze({
    [enum.CONNECTION_INTENT.STATUS] = CLIENTBOUND_STATUS,
    [enum.CONNECTION_INTENT.CONFIGURATION] = CLIENTBOUND_CONFIGURATION,
    [enum.CONNECTION_INTENT.LOGIN] = CLIENTBOUND_LOGIN,
    [enum.CONNECTION_INTENT.PLAY] = CLIENTBOUND_PLAY,
})

export function get(flow: number, intent: number): PacketRegistry
    const registry = if flow == enum.PACKET_FLOW.SERVERBOUND
        then SERVERBOUND
        elseif flow == enum.PACKET_FLOW.CLIENTBOUND then CLIENTBOUND
        else error("not a valid packet flow")

    return assert(
        registry[intent],
        `no packets with flow '{flow}' registered for intent '{intent}'`
    )
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
