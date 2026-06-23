--!optimize 2
--!native

const buffer_codec = require("@moonstone/network/buffer_codec/helper")
const packet = require("@moonstone/network/protocol/packet")
const packet_registry = require("@moonstone/network/protocol/packet_registry")
const friendly_buf = require("@moonstone/util/friendly_buf")

type Packet<T> = packet.Packet<T>
type PacketRegistry = packet_registry.PacketRegistry
type FriendlyBuf = friendly_buf.FriendlyBuf

const DEFAULT_BUFFER_SIZE = 8192 * 16
const MAX_PACKET_SIZE = 2 ^ 21

export function decode<T>(buf: FriendlyBuf, registry: PacketRegistry): (Packet<T>, T)
    const id: number = buffer_codec.VAR_INT:read(buf)
    const type = registry:lookup(id)

    assert(type ~= nil, `no packet registered with id '{id}'`)

    return type, type.codec:read(buf)
end

export function encode<T>(packet: Packet<T>, data: T): FriendlyBuf
    const body = friendly_buf.allocate(256)

    buffer_codec.VAR_INT:write(body, packet.id)
    packet.codec:write(body, data)

    const body_len = body.position

    body:trim()

    assert(
        body_len <= MAX_PACKET_SIZE,
        `packet length of '{body_len}' bytes is larger than maximum allowed size of '{MAX_PACKET_SIZE}' bytes`
    )

    const out = friendly_buf.allocate(body_len + 5)

    buffer_codec.VAR_INT:write(out, body_len)
    out:write_slice(body)
    out:trim()

    return out
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
