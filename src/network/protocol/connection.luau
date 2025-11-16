--!optimize 2

local byteBuf = require("../../util/byteBuf")
local enum = require("../../util/enum")
local linkedQueue = require("../../util/collection/linkedQueue")
local packet = require("./packet")
local decodePacket = require("./serialization/decodePacket")
local encodePacket = require("./serialization/encodePacket")
local packetRegistry = require("./packetRegistry")
local sharedTypes = require("./sharedTypes")

type ConnectionProto = sharedTypes.ConnectionProto
export type Connection = sharedTypes.Connection

local READ_LIMIT_BYTES = 8192

local connection = {} :: ConnectionProto
connection.__index = connection

function connection.processPackets(self: Connection)
    local recv = self._socket:recv(READ_LIMIT_BYTES)
    local asbuf = byteBuf.wrap(recv)

    local type, data = decodePacket(asbuf, self:getServerboundPacketRegistry())
    type.handle(self, data)
end

function connection.enqueueWrite(self: Connection, write: byteBuf.ByteBuf)
    self._writeQueue:add(write)
end

function connection.sendPacket<T>(self: Connection, pkt: packet.Packet<T>, data: T)
    local id = self:getClientboundPacketRegistry():getId(pkt)
    local encoded = encodePacket(pkt, data, id)

    self:enqueueWrite(encoded)
end

function connection.getClientboundPacketRegistry(self: Connection)
    return packetRegistry.clientboundForIntent(self.intent)
end

function connection.getServerboundPacketRegistry(self: Connection)
    return packetRegistry.serverboundForIntent(self.intent)
end

function connection.flush(self: Connection)
    while not self._writeQueue:isEmpty() do
        local write: byteBuf.ByteBuf = self._writeQueue:poll()
        self._socket:send(write._buffer)
    end
end

function connection.close(self: Connection)
    self._socket:close()
end

function connection.addPersistentValue(self: Connection, key, value)
    assert(self._metadata[key] == nil, `there is already a metadata entry for '{key}'`)
    self._metadata[key] = value
end

function connection.removePersistentValue(self: Connection, key)
    assert(self._metadata[key] ~= nil, `no metadata has been registered for '{key}'`)
    self._metadata[key] = nil
end

function connection.clearPersistentValues(self: Connection)
    table.clear(self._metadata)
end

local function new(socket: NetworkSocket)
    return setmetatable({
        _socket = socket,
        _writeQueue = linkedQueue.new(),
        _metadata = {},
        intent = enum.intent.HANDSHAKE,
    }, connection) :: Connection
end

return table.freeze({
    new = new,
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
