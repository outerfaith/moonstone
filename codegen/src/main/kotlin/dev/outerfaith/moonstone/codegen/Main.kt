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

import com.google.gson.JsonObject
import com.mojang.logging.LogUtils
import dev.outerfaith.moonstone.codegen.generator.DataGeneratorInstance
import dev.outerfaith.moonstone.codegen.generator.DataSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import net.minecraft.SharedConstants
import net.minecraft.commands.Commands
import net.minecraft.core.RegistryAccess
import net.minecraft.core.registries.Registries
import net.minecraft.network.chat.ChatType
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
import net.minecraft.world.damagesource.DamageType
import net.minecraft.world.entity.animal.chicken.ChickenVariant
import net.minecraft.world.entity.animal.cow.CowVariant
import net.minecraft.world.entity.animal.feline.CatVariant
import net.minecraft.world.entity.animal.frog.FrogVariant
import net.minecraft.world.entity.animal.pig.PigVariant
import net.minecraft.world.entity.animal.wolf.WolfSoundVariant
import net.minecraft.world.entity.animal.wolf.WolfVariant
import net.minecraft.world.entity.decoration.painting.PaintingVariant
import net.minecraft.world.flag.FeatureFlags
import net.minecraft.world.item.equipment.trim.TrimMaterial
import net.minecraft.world.item.equipment.trim.TrimPattern
import net.minecraft.world.level.DataPackConfig
import net.minecraft.world.level.WorldDataConfiguration
import net.minecraft.world.level.biome.Biome
import net.minecraft.world.level.block.entity.BannerPattern
import net.minecraft.world.level.dimension.DimensionType
import java.nio.file.Path
import java.util.stream.Stream
import kotlin.io.path.createParentDirectories
import kotlin.io.path.writeText

private lateinit var registryAccess: RegistryAccess.Frozen
private val logger = LogUtils.getLogger()

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

fun generateNetworked(output: Path) {
    val generators = listOf(
        DataSource(registryAccess.lookupOrThrow(Registries.BIOME), Biome.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.CHAT_TYPE), ChatType.DIRECT_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.TRIM_PATTERN), TrimPattern.DIRECT_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.TRIM_MATERIAL), TrimMaterial.DIRECT_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.WOLF_VARIANT), WolfVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.WOLF_SOUND_VARIANT), WolfSoundVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.PIG_VARIANT), PigVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.FROG_VARIANT), FrogVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.CAT_VARIANT), CatVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.COW_VARIANT), CowVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.CHICKEN_VARIANT), ChickenVariant.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.PAINTING_VARIANT), PaintingVariant.DIRECT_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.DIMENSION_TYPE), DimensionType.NETWORK_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.DAMAGE_TYPE), DamageType.DIRECT_CODEC),
        DataSource(registryAccess.lookupOrThrow(Registries.BANNER_PATTERN), BannerPattern.DIRECT_CODEC)
    )

    val root = JsonObject()
    
    for (generator in generators) {
        val registryKey = generator.registry.key().identifier()
        val instance = DataGeneratorInstance(generator, registryAccess)
        
        logger.info("Generating data for '$registryKey'")

        val result = instance.generate().orThrow 
        
        root.add(registryKey.toString(), result)
    }
    
    output.writeText(root.toString())
}

fun main(args: Array<String>) = runBlocking {
    val output = Path.of(args.first())
    val networkOutput = output.resolve("networked_registries.json").createParentDirectories()
    
    bootstrap()
    
    generateNetworked(networkOutput)
}
