--!optimize 2

export function range(n: number, min: number, max: number, msg: string?): number
    assert(n <= max and n >= min, msg)

    return n
end

export function is_int(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n % 1 == 0, msg)

    return n
end

export function is_float(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n % 1 ~= 0, msg)

    return n
end

export function bits_signed(n: number, b: number, msg: string?): number
    is_int(n, msg)
    assert(n >= -(2 ^ (b - 1)) and n < 2 ^ (b - 1), msg)

    return n
end

export function bits_unsigned(n: number, b: number, msg: string?): number
    is_int(n, msg)
    assert(n >= 0 and n < 2 ^ b, msg)

    return n
end

export function is_u8(n: number, msg: string?): number
    return bits_unsigned(n, 8, msg)
end

export function is_i8(n: number, msg: string?): number
    return bits_signed(n, 8, msg)
end

export function is_u16(n: number, msg: string?): number
    return bits_unsigned(n, 16, msg)
end

export function is_i16(n: number, msg: string?): number
    return bits_signed(n, 16, msg)
end

export function is_u24(n: number, msg: string?): number
    return bits_unsigned(n, 24, msg)
end

export function is_i24(n: number, msg: string?): number
    return bits_signed(n, 24, msg)
end

export function is_u32(n: number, msg: string?): number
    return bits_unsigned(n, 32, msg)
end

export function is_i32(n: number, msg: string?): number
    return bits_signed(n, 32, msg)
end

export function is_f32(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n >= -(2 - 2 ^ -23) * 2 ^ 127 and n <= (2 - 2 ^ -23) * 2 ^ 127, msg)

    return n
end

export function is_f64(n: number, msg: string?): number
    assert(math.isfinite(n), msg)

    return n
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
