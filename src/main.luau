--!optimize 2
--!native

local net = zune.net
local task = zune.task

local connection = require("./network/protocol/connection")

local socket = net.createSocket(
    net.ADDRF.INET,
    bit32.bor(net.SOCKF.STREAM, net.SOCKF.CLOEXEC, net.SOCKF.NONBLOCK),
    net.IPPROTO.TCP
)

socket:setOption(net.SOCKOPTLV.SOCKET, net.SOCKOPT.REUSEADDR, true)
if net.SOCKOPT.REUSEPORT then
    socket:setOption(net.SOCKOPTLV.SOCKET, net.SOCKOPT.REUSEPORT, true)
end

socket:bindIp("127.0.0.1", 25565)
socket:listen()

while socket:isOpen() do
    local incoming = socket:accept()
    local conn = connection.new(incoming)
    task.spawn(function()
        while conn._socket:isOpen() do
            pcall(function()
                conn:processPackets()
            end)
            conn:flush()
        end
    end)
    task.wait()
end

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
