--!optimize 2
--!native

const friendly_buf = require("@moonstone/util/friendly_buf")

type FriendlyBuf = friendly_buf.FriendlyBuf

type FrameBufferProto = {
    __index: FrameBufferProto,
    append: (self: FrameBuffer, bytes: FriendlyBuf) -> (),
    read_frame_or_nil: (self: FrameBuffer) -> FriendlyBuf?,
    compact: (self: FrameBuffer) -> (),
    clear: (self: FrameBuffer) -> (),
}

export type FrameBuffer = setmetatable<{
    buf: FriendlyBuf,
    read_pos: number,
    write_pos: number,
}, FrameBufferProto>

const MAX_READABLE_LENGTH = 2 ^ 21

const frame_buffer = {} :: FrameBufferProto
frame_buffer.__index = frame_buffer

const function read_var_int_or_nil(fb: FrameBuffer): number?
    const start = fb.buf.position
    local result = 0
    local shift = 0

    for i = 1, 5 do
        if fb.buf.position >= fb.write_pos then
            fb.buf.position = start
            return nil
        end

        const byte = fb.buf:get_u8()
        const value = bit32.band(byte, 0x7F)

        result = bit32.bor(result, bit32.lshift(value, shift))
        if bit32.band(byte, 0x80) == 0 then
            break
        end

        shift += 7
        assert(shift <= 28, "VarInt is too big")
    end

    return result
end

export function new(size: number?): FrameBuffer
    const buf = friendly_buf.allocate(size or 1024)

    return setmetatable({
        buf = buf,
        read_pos = 0,
        write_pos = 0,
    }, frame_buffer)
end

function frame_buffer.append(self, chunk)
    self.buf.position = self.write_pos
    self.buf:extend(chunk)
    self.write_pos = self.buf.position
end

function frame_buffer.read_frame_or_nil(self)
    self.buf.position = self.read_pos

    const length = read_var_int_or_nil(self)
    if length == nil then
        return nil
    end

    assert(
        length <= MAX_READABLE_LENGTH,
        `packet length of '{length}' bytes is larger than maximum allowed size of '{MAX_READABLE_LENGTH}' bytes`
    )

    if self.write_pos - self.buf.position < length then
        self.buf.position = self.read_pos
        return nil
    end

    const body = self.buf:get_slice(length)
    self.read_pos = self.buf.position

    if self.read_pos > 4096 and self.read_pos > self.write_pos // 2 then
        self:compact()
    end

    return body
end

function frame_buffer.compact(self)
    if self.read_pos == 0 then
        return
    end

    self.buf.position = self.read_pos
    self.buf.limit = self.write_pos
    self.buf:compact()
    self.read_pos = 0
    self.write_pos = self.buf.position
end

function frame_buffer.clear(self)
    self.buf.position = self.buf.limit
    self.read_pos = 0
    self.write_pos = 0
    self.buf:compact()
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
