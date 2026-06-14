--!optimize 2
--!native

const test = require("@std/test")

const linked_queue = require("@moonstone/collections/linked_queue")

const function collect<T>(queue: linked_queue.LinkedQueue<T>, max_values: number?): ({ T }, boolean)
    const values = {}
    const limit = max_values or math.huge

    for value in queue do
        table.insert(values, value)

        if #values > limit then
            return values, false
        end
    end

    return values, true
end

test.suite("LinkedQueue", function(suite)
    suite:case("new queues are empty", function(asserts)
        const queue = linked_queue.new()

        asserts.eq(nil, queue.head)
        asserts.eq(nil, queue.tail)
        asserts.eq(0, queue.size)
        asserts.that(queue:is_empty())
        asserts.eq(nil, queue:peek())
        asserts.eq(nil, queue:dequeue())
        asserts.eq(0, queue.size)
    end)

    suite:case("enqueue appends values and updates endpoints", function(asserts)
        const queue = linked_queue.new()

        queue:enqueue("first")

        asserts.eq(1, queue.size)
        asserts.never.that(queue:is_empty())
        asserts.eq("first", queue:peek())
        asserts.eq(queue.head, queue.tail)
        asserts.eq("first", (queue.head :: any).value)

        queue:enqueue("second")

        asserts.eq(2, queue.size)
        asserts.eq("first", queue:peek())
        asserts.neq(queue.head, queue.tail)
        asserts.eq("second", (queue.tail :: any).value)
        asserts.eq(queue.tail, (queue.head :: any).next)
    end)

    suite:case("dequeue returns values in FIFO order", function(asserts)
        const queue = linked_queue.new()

        queue:enqueue("first")
        queue:enqueue("second")
        queue:enqueue("third")

        asserts.eq("first", queue:dequeue())
        asserts.eq(2, queue.size)
        asserts.eq("second", queue:peek())
        asserts.eq("second", (queue.head :: any).value)

        asserts.eq("second", queue:dequeue())
        asserts.eq(1, queue.size)
        asserts.eq("third", queue:peek())
        asserts.eq(queue.head, queue.tail)

        asserts.eq("third", queue:dequeue())
        asserts.eq(0, queue.size)
        asserts.that(queue:is_empty())
        asserts.eq(nil, queue.head)
        asserts.eq(nil, queue.tail)
        asserts.eq(nil, queue:dequeue())
    end)

    suite:case("peek does not remove values", function(asserts)
        const queue = linked_queue.new()

        queue:enqueue(10)
        queue:enqueue(20)

        asserts.eq(10, queue:peek())
        asserts.eq(10, queue:peek())
        asserts.eq(2, queue.size)
        asserts.eq(10, queue:dequeue())
        asserts.eq(20, queue:peek())
    end)

    suite:case("can be reused after draining", function(asserts)
        const queue = linked_queue.new()

        queue:enqueue("old")
        asserts.eq("old", queue:dequeue())
        asserts.that(queue:is_empty())

        queue:enqueue("new")

        asserts.eq(1, queue.size)
        asserts.eq("new", queue:peek())
        asserts.eq(queue.head, queue.tail)
        asserts.eq("new", queue:dequeue())
        asserts.that(queue:is_empty())
    end)

    suite:case("iteration yields values in queue order without consuming", function(asserts)
        const queue = linked_queue.new()

        queue:enqueue("a")
        queue:enqueue("b")
        queue:enqueue("c")

        local values, terminated = collect(queue, queue.size)

        asserts.that(terminated, "queue iteration should terminate after all nodes")
        asserts.eq({ "a", "b", "c" }, values)
        asserts.eq(3, queue.size)
        asserts.eq("a", queue:peek())

        values, terminated = collect(queue, queue.size)
        asserts.that(terminated, "queue iteration should remain repeatable")
        asserts.eq({ "a", "b", "c" }, values)
    end)

    suite:case("iteration over an empty queue yields no values", function(asserts)
        const queue = linked_queue.new()
        const values, terminated = collect(queue)

        asserts.that(terminated)
        asserts.eq({}, values)
    end)

    suite:case("preserves table payload identity", function(asserts)
        const queue = linked_queue.new()
        const first = { id = 1 }
        const second = { id = 2 }

        queue:enqueue(first)
        queue:enqueue(second)

        asserts.eq(first, queue:peek())
        const values, terminated = collect(queue, queue.size)

        asserts.that(terminated, "queue iteration should terminate with table payloads")
        asserts.eq({ first, second }, values)
        asserts.eq(first, queue:dequeue())
        asserts.eq(second, queue:dequeue())
    end)
end)
