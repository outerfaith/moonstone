/*
 *    Copyright 2025-2026 outerfaith
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package dev.outerfaith.moonstone.codegen.generator

import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.mojang.serialization.DataResult
import com.mojang.serialization.JsonOps
import net.minecraft.core.RegistryAccess
import net.minecraft.resources.RegistryOps

class DataGeneratorInstance<T : Any>(private val source: DataSource<T>, private val registryAccess: RegistryAccess) {
    
    fun generate(): DataResult<JsonElement> {
        val ops = RegistryOps.create(JsonOps.INSTANCE, registryAccess)
        
        val mapped = source.registry.entrySet().map { entry ->
            val entryKey = entry.key
            val value = entry.value
            
            val key = entryKey.identifier()
            val serial = source.codec.encodeStart(ops, value)
            
            if (serial.isError) return serial.mapError { "Cannot encode $key into JSON: $it" }

            Pair(key.toShortString(), serial.orThrow)
        }
        
        val root = JsonObject()
        
        for ((key, value) in mapped) {
            root.add(key, value)
        }
        
        return DataResult.success(root)
    }
    
}
