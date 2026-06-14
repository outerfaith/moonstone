--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec")
const variable_sized = require("@moonstone/network/buffer_codec/variable_sized")
const assertions = require("@moonstone/util/assertions")

type BufferCodec<T> = buffer_codec.BufferCodec<T>

const function limited(max_length: number): BufferCodec<string>
    assertions.range(max_length, 1, 32767, "max length must be at least 1 and at most 32767")

    const max_bytes = max_length * 4

    return buffer_codec.new<<string>>(function(buf)
        const length = variable_sized.VAR_INT:read(buf)
        assertions.range(length, 0, max_bytes, `string must be at most most {max_bytes} bytes`)

        const str = buf:get_string(length)

        assert(
            (utf8.len(str) and (utf8.len(str) :: number) <= max_length),
            "decoded string is too long"
        )

        return str
    end, function(buf, value)
        const char_length = utf8.len(value)
        const byte_length = string.len(value)

        assert(
            char_length and char_length <= max_length,
            `string is too long, expected at most {max_length} characters but found {char_length} characters`
        )
        assert(byte_length and byte_length <= max_bytes, "string is too large")

        variable_sized.VAR_INT:write(buf, byte_length)
        buf:write_string(value)
    end)
end

const UNLIMITED = limited(32767)

return table.freeze({
    UNLIMITED = UNLIMITED,
    limited = limited,
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
