--!optimize 2
--!strict

local tags = require("./tags")
local byteBuf = require("../util/byteBuf")
local supplier = require("../util/supplier")

type TagHeader = {
    id: number,
    name: string?,
}

local TAG_OPS_TABLE: { [number]: supplier.Supplier<tags.TagOps<any>> } = table.freeze({
    --- Lazy require path is always relative to supplier module location
    --- There is probably a much better way to handle this that doesn't involve
    --- invoking the supplier every time a tag needs to be read or written.
    [tags.END] = supplier.lazyRequire("../nbt/endTag") :: any,
    [tags.BYTE] = supplier.lazyRequire("../nbt/byteTag") :: any,
    [tags.SHORT] = supplier.lazyRequire("../nbt/shortTag") :: any,
    [tags.INT] = supplier.lazyRequire("../nbt/intTag") :: any,
    [tags.LONG] = supplier.lazyRequire("../nbt/longTag") :: any,
    [tags.FLOAT] = supplier.lazyRequire("../nbt/floatTag") :: any,
    [tags.DOUBLE] = supplier.lazyRequire("../nbt/doubleTag") :: any,
    [tags.BYTE_ARRAY] = supplier.lazyRequire("../nbt/byteArrayTag") :: any,
    [tags.STRING] = supplier.lazyRequire("../nbt/stringTag") :: any,
    --- ListTag and CompoundTag are the only tag types that need
    --- to write with another TagOps<?>
    [tags.LIST] = supplier.lazyRequire("../nbt/listTag") :: any,
    [tags.COMPOUND] = supplier.lazyRequire("../nbt/compoundTag") :: any,
    [tags.INT_ARRAY] = supplier.lazyRequire("../nbt/intArrayTag") :: any,
    [tags.LONG_ARRAY] = supplier.lazyRequire("../nbt/longArrayTag") :: any,
})

local function read(buf: byteBuf.ByteBuf, named: boolean?): tags.Tag<any>
    local id = buf:readByte()
    local opsSupplier = TAG_OPS_TABLE[id]
    assert(opsSupplier ~= nil, `no TagOps has been registered for id {id}`)

    local ops = opsSupplier()

    return named and ops.readNamed(buf) or ops.read(buf)
end

local function write(buf: byteBuf.ByteBuf, tag: tags.Tag<any>, named: boolean?)
    local id = tag.id
    local opsSupplier = TAG_OPS_TABLE[id]
    assert(opsSupplier ~= nil, `no TagOps has been registered for id {id}`)

    buf:putByte(id)

    local ops = opsSupplier()

    if not named then
        ops.write(buf, tag)
    else
        ops.writeNamed(buf, tag :: tags.NamedTag<any>)
    end
end

return table.freeze({
    TAG_OPS_TABLE = TAG_OPS_TABLE,
    read = read,
    write = write,
})

--[[
   Copyright 2025 Outerfaith
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
