--!optimize 2

const result = require("@pkg/result")

const friendly_buf = require("@moonstone/util/friendly_buf")

type Result<R, E> = result.Result<R, E>
type FriendlyBuf = friendly_buf.FriendlyBuf

export type Tag<T> = {
    read value: T,
    read id: number,
}

export type ListTag<T> = Tag<T> & {
    read element_id: number?,
}

export type NamedTag<T> = {
    read name: string,
    read tag: ListTag<T> | Tag<T>,
}

export type TagOps<T> = {
    read write: (tag: Tag<T>, buf: FriendlyBuf) -> (),
    read read: (buf: FriendlyBuf) -> Result<Tag<T>, string>,
}

return nil

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
