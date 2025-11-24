--!optimize 2
--!strict

local byteBuf = require("../util/byteBuf")

export type Tag<T> = {
    read value: T,
    read id: number,
}

export type NamedTag<T> = Tag<T> & {
    read name: string,
}

export type TagOps<T> = {
    __index: TagOps<T>,
    create: (value: T) -> Tag<T>,
    createNamed: (value: T, name: string) -> NamedTag<T>,
    read: (buf: byteBuf.ByteBuf) -> Tag<T>,
    write: (buf: byteBuf.ByteBuf, instance: Tag<T>) -> (),
    readNamed: (buf: byteBuf.ByteBuf) -> NamedTag<T>,
    writeNamed: (buf: byteBuf.ByteBuf, instance: NamedTag<T>) -> (),
}

export type CollectionTagOps<T> = TagOps<T> & {
    clear: (self: Tag<T>) -> (),
}

export type ArrayTagOps<T> = CollectionTagOps<{ T }> & {
    set: (self: Tag<{ T }>, index: number, value: T) -> (),
    add: (self: Tag<{ T }>, value: T) -> (),
    remove: (self: Tag<{ T }>, index: number) -> T?,
}

export type MapTagOps = CollectionTagOps<{ [string]: Tag<any> }> & {
    contains: (self: Tag<{ [string]: Tag<any> }>, key: string) -> boolean,
    copy: (self: Tag<{ [string]: Tag<any> }>) -> Tag<{ [string]: Tag<any> }>,
    put: (self: Tag<{ [string]: Tag<any> }>, key: string, value: Tag<any>) -> (),
    putByte: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putShort: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putInt: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putLong: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putFloat: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putDouble: (self: Tag<{ [string]: Tag<any> }>, key: string, value: number) -> (),
    putString: (self: Tag<{ [string]: Tag<any> }>, key: string, value: string) -> (),
    putByteArray: (self: Tag<{ [string]: Tag<any> }>, key: string, value: { number }) -> (),
    putIntArray: (self: Tag<{ [string]: Tag<any> }>, key: string, value: { number }) -> (),
    putLongArray: (self: Tag<{ [string]: Tag<any> }>, key: string, value: { number }) -> (),
    putBoolean: (self: Tag<{ [string]: Tag<any> }>, key: string, value: boolean) -> (),
    get: (self: Tag<{ [string]: Tag<any> }>, key: string) -> Tag<any>?,
    getByte: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getShort: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getInt: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getLong: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getFloat: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getDouble: (self: Tag<{ [string]: Tag<any> }>, key: string) -> number?,
    getString: (self: Tag<{ [string]: Tag<any> }>, key: string) -> string?,
    getByteArray: (self: Tag<{ [string]: Tag<any> }>, key: string) -> { number }?,
    getIntArray: (self: Tag<{ [string]: Tag<any> }>, key: string) -> { number }?,
    getLongArray: (self: Tag<{ [string]: Tag<any> }>, key: string) -> { number }?,
    getBoolean: (self: Tag<{ [string]: Tag<any> }>, key: string) -> boolean?,
}

return table.freeze({
    END = 0x00,
    BYTE = 0x01,
    SHORT = 0x02,
    INT = 0x03,
    LONG = 0x04,
    FLOAT = 0x05,
    DOUBLE = 0x06,
    BYTE_ARRAY = 0x07,
    STRING = 0x08,
    LIST = 0x09,
    COMPOUND = 0x0A,
    INT_ARRAY = 0x0B,
    LONG_ARRAY = 0x0C,
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
