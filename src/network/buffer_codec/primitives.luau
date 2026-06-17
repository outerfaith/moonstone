--!optimize 2

const buffer_codec = require("@moonstone/network/buffer_codec")

export const BOOLEAN = buffer_codec.new<<boolean>>(function(buf)
    return buf:get_u8() ~= 0
end, function(buf, value)
    buf:write_u8(value and 1 or 0)
end)

export const BYTE = buffer_codec.new<<number>>(function(buf)
    return buf:get_i8()
end, function(buf, value)
    buf:write_i8(value)
end)

export const UNSIGNED_BYTE = buffer_codec.new<<number>>(function(buf)
    return buf:get_u8()
end, function(buf, value)
    buf:write_u8(value)
end)

export const SHORT = buffer_codec.new<<number>>(function(buf)
    return buf:get_i16()
end, function(buf, value)
    buf:write_i16(value)
end)

export const UNSIGNED_SHORT = buffer_codec.new<<number>>(function(buf)
    return buf:get_u16()
end, function(buf, value)
    buf:write_u16(value)
end)

export const INT = buffer_codec.new<<number>>(function(buf)
    return buf:get_i32()
end, function(buf, value)
    buf:write_i32(value)
end)

export const LONG = buffer_codec.new<<integer>>(function(buf)
    return buf:get_i64()
end, function(buf, value)
    buf:write_i64(value)
end)

export const FLOAT = buffer_codec.new<<number>>(function(buf)
    return buf:get_f32()
end, function(buf, value)
    buf:write_f32(value)
end)

export const DOUBLE = buffer_codec.new<<number>>(function(buf)
    return buf:get_f64()
end, function(buf, value)
    buf:write_f64(value)
end)

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
