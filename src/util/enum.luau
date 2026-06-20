--!optimize 2

export const CONNECTION_INTENT = {
    HANDSHAKE = 0x00,
    STATUS = 0x01,
    LOGIN = 0x02,
    CONFIGURATION = 0x03,
    PLAY = 0x04,
}

export const PACKET_FLOW = {
    CLIENTBOUND = 0x00,
    SERVERBOUND = 0x01,
}

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
