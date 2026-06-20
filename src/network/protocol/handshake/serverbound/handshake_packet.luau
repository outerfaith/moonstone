--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec/helper")
const packet = require("@moonstone/network/protocol/packet")

type Packet<T> = packet.Packet<T>

export type Fields = {
    read protocol_version: number,
    read server_address: string,
    read server_port: number,
    read intent: number,
}

const CODEC = buffer_codec.struct<<Fields>>({
    { buffer_codec.VAR_INT, "protocol_version" },
    { buffer_codec.UNLIMITED_STRING, "server_address" },
    { buffer_codec.UNSIGNED_SHORT, "server_port" },
    { buffer_codec.VAR_INT, "intent" },
})

return table.freeze({
    codec = CODEC,
} :: any) :: Packet<Fields>

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
