plugins {
    kotlin("jvm") version "2.3.20"
    id("org.spongepowered.gradle.vanilla") version "0.3.2"
}

kotlin {
    jvmToolchain(25)
}

repositories {
    mavenCentral()
}

minecraft {
    version("26.1.2")
    runs {
        server()
    }
    platform(org.spongepowered.gradle.vanilla.repository.MinecraftPlatform.SERVER)
}
