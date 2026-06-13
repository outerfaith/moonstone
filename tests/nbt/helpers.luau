--!optimize 2
--!native

const friendly_buf = require("@moonstone/util/friendly_buf")

type FriendlyBuf = friendly_buf.FriendlyBuf

const function buf_from_bytes(bytes: { number })
    const buf = friendly_buf.allocate(#bytes)

    for _, byte in ipairs(bytes) do
        buf:write_u8(byte)
    end

    buf.position = 0
    return buf
end

const function written_bytes(buf: FriendlyBuf): { number }
    const bytes = {}

    for i = 0, buf.position - 1 do
        table.insert(bytes, buffer.readu8(buf._buffer, i))
    end

    return bytes
end

const function all_bytes(buf: FriendlyBuf): { number }
    const bytes = {}

    for i = 0, buffer.len(buf._buffer) - 1 do
        table.insert(bytes, buffer.readu8(buf._buffer, i))
    end

    return bytes
end

const function assert_tag(asserts: any, tag: any, id: number, value: any)
    asserts.eq(id, tag.id)
    asserts.eq(value, tag.value)
end

const function assert_named_tag(asserts: any, named_tag: any, name: string, id: number, value: any)
    asserts.eq(name, named_tag.name)
    assert_tag(asserts, named_tag.tag, id, value)
end

return table.freeze({
    buf_from_bytes = buf_from_bytes,
    written_bytes = written_bytes,
    all_bytes = all_bytes,
    assert_tag = assert_tag,
    assert_named_tag = assert_named_tag,
})
