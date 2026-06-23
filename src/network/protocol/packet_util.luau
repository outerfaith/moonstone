--!optimize 2

const connection = require("@moonstone/network/connection")
const packet = require("@moonstone/network/protocol/packet")
const lazy_require = require("@moonstone/util/lazy_require")

type Connection = connection.Connection
type Packet<T> = packet.Packet<T>

const packet_coding = lazy_require<<any>>("@moonstone/network/protocol/packet_coding")

export function send_packet<T>(connection: Connection, packet: Packet<T>, data: T)
    const encoded = packet_coding().encode(packet, data)
    connection:enqueue_write(encoded)
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
