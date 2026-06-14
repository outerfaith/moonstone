--!optimize 2

const friendly_buf = require("@moonstone/util/friendly_buf")

type FriendlyBuf = friendly_buf.FriendlyBuf

type BufferCodecProto<T> = {
    __index: BufferCodecProto<T>,
    read: (self: BufferCodec<T>, buf: FriendlyBuf) -> T,
    read_at_offset: (self: BufferCodec<T>, buf: FriendlyBuf, offset: number) -> T,
    write: (self: BufferCodec<T>, buf: FriendlyBuf, value: T) -> (),
    write_at_offset: (self: BufferCodec<T>, buf: FriendlyBuf, value: T, offset: number) -> (),
    as_optional: (self: BufferCodec<T>) -> OptionalBufferCodec<T>,
}

export type BufferCodec<T> = setmetatable<{
    read reader: (buf: FriendlyBuf) -> T,
    read writer: (buf: FriendlyBuf, value: T) -> (),
}, BufferCodecProto<T>>

-- TODO(outerfaith): get rid of this once restrictions on generics are relaxed
-- i genuinely hate this so much and there's not a better way to do this

type OptionalBufferCodecProto<T> = {
    __index: OptionalBufferCodecProto<T>,
    read: (self: OptionalBufferCodec<T>, buf: FriendlyBuf) -> T?,
    read_at_offset: (self: OptionalBufferCodec<T>, buf: FriendlyBuf, offset: number) -> T?,
    write: (self: OptionalBufferCodec<T>, buf: FriendlyBuf, value: T?) -> (),
    write_at_offset: (
        self: OptionalBufferCodec<T>,
        buf: FriendlyBuf,
        value: T?,
        offset: number
    ) -> (),
}

type OptionalBufferCodec<T> = setmetatable<{
    read reader: (buf: FriendlyBuf) -> T?,
    read writer: (buf: FriendlyBuf, value: T?) -> (),
}, OptionalBufferCodecProto<T>>

const buffer_codec = {} :: BufferCodecProto<unknown>
buffer_codec.__index = buffer_codec

const function new_buffer_codec<T>(
    reader: (buf: FriendlyBuf) -> T,
    writer: (buf: FriendlyBuf, value: T) -> ()
): BufferCodec<T>
    return setmetatable({
        reader = reader,
        writer = writer,
    }, buffer_codec)
end

function buffer_codec.read(self, buf)
    return self.reader(buf)
end

function buffer_codec.read_at_offset(self, buf, offset)
    const current_pos = buf.position

    buf.position = offset
    const value = self.reader(buf)
    buf.position = current_pos

    return value
end

function buffer_codec.write(self, buf, value)
    self.writer(buf, value)
end

function buffer_codec.write_at_offset(self, buf, value, offset)
    const current_pos = buf.position

    buf.position = offset
    self.writer(buf, value)
    buf.position = current_pos
end

function buffer_codec.as_optional(self)
    return new_buffer_codec(function(buf)
        const is_present = buf:get_u8()
        if is_present == 0 then
            return nil
        end

        return self:read(buf) :: any
    end, function(buf, value)
        if value == nil then
            buf:write_u8(0)
            return
        end

        buf:write_u8(1)
        self:write(buf, value)
    end) :: any
end

return table.freeze({
    new = new_buffer_codec,
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
