--!optimize 2

const function assert_range(n: number, min: number, max: number, msg: string?): number
    assert(n <= max and n >= min, msg)

    return n
end

const function assert_isint(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n % 1 == 0, msg)

    return n
end

const function assert_isfloat(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n % 1 ~= 0, msg)

    return n
end

const function assert_bits_signed(n: number, b: number, msg: string?): number
    assert_isint(n, msg)
    assert(n >= -(2 ^ (b - 1)) and n < 2 ^ (b - 1), msg)

    return n
end

const function assert_bits_unsigned(n: number, b: number, msg: string?): number
    assert_isint(n, msg)
    assert(n >= 0 and n < 2 ^ b, msg)

    return n
end

const function assert_isu8(n: number, msg: string?): number
    return assert_bits_unsigned(n, 8, msg)
end

const function assert_isi8(n: number, msg: string?): number
    return assert_bits_signed(n, 8, msg)
end

const function assert_isu16(n: number, msg: string?): number
    return assert_bits_unsigned(n, 16, msg)
end

const function assert_isi16(n: number, msg: string?): number
    return assert_bits_signed(n, 16, msg)
end

const function assert_isu24(n: number, msg: string?): number
    return assert_bits_unsigned(n, 24, msg)
end

const function assert_isi24(n: number, msg: string?): number
    return assert_bits_signed(n, 24, msg)
end

const function assert_isu32(n: number, msg: string?): number
    return assert_bits_unsigned(n, 32, msg)
end

const function assert_isi32(n: number, msg: string?): number
    return assert_bits_signed(n, 32, msg)
end

const function assert_isf32(n: number, msg: string?): number
    assert(math.isfinite(n), msg)
    assert(n >= -(2 - 2 ^ -23) * 2 ^ 127 and n <= (2 - 2 ^ -23) * 2 ^ 127, msg)

    return n
end

const function assert_isf64(n: number, msg: string?): number
    assert(math.isfinite(n), msg)

    return n
end

return table.freeze({
    range = assert_range,
    bits_signed = assert_bits_signed,
    bits_unsigned = assert_bits_unsigned,
    is_int = assert_isint,
    is_float = assert_isfloat,
    is_u8 = assert_isu8,
    is_i8 = assert_isi8,
    is_u16 = assert_isu16,
    is_i16 = assert_isi16,
    is_u24 = assert_isu24,
    is_i24 = assert_isi24,
    is_u32 = assert_isu32,
    is_i32 = assert_isi32,
    is_f32 = assert_isf32,
    is_f64 = assert_isf64,
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
