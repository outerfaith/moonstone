--!optimize 2
--!native

const test = require("@std/test")

const identifier = require("@moonstone/resources/identifier")

test.suite("Identifier", function(suite)
    suite:case("validates namespace and path characters", function(asserts)
        asserts.that(identifier.is_valid_namespace("minecraft"))
        asserts.that(identifier.is_valid_namespace("moonstone.extra-pack"))
        asserts.that(identifier.is_valid_path("block/oak_log"))
        asserts.that(identifier.is_valid_path("entity.zombie_villager"))

        asserts.never.that(identifier.is_valid_namespace("MineCraft"))
        asserts.never.that(identifier.is_valid_namespace("bad namespace"))
        asserts.never.that(identifier.is_valid_path("Block/OakLog"))
        asserts.never.that(identifier.is_valid_path("bad:path"))
    end)

    suite:case("constructs identifiers with explicit and helper namespaces", function(asserts)
        const explicit = identifier.new("custom", "widgets/cog")
        const default = identifier.with_default_namespace("systems/tick")
        const minecraft = identifier.with_minecraft_namespace("stone")

        asserts.eq("custom", explicit.namespace)
        asserts.eq("widgets/cog", explicit.path)
        asserts.eq("custom:widgets/cog", tostring(explicit))

        asserts.eq("moonstone", default.namespace)
        asserts.eq("systems/tick", default.path)
        asserts.eq("moonstone:systems/tick", tostring(default))

        asserts.eq("minecraft", minecraft.namespace)
        asserts.eq("stone", minecraft.path)
        asserts.eq("minecraft:stone", tostring(minecraft))
    end)

    suite:case("parses minecraft shorthand and namespaced strings", function(asserts)
        const shorthand = identifier.parse("dirt")
        const explicit = identifier.parse("moonstone:scheduler/pre")

        asserts.eq(identifier.with_minecraft_namespace("dirt"), shorthand)
        asserts.eq("minecraft", shorthand.namespace)
        asserts.eq("dirt", shorthand.path)

        asserts.eq(identifier.new("moonstone", "scheduler/pre"), explicit)
        asserts.eq("moonstone", explicit.namespace)
        asserts.eq("scheduler/pre", explicit.path)
    end)

    suite:case("derives identifiers without mutating the original", function(asserts)
        const base = identifier.new("moonstone", "tick")

        asserts.eq(identifier.new("moonstone", "post"), base:with_path("post"))
        asserts.eq(identifier.new("moonstone", "server/tick"), base:with_prefix("server/"))
        asserts.eq(identifier.new("moonstone", "tick/end"), base:with_suffix("/end"))
        asserts.eq("moonstone:tick", tostring(base))
    end)

    suite:case("formats language keys and short forms", function(asserts)
        const minecraft = identifier.with_minecraft_namespace("diamond_sword")
        const custom = identifier.with_default_namespace("scheduler/tick")

        asserts.eq("minecraft.diamond_sword", minecraft:to_language_key())
        asserts.eq("item.minecraft.diamond_sword", minecraft:to_prefixed_language_key("item"))
        asserts.eq(
            "block.minecraft.diamond_sword.desc",
            minecraft:to_prefixed_and_suffixed_language_key("block", "desc")
        )
        asserts.eq("diamond_sword", minecraft:to_short_language_key())
        asserts.eq("diamond_sword", minecraft:to_short_string())

        asserts.eq("moonstone.scheduler/tick", custom:to_language_key())
        asserts.eq("system.moonstone.scheduler/tick", custom:to_prefixed_language_key("system"))
        asserts.eq(
            "system.moonstone.scheduler/tick.name",
            custom:to_prefixed_and_suffixed_language_key("system", "name")
        )
        asserts.eq("moonstone.scheduler/tick", custom:to_short_language_key())
        asserts.eq("moonstone:scheduler/tick", custom:to_short_string())
    end)

    suite:case("compares by namespace and path only for identifiers", function(asserts)
        const first = identifier.new("moonstone", "tick")
        const second = identifier.new("moonstone", "tick")
        const different_namespace = identifier.new("minecraft", "tick")
        const different_path = identifier.new("moonstone", "post")

        asserts.eq(first, second)
        asserts.neq(first, different_namespace)
        asserts.neq(first, different_path)

        const plain_table = { namespace = "moonstone", path = "tick" }
        asserts.that(first ~= (plain_table :: any))
        asserts.that(first ~= ("moonstone:tick" :: any))
    end)

    suite:case("rejects invalid construction and derived values", function(asserts)
        asserts.throwsWith("namespace contains invalid characters", function()
            identifier.new("bad namespace", "stone")
        end)

        asserts.throwsWith("path contains invalid characters", function()
            identifier.new("minecraft", "BadPath")
        end)

        asserts.throwsWith("path contains invalid characters", function()
            identifier.with_default_namespace("valid"):with_suffix(":invalid")
        end)
    end)
end)
