--!optimize 2

const test = require("@std/test")

const assertions = require("@moonstone/util/assertions")

const F32_MAX = (2 - 2 ^ -23) * 2 ^ 127

test.suite("Assertions", function(suite)
    suite:case("exports assertion helpers", function(asserts)
        asserts.eq("function", type(assertions.range))
        asserts.eq("function", type(assertions.bits_signed))
        asserts.eq("function", type(assertions.bits_unsigned))
        asserts.eq("function", type(assertions.is_int))
        asserts.eq("function", type(assertions.is_float))
        asserts.eq("function", type(assertions.is_u8))
        asserts.eq("function", type(assertions.is_i8))
        asserts.eq("function", type(assertions.is_u16))
        asserts.eq("function", type(assertions.is_i16))
        asserts.eq("function", type(assertions.is_u24))
        asserts.eq("function", type(assertions.is_i24))
        asserts.eq("function", type(assertions.is_u32))
        asserts.eq("function", type(assertions.is_i32))
        asserts.eq("function", type(assertions.is_f32))
        asserts.eq("function", type(assertions.is_f64))
    end)

    suite:case("range returns values inside inclusive bounds", function(asserts)
        asserts.eq(-2, assertions.range(-2, -2, 3))
        asserts.eq(0, assertions.range(0, -2, 3))
        asserts.eq(3, assertions.range(3, -2, 3))
    end)

    suite:case("range rejects values outside bounds", function(asserts)
        asserts.throwsWith("range fail", function()
            assertions.range(-3, -2, 3, "range fail")
        end)

        asserts.throwsWith("range fail", function()
            assertions.range(4, -2, 3, "range fail")
        end)
    end)

    suite:case("is_int accepts finite integers only", function(asserts)
        asserts.eq(0, assertions.is_int(0))
        asserts.eq(-42, assertions.is_int(-42))
        asserts.eq(2 ^ 32, assertions.is_int(2 ^ 32))

        asserts.throwsWith("int fail", function()
            assertions.is_int(1.5, "int fail")
        end)

        asserts.throwsWith("int fail", function()
            assertions.is_int(math.huge, "int fail")
        end)
    end)

    suite:case("is_float accepts finite non-integers only", function(asserts)
        asserts.eq(0.5, assertions.is_float(0.5))
        asserts.eq(-12.25, assertions.is_float(-12.25))

        asserts.throwsWith("float fail", function()
            assertions.is_float(1, "float fail")
        end)

        asserts.throwsWith("float fail", function()
            assertions.is_float(math.huge, "float fail")
        end)
    end)

    suite:case("bits_signed uses signed integer bit bounds", function(asserts)
        asserts.eq(-4, assertions.bits_signed(-4, 3))
        asserts.eq(0, assertions.bits_signed(0, 3))
        asserts.eq(3, assertions.bits_signed(3, 3))

        asserts.throwsWith("signed bits fail", function()
            assertions.bits_signed(-5, 3, "signed bits fail")
        end)

        asserts.throwsWith("signed bits fail", function()
            assertions.bits_signed(4, 3, "signed bits fail")
        end)

        asserts.throwsWith("signed bits fail", function()
            assertions.bits_signed(1.5, 3, "signed bits fail")
        end)
    end)

    suite:case("bits_unsigned uses unsigned integer bit bounds", function(asserts)
        asserts.eq(0, assertions.bits_unsigned(0, 3))
        asserts.eq(4, assertions.bits_unsigned(4, 3))
        asserts.eq(7, assertions.bits_unsigned(7, 3))

        asserts.throwsWith("unsigned bits fail", function()
            assertions.bits_unsigned(-1, 3, "unsigned bits fail")
        end)

        asserts.throwsWith("unsigned bits fail", function()
            assertions.bits_unsigned(8, 3, "unsigned bits fail")
        end)

        asserts.throwsWith("unsigned bits fail", function()
            assertions.bits_unsigned(1.5, 3, "unsigned bits fail")
        end)
    end)

    suite:case("fixed-width unsigned integer helpers enforce bounds", function(asserts)
        asserts.eq(0, assertions.is_u8(0))
        asserts.eq(0xFF, assertions.is_u8(0xFF))
        asserts.eq(0, assertions.is_u16(0))
        asserts.eq(0xFFFF, assertions.is_u16(0xFFFF))
        asserts.eq(0, assertions.is_u24(0))
        asserts.eq(0xFFFFFF, assertions.is_u24(0xFFFFFF))
        asserts.eq(0, assertions.is_u32(0))
        asserts.eq(0xFFFFFFFF, assertions.is_u32(0xFFFFFFFF))

        asserts.throwsWith("u8 fail", function()
            assertions.is_u8(0x100, "u8 fail")
        end)

        asserts.throwsWith("u16 fail", function()
            assertions.is_u16(0x10000, "u16 fail")
        end)

        asserts.throwsWith("u24 fail", function()
            assertions.is_u24(0x1000000, "u24 fail")
        end)

        asserts.throwsWith("u32 fail", function()
            assertions.is_u32(0x100000000, "u32 fail")
        end)
    end)

    suite:case("fixed-width signed integer helpers enforce bounds", function(asserts)
        asserts.eq(-0x80, assertions.is_i8(-0x80))
        asserts.eq(0x7F, assertions.is_i8(0x7F))
        asserts.eq(-0x8000, assertions.is_i16(-0x8000))
        asserts.eq(0x7FFF, assertions.is_i16(0x7FFF))
        asserts.eq(-0x800000, assertions.is_i24(-0x800000))
        asserts.eq(0x7FFFFF, assertions.is_i24(0x7FFFFF))
        asserts.eq(-0x80000000, assertions.is_i32(-0x80000000))
        asserts.eq(0x7FFFFFFF, assertions.is_i32(0x7FFFFFFF))

        asserts.throwsWith("i8 fail", function()
            assertions.is_i8(-0x81, "i8 fail")
        end)

        asserts.throwsWith("i16 fail", function()
            assertions.is_i16(0x8000, "i16 fail")
        end)

        asserts.throwsWith("i24 fail", function()
            assertions.is_i24(0x800000, "i24 fail")
        end)

        asserts.throwsWith("i32 fail", function()
            assertions.is_i32(0x80000000, "i32 fail")
        end)
    end)

    suite:case("float helpers accept finite values within their ranges", function(asserts)
        asserts.eq(0, assertions.is_f32(0))
        asserts.eq(F32_MAX, assertions.is_f32(F32_MAX))
        asserts.eq(-F32_MAX, assertions.is_f32(-F32_MAX))
        asserts.eq(math.pi, assertions.is_f64(math.pi))
        asserts.eq(2 ^ 1023, assertions.is_f64(2 ^ 1023))
    end)

    suite:case("float helpers reject non-finite and out-of-range values", function(asserts)
        asserts.throwsWith("f32 fail", function()
            assertions.is_f32(F32_MAX * 2, "f32 fail")
        end)

        asserts.throwsWith("f32 fail", function()
            assertions.is_f32(math.huge, "f32 fail")
        end)

        asserts.throwsWith("f64 fail", function()
            assertions.is_f64(math.huge, "f64 fail")
        end)
    end)
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
