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

import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import net.minecraft.core.Registry

class TagGeneratorInstance<T : Any>(private val registry: Registry<T>) {
    
    fun generate(): JsonElement {
        val root = JsonObject()
        
        registry.listTagIds().forEach { tagKey ->
            val tag = JsonArray()
            
            registry.getTagOrEmpty(tagKey).forEach { holder ->
                val key = holder.unwrapKey().orElseThrow()
                
                tag.add(key.identifier().toShortString())
            }
            
            root.add(tagKey.location.toString(), tag)
        }
        
        return root
    }
    
}
