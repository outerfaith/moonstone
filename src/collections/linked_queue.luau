--!optimize 2

export type Node<T> = {
    read value: T,
    next: Node<T>?,
}

type LinkedQueueProto<T> = {
    __index: LinkedQueueProto<T>,
    __iter: (self: LinkedQueue<T>) -> () -> T,
    enqueue: (self: LinkedQueue<T>, value: T) -> (),
    dequeue: (self: LinkedQueue<T>) -> T?,
    peek: (self: LinkedQueue<T>) -> T?,
    is_empty: (self: LinkedQueue<T>) -> boolean,
}

export type LinkedQueue<T> = setmetatable<{
    head: Node<T>?,
    tail: Node<T>?,
    size: number,
}, LinkedQueueProto<T>>

const linked_queue = {} :: LinkedQueueProto<unknown>
linked_queue.__index = linked_queue

export function new<T>(): LinkedQueue<T>
    return setmetatable({
        head = nil,
        tail = nil,
        size = 0,
    }, linked_queue) :: any
end

function linked_queue.__iter(self)
    local node = self.head

    return function()
        if node == nil then
            return nil :: unknown
        end

        const current = node

        node = current.next
        return current.value
    end
end

function linked_queue.enqueue(self, value)
    const node: Node<unknown> = {
        value = value,
    }

    const tail = self.tail
    if tail ~= nil then
        tail.next = node
    else
        self.head = node
    end
    self.tail = node
    self.size += 1
end

function linked_queue.dequeue(self)
    const head = self.head
    if head == nil then
        return nil
    end

    const next_node = head.next

    self.head = next_node
    self.size -= 1

    if next_node == nil then
        self.tail = nil
    end

    return head.value
end

function linked_queue.peek(self)
    const head = self.head
    return if head ~= nil then head.value else nil
end

function linked_queue.is_empty(self)
    return self.head == nil
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
