--!optimize 2

type Node<T> = {
    read value: T,
    next: Node<T>?,
}

type LinkedQueueProto = {
    __index: LinkedQueueProto,
    __iter: (self: LinkedQueue) -> () -> any?,
    add: (self: LinkedQueue, value: any) -> (),
    peek: (self: LinkedQueue) -> any?,
    poll: (self: LinkedQueue) -> any?,
    isEmpty: (self: LinkedQueue) -> boolean,
}

export type LinkedQueue = setmetatable<{
    head: Node<any>?,
    tail: Node<any>?,
    size: number,
}, LinkedQueueProto>

local linkedQueue = {} :: LinkedQueueProto
linkedQueue.__index = linkedQueue

function linkedQueue.__iter(self)
    local node = self.head

    return function()
        if node == nil then
            return nil
        end

        local value = node.value

        node = node.next
        return value
    end
end

function linkedQueue.add(self, value)
    local node: Node<any> = {
        value = value,
    }

    if self.tail ~= nil then
        self.tail.next = node
    else
        self.head = node
    end

    self.tail = node
    self.size += 1
end

function linkedQueue.peek(self)
    local head = self.head
    return head and head.value or nil
end

function linkedQueue.poll(self)
    local head = self.head

    if head == nil then
        return nil
    end

    self.head = head.next
    self.size -= 1
    if self.head == nil then
        self.tail = nil
    end

    return head.value
end

function linkedQueue.isEmpty(self)
    return self.head == nil
end

local function new()
    return setmetatable({
        size = 0,
    }, linkedQueue) :: LinkedQueue
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
