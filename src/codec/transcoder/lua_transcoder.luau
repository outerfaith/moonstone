--!optimize 2
--!nolint UnknownType

const data_result = require("@moonstone/codec/data_result")
const transcoder = require("@moonstone/codec/transcoder")
const assertions = require("@moonstone/util/assertions")

type DataResult<T> = data_result.DataResult<T>
type Transcoder<T> = transcoder.Transcoder<T>

type Dictionary<T> = { read [string]: T }

const lua_transcoder = {} :: Transcoder<any>
lua_transcoder.__index = lua_transcoder

function lua_transcoder.create_nil(self)
    return nil
end

function lua_transcoder.create_string(self, value)
    assert(type(value) == "string", "value is not a string")
    return value
end

function lua_transcoder.create_i8(self, value)
    assert(type(value) == "number", "value is not a number")
    assertions.is_i8(value, "value is not within range")

    return value
end

function lua_transcoder.create_i16(self, value)
    assert(type(value) == "number", "value is not a number")
    assertions.is_i16(value, "value is not within range")

    return value
end

function lua_transcoder.create_i32(self, value)
    assert(type(value) == "number", "value is not a number")
    assertions.is_i32(value, "value is not within range")

    return value
end

function lua_transcoder.create_i64(self, value)
    assert(type(value) == "integer", "value is not an integer")

    return value
end

function lua_transcoder.create_f32(self, value)
    assert(type(value) == "number", "value is not a number")
    assertions.is_f32(value, "value is not within range")

    return value
end

function lua_transcoder.create_f64(self, value)
    assert(type(value) == "number", "value is not a number")
    assertions.is_f64(value, "value is not within range")

    return value
end

function lua_transcoder.create_boolean(self, value)
    assert(type(value) == "boolean", "value is not a string")

    return value
end

function lua_transcoder.create_dictionary(self, value)
    -- TODO(outerfaith): some way to validate that keys are strings
    assert(type(value) == "table", "value is not a table")

    return value
end

function lua_transcoder.create_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(idx) == "number", "entry key is not a number")
    end

    return value
end

function lua_transcoder.create_i8_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "number", "entry is not a number")
        assertions.is_i8(entry, "entry is not within range")
    end

    return value
end

function lua_transcoder.create_i32_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "number", "entry is not a number")
        assertions.is_i32(entry, "entry is not within range")
    end

    return value
end

function lua_transcoder.create_i64_array(self, value)
    assert(type(value) == "table", "value is not a table")
    for idx, entry in value do
        assert(type(entry) == "integer", "entry is not an integer")
    end

    return value
end

function lua_transcoder.get_string(self, value)
    return transcoder.check<<string>>(value, "string")
end

function lua_transcoder.get_i8(self, value)
    return data_result.map<<number, number>>(
        transcoder.check<<number>>(value, "number"),
        function(v)
            return assertions.is_i8(v, "value is not within range")
        end
    )
end

function lua_transcoder.get_i16(self, value)
    return data_result.map<<number, number>>(
        transcoder.check<<number>>(value, "number"),
        function(v)
            return assertions.is_i16(v, "value is not within range")
        end
    )
end

function lua_transcoder.get_i32(self, value)
    return data_result.map<<number, number>>(
        transcoder.check<<number>>(value, "number"),
        function(v)
            return assertions.is_i32(v, "value is not within range")
        end
    )
end

function lua_transcoder.get_i64(self, value)
    return transcoder.check<<integer>>(value, "integer")
end

function lua_transcoder.get_f32(self, value)
    return data_result.map<<number, number>>(
        transcoder.check<<number>>(value, "number"),
        function(v)
            return assertions.is_f32(v, "value is not within range")
        end
    )
end

function lua_transcoder.get_f64(self, value)
    return data_result.map<<number, number>>(
        transcoder.check<<number>>(value, "number"),
        function(v)
            return assertions.is_f64(v, "value is not within range")
        end
    )
end

function lua_transcoder.get_boolean(self, value)
    return transcoder.check<<boolean>>(value, "boolean")
end

function lua_transcoder.get_dictionary(self, value)
    return data_result.map<<Dictionary<any>, Dictionary<any>>>(
        transcoder.check<<Dictionary<any>>>(value, "table"),
        function(v)
            -- TODO(outerfaith): some way to validate that keys are strings
            return v
        end
    )
end

function lua_transcoder.get_array(self, value)
    -- TODO(outerfaith): some way to validate keys are numbers
    return transcoder.check<<{ any }>>(value, "table")
end

function lua_transcoder.get_i8_array(self, value)
    -- TODO(outerfaith): some way to validate keys are numbers and values are within range
    return transcoder.check<<{ number }>>(value, "table")
end

function lua_transcoder.get_i32_array(self, value)
    -- TODO(outerfaith): some way to validate keys are numbers and values are within range
    return transcoder.check<<{ number }>>(value, "table")
end

function lua_transcoder.get_i64_array(self, value)
    -- TODO(outerfaith): some way to validate keys are numbers and values are integers
    return transcoder.check<<{ integer }>>(value, "table")
end

return transcoder.impl(lua_transcoder)

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
