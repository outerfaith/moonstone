--!optimize 2
--!native

const friendly_buf = require("@moonstone/util/friendly_buf")

const function buf_from_bytes(bytes: { number })
    const buf = friendly_buf.allocate(#bytes)

    for _, byte in ipairs(bytes) do
        buf:write_u8(byte)
    end

    buf.position = 0
    return buf
end

const function friendly_from_bytes(bytes: { number })
    return buf_from_bytes(bytes)
end

const function written_bytes(buf: any): { number }
    const bytes = {}

    for i = 0, buf.position - 1 do
        table.insert(bytes, buffer.readu8(buf._buffer, i))
    end

    return bytes
end

const function all_bytes(buf: any): { number }
    const bytes = {}

    for i = 0, buffer.len(buf._buffer) - 1 do
        table.insert(bytes, buffer.readu8(buf._buffer, i))
    end

    return bytes
end

const function write_to_bytes(size: number, codec: any, value: any): { number }
    const buf = friendly_buf.allocate(size)

    codec:write(buf, value)

    return written_bytes(buf)
end

const function string_bytes(value: string): { number }
    const bytes = {}

    for i = 1, string.len(value) do
        table.insert(bytes, string.byte(value, i) :: number)
    end

    return bytes
end

return table.freeze({
    all_bytes = all_bytes,
    buf_from_bytes = buf_from_bytes,
    friendly_from_bytes = friendly_from_bytes,
    string_bytes = string_bytes,
    write_to_bytes = write_to_bytes,
    written_bytes = written_bytes,
})

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
