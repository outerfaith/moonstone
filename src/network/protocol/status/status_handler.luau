--!optimize 2

const jecs = require("@vendor/jecs")

const world = require("@moonstone/ecs/world")
const client_connection = require("@moonstone/ecs/components/client_connection")
const handler = require("@moonstone/network/protocol/handler")
const packet = require("@moonstone/network/protocol/packet")
const packet_util = require("@moonstone/network/protocol/packet_util")
-- stylua: ignore start
const clientbound_ping_response = require("@moonstone/network/protocol/status/clientbound_ping_response")
const clientbound_status_response = require("@moonstone/network/protocol/status/clientbound_status_response")
const serverbound_ping_request = require("@moonstone/network/protocol/status/serverbound_ping_request")
const serverbound_status_request = require("@moonstone/network/protocol/status/serverbound_status_request")
-- stylua: ignore end
const enum = require("@moonstone/util/enum")

type Entity = jecs.Entity
type PacketHandler = handler.PacketHandler
type Packet<T> = packet.Packet<T>
type ClientConnection = client_connection.ClientConnection
type ClientboundPingResponse = clientbound_ping_response.Fields
type CLientboundStatusResponse = clientbound_status_response.Fields
type ServerboundPingRequest = serverbound_ping_request.Fields
type ServerboundStatusRequest = serverbound_status_request.Fields

const function handle_ping_request(packet: ServerboundPingRequest, e: Entity)
    const client = assert(world:get(e, client_connection), "entity has no ClientConnection")

    packet_util.send_packet<<ClientboundPingResponse>>(
        client.connection,
        clientbound_ping_response,
        {
            payload = packet.payload,
        }
    )
end

const function handle_status_request(packet: ServerboundStatusRequest, e: Entity)
    const client = assert(world:get(e, client_connection), "entity has no ClientConnection")

    packet_util.send_packet<<CLientboundStatusResponse>>(
        client.connection,
        clientbound_status_response,
        -- TODO(outerfaith): fetch data from server configuration
        {
            version = {
                name = "26.2",
                protocol = 776,
            },
            players = {
                max = 67,
                online = 1,
                sample = {},
            },
            description = "powered by lute.. or something",
            enforcesSecureChat = true,
        }
    )
end

const HANDLERS: { read [Packet<any>]: (any, Entity) -> () } = {
    [serverbound_ping_request] = handle_ping_request,
    [serverbound_status_request] = handle_status_request,
}

const function handler_for<T>(packet: Packet<T>): (T, Entity) -> ()
    return HANDLERS[packet]
end

return table.freeze({
    flow = enum.PACKET_FLOW.SERVERBOUND,
    intent = enum.CONNECTION_INTENT.STATUS,
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
