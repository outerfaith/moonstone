--!optimize 2

local linkedQueue = {}
linkedQueue.__index = linkedQueue

export type Node<T> = {
    read value: T,
    next: Node<T>?,
}

export type LinkedQueue<T> = typeof(setmetatable(
    {} :: {
        head: Node<T>?,
        tail: Node<T>?,
        size: number,
    },
    linkedQueue
))

function linkedQueue.new<T>(): LinkedQueue<T>
    return setmetatable({
        size = 0,
    }, linkedQueue)
end

function linkedQueue.__iter<T>(self: LinkedQueue<T>): () -> T?
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

function linkedQueue.add<T>(self: LinkedQueue<T>, value: T)
    local node: Node<T> = {
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

function linkedQueue.peek<T>(self: LinkedQueue<T>)
    local head = self.head
    return if head ~= nil then head.value else nil
end

function linkedQueue.poll<T>(self: LinkedQueue<T>): T?
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

function linkedQueue.isEmpty<T>(self: LinkedQueue<T>)
    return self.head == nil
end

return linkedQueue

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
