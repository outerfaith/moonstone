--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec")
const variable_sized = require("@moonstone/network/buffer_codec/variable_sized")
const friendly_buf = require("@moonstone/util/friendly_buf")

type BufferCodec<T> = buffer_codec.BufferCodec<T>
type FriendlyBuf = friendly_buf.FriendlyBuf

const BYTE_ARRAY = buffer_codec.new<<FriendlyBuf>>(function(buf)
    const length = variable_sized.VAR_INT:read(buf)
    const bytes = buf:get_slice(length)

    return bytes
end, function(buf, value)
    variable_sized.VAR_INT:write(buf, buffer.len(value._buffer))
    buf:write_slice(value)
end)

const TERMINATING_BYTE_ARRAY = buffer_codec.new<<FriendlyBuf>>(function(buf)
    return buf:get_slice(buf:get_remaining())
end, function(buf, value)
    buf:write_slice(value)
end)

const function array<T>(codec: BufferCodec<T>)
    return buffer_codec.new<<{ T }>>(function(buf)
        const length = variable_sized.VAR_INT:read(buf)
        const result = table.create(length)

        for i = 1, length do
            table.insert(result, codec:read(buf))
        end

        return result
    end, function(buf, value)
        const length = #value

        variable_sized.VAR_INT:write(buf, length)
        for idx, entry in value do
            codec:write(buf, entry)
        end
    end)
end

return table.freeze({
    BYTE_ARRAY = BYTE_ARRAY,
    TERMINATING_BYTE_ARRAY = TERMINATING_BYTE_ARRAY,
    array = array,
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
