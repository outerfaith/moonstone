--!optimize 2

const jecs = require("@vendor/jecs")

const world = require("@moonstone/ecs/world")
const patch = require("@moonstone/ecs/patch")
const client_connection = require("@moonstone/ecs/components/client_connection")
const handler = require("@moonstone/network/protocol/handler")
const packet = require("@moonstone/network/protocol/packet")
const handshake = require("@moonstone/network/protocol/handshake/serverbound/handshake_packet")
const enum = require("@moonstone/util/enum")
const logger = require("@moonstone/util/logger")

type Entity = jecs.Entity
type PacketHandler = handler.PacketHandler
type Packet<T> = packet.Packet<T>
type ClientConnection = client_connection.ClientConnection
type ServerboundHandshakePacket = handshake.Fields

const LOGGER = logger.new()

const function handle_handshake_packet(packet: ServerboundHandshakePacket, e: Entity)
    const client = assert(world:get(e, client_connection), "entity has no ClientConnection")

    LOGGER:debug(`Setting connection intent to '{packet.intent}', previous was '{client.intent}'`)

    patch<<ClientConnection>>(e, client_connection, client, {
        intent = packet.intent,
    })
end

const HANDLERS: { read [Packet<any>]: (any, Entity) -> () } = {
    [handshake] = handle_handshake_packet,
}

const function handler_for<T>(packet: Packet<T>): (T, Entity) -> ()
    return HANDLERS[packet]
end

return table.freeze({
    flow = enum.PACKET_FLOW.SERVERBOUND,
    intent = enum.CONNECTION_INTENT.HANDSHAKE,
    handler_for = handler_for,
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
