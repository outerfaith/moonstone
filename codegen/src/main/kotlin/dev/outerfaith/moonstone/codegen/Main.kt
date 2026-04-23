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

package dev.outerfaith.moonstone.codegen

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import net.minecraft.SharedConstants
import net.minecraft.commands.Commands
import net.minecraft.core.RegistryAccess
import net.minecraft.resources.RegistryDataLoader
import net.minecraft.server.Bootstrap
import net.minecraft.server.MinecraftServer
import net.minecraft.server.RegistryLayer
import net.minecraft.server.ReloadableServerResources
import net.minecraft.server.packs.PackType
import net.minecraft.server.packs.repository.ServerPacksSource
import net.minecraft.server.packs.resources.MultiPackResourceManager
import net.minecraft.server.permissions.LevelBasedPermissionSet
import net.minecraft.tags.TagLoader
import net.minecraft.util.Util
import net.minecraft.world.flag.FeatureFlags
import net.minecraft.world.level.DataPackConfig
import net.minecraft.world.level.WorldDataConfiguration
import java.util.stream.Stream

private lateinit var registryAccess: RegistryAccess.Frozen

suspend fun bootstrap() = withContext(Dispatchers.Default) {
    SharedConstants.tryDetectVersion()
    Bootstrap.bootStrap()
    Bootstrap.validate()
    
    val repository = ServerPacksSource.createVanillaTrustedRepository()
    val flags = FeatureFlags.REGISTRY.allFlags()

    MinecraftServer.configurePackRepository(
        repository, 
        WorldDataConfiguration(
            DataPackConfig(FeatureFlags.REGISTRY.toNames(flags).map { it.path }.toList(), listOf()), 
            flags
        ), 
        true, 
        false
    )
    
    val resourceManager = MultiPackResourceManager(PackType.SERVER_DATA, repository.openAllSelected())
    var layers = RegistryLayer.createRegistryAccess()
    val pendingTags = TagLoader.loadTagsForExistingRegistries(resourceManager, layers.getLayer(RegistryLayer.STATIC))
    val worldGenLayer = TagLoader.buildUpdatedLookups(layers.getAccessForLoading(RegistryLayer.WORLDGEN), pendingTags)
    val frozen = RegistryDataLoader.load(resourceManager, worldGenLayer, RegistryDataLoader.WORLDGEN_REGISTRIES, Util.backgroundExecutor()).await()
    
    layers = layers.replaceFrom(RegistryLayer.WORLDGEN, frozen)
    
    val lookups = Stream.concat(worldGenLayer.stream(), frozen.listRegistries()).toList()
    val dimensions = RegistryDataLoader.load(resourceManager, lookups, RegistryDataLoader.DIMENSION_REGISTRIES, Util.backgroundExecutor()).await()
    
    layers = layers.replaceFrom(RegistryLayer.DIMENSIONS, dimensions)
    
    registryAccess = layers.compositeAccess().freeze()
    
    val resources = ReloadableServerResources.loadResources(
        resourceManager,
        layers,
        pendingTags,
        flags,
        Commands.CommandSelection.DEDICATED,
        LevelBasedPermissionSet.GAMEMASTER,
        Util.backgroundExecutor(),
        Runnable::run
    ).await()

    resources.updateComponentsAndStaticRegistryTags()
}

fun main() = runBlocking {
    bootstrap()
}
