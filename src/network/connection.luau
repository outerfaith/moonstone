--!optimize 2
--!native

const duration = require("@std/time/duration")
const net = require("@lute/net")

const linked_queue = require("@moonstone/collections/linked_queue")
const friendly_buf = require("@moonstone/util/friendly_buf")

type TcpStream = net.TCPStream
type LinkedQueue<T> = linked_queue.LinkedQueue<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

type ConnectionProto = {
    __index: ConnectionProto,
    enqueue_write: (self: Connection, buf: FriendlyBuf) -> (),
    read: (self: Connection) -> FriendlyBuf,
    flush: (self: Connection) -> (),
    close: (self: Connection, flush: boolean?) -> (),
}

export type Connection = setmetatable<{
    read stream: TcpStream,
    read write_queue: LinkedQueue<FriendlyBuf>,
}, ConnectionProto>

const connection = {} :: ConnectionProto
connection.__index = connection

export function new(stream: TcpStream): Connection
    return table.freeze(setmetatable({
        stream = stream,
        write_queue = linked_queue.new() :: any,
    }, connection))
end

function connection.enqueue_write(self, buf)
    self.write_queue:enqueue(buf)
end

function connection.read(self)
    const recv = self.stream:read(duration.seconds(30))
    const as_friendly = friendly_buf.wrap(recv)

    return as_friendly
end

function connection.flush(self)
    while not self.write_queue:is_empty() do
        const write = self.write_queue:dequeue()
        assert(write ~= nil, "luau")

        self.stream:write(write._buffer)
    end
end

function connection.close(self, flush)
    if flush then
        self:flush()
    end
    self.stream:close()
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
