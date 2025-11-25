--!optimize 2

local byteBuf = require("../../util/byteBuf")
local linkedQueue = require("../../util/collection/linkedQueue")
local networkType = require("../networkType")

export type Packet<T> = {
    read networkType: networkType.NetworkType<T>,
}

export type ServerboundPacket<T> = Packet<T> & {
    read handle: (connection: Connection, data: T) -> (),
}

export type PacketRegistryProto = {
    __index: PacketRegistryProto,
    register: <T>(self: PacketRegistry, id: number, packet: Packet<T>) -> PacketRegistry,
    getId: <T>(self: PacketRegistry, packet: Packet<T>) -> number,
    get: <T>(self: PacketRegistry, id: number) -> Packet<T>,
}

export type PacketRegistry = setmetatable<{
    read idToType: { [number]: Packet<unknown> },
    read typeToId: { [Packet<unknown>]: number },
}, PacketRegistryProto>

export type ConnectionProto = {
    __index: ConnectionProto,
    processPackets: (self: Connection) -> (),
    enqueueWrite: (self: Connection, write: byteBuf.ByteBuf) -> (),
    sendPacket: <T>(self: Connection, packet: Packet<T>, data: T) -> (),
    getClientboundPacketRegistry: (self: Connection) -> PacketRegistry,
    getServerboundPacketRegistry: (self: Connection) -> PacketRegistry,
    flush: (self: Connection) -> (),
    close: (self: Connection) -> (),
    addPersistentValue: (self: Connection, key: string, value: any) -> (),
    removePersistentValue: (self: Connection, key: string) -> (),
    clearPersistentValues: (self: Connection) -> (),
}

export type Connection = setmetatable<{
    read _socket: NetworkSocket,
    _readBuffer: buffer?,
    read _writeQueue: linkedQueue.LinkedQueue<byteBuf.ByteBuf>,
    read _metadata: { [string]: any },
    intent: number,
}, ConnectionProto>

return nil

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
