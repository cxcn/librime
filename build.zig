const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    // yaml-cpp
    // const yamlcpp = b.addSharedLibrary(.{
    const yamlcpp = b.addStaticLibrary(.{
        .name = "yaml-cpp",
        .target = target,
        .optimize = optimize,
    });
    yamlcpp.linkLibCpp();
    yamlcpp.addIncludePath("deps/yaml-cpp/include");
    yamlcpp.addIncludePath("deps/yaml-cpp/src");
    yamlcpp.addIncludePath("deps/yaml-cpp/src/contrib");
    yamlcpp.addCSourceFiles(&.{
        "deps/yaml-cpp/src/contrib/graphbuilder.cpp",
        "deps/yaml-cpp/src/contrib/graphbuilderadapter.cpp",
        "deps/yaml-cpp/src/binary.cpp",
        "deps/yaml-cpp/src/convert.cpp",
        "deps/yaml-cpp/src/depthguard.cpp",
        "deps/yaml-cpp/src/directives.cpp",
        "deps/yaml-cpp/src/emit.cpp",
        "deps/yaml-cpp/src/emitfromevents.cpp",
        "deps/yaml-cpp/src/emitter.cpp",
        "deps/yaml-cpp/src/emitterstate.cpp",
        "deps/yaml-cpp/src/emitterutils.cpp",
        "deps/yaml-cpp/src/exceptions.cpp",
        "deps/yaml-cpp/src/exp.cpp",
        "deps/yaml-cpp/src/memory.cpp",
        "deps/yaml-cpp/src/node_data.cpp",
        "deps/yaml-cpp/src/node.cpp",
        "deps/yaml-cpp/src/nodebuilder.cpp",
        "deps/yaml-cpp/src/nodeevents.cpp",
        "deps/yaml-cpp/src/null.cpp",
        "deps/yaml-cpp/src/ostream_wrapper.cpp",
        "deps/yaml-cpp/src/parse.cpp",
        "deps/yaml-cpp/src/parser.cpp",
        "deps/yaml-cpp/src/regex_yaml.cpp",
        "deps/yaml-cpp/src/scanner.cpp",
        "deps/yaml-cpp/src/scanscalar.cpp",
        "deps/yaml-cpp/src/scantag.cpp",
        "deps/yaml-cpp/src/scantoken.cpp",
        "deps/yaml-cpp/src/simplekey.cpp",
        "deps/yaml-cpp/src/singledocparser.cpp",
        "deps/yaml-cpp/src/stream.cpp",
        "deps/yaml-cpp/src/tag.cpp",
    }, &.{
        "-std=c++11",
        "-Wall ",
        "-Wextra ",
        "-Wshadow",
        "-Weffc++ ",
        "-Wno-long-long",
        "-pedantic",
        "-pedantic-errors",
    });
    yamlcpp.installHeadersDirectory("deps/yaml-cpp/include", "");

    // marisa-trie
    // const marisa = b.addSharedLibrary(.{
    const marisa = b.addStaticLibrary(.{
        .name = "marisa",
        .target = target,
        .optimize = optimize,
    });
    marisa.linkLibCpp();
    marisa.addIncludePath("deps/marisa-trie/include");
    marisa.addIncludePath("deps/marisa-trie/lib");
    marisa.addCSourceFiles(&.{
        "deps/marisa-trie/lib/marisa/grimoire/io/mapper.cc",
        "deps/marisa-trie/lib/marisa/grimoire/io/reader.cc",
        "deps/marisa-trie/lib/marisa/grimoire/io/writer.cc",
        "deps/marisa-trie/lib/marisa/grimoire/trie/louds-trie.cc",
        "deps/marisa-trie/lib/marisa/grimoire/trie/tail.cc",
        "deps/marisa-trie/lib/marisa/grimoire/vector/bit-vector.cc",
        "deps/marisa-trie/lib/marisa/agent.cc",
        "deps/marisa-trie/lib/marisa/keyset.cc",
        "deps/marisa-trie/lib/marisa/trie.cc",
    }, &.{
        "-std=c++17",
        "-Wall",
        "-Weffc++",
        "-Wextra",
        "-Wconversion",
    });
    marisa.installHeadersDirectory("deps/marisa-trie/include", "");

    // opencc
    // const opencc = b.addSharedLibrary(.{
    const opencc = b.addStaticLibrary(.{
        .name = "opencc",
        .target = target,
        .optimize = optimize,
    });
    opencc.linkLibCpp();
    opencc.linkLibrary(marisa);
    // opencc_config
    const OPENCC_ENABLE_DARTS = 1;
    const opencc_config = b.addConfigHeader(.{
        .style = .{ .cmake = .{ .path = "deps/opencc/src/opencc_config.h.in" } },
        .include_path = "deps/opencc/src/opencc_config.h",
    }, .{
        .OPENCC_ENABLE_DARTS = OPENCC_ENABLE_DARTS,
    });
    opencc.addConfigHeader(opencc_config);
    // OPENCC_ENABLE_DARTS
    if (OPENCC_ENABLE_DARTS == 1) {
        opencc.addIncludePath("deps/opencc/deps/darts-clone");
        opencc.addCSourceFiles(&.{
            "deps/opencc/src/BinaryDict.cpp",
            "deps/opencc/src/DartsDict.cpp",
        }, &.{
            "-std=c++14",
            "-Wall",
        });
    }
    opencc.addIncludePath("deps/opencc/deps/rapidjson-1.1.0");
    opencc.addIncludePath("deps/opencc/deps/tclap-1.2.2");
    opencc.addIncludePath("deps/marisa-trie/include");
    opencc.addCSourceFiles(&.{
        "deps/opencc/src/Config.cpp",
        "deps/opencc/src/Conversion.cpp",
        "deps/opencc/src/ConversionChain.cpp",
        "deps/opencc/src/Converter.cpp",
        "deps/opencc/src/Dict.cpp",
        "deps/opencc/src/DictConverter.cpp",
        "deps/opencc/src/DictEntry.cpp",
        "deps/opencc/src/DictGroup.cpp",
        "deps/opencc/src/Lexicon.cpp",
        "deps/opencc/src/MarisaDict.cpp",
        "deps/opencc/src/MaxMatchSegmentation.cpp",
        "deps/opencc/src/PhraseExtract.cpp",
        "deps/opencc/src/SerializedValues.cpp",
        "deps/opencc/src/SimpleConverter.cpp",
        "deps/opencc/src/Segmentation.cpp",
        "deps/opencc/src/TextDict.cpp",
        "deps/opencc/src/UTF8StringSlice.cpp",
        "deps/opencc/src/UTF8Util.cpp",
    }, &.{
        "-std=c++14",
        "-Wall",
    });
    // opencc install header
    opencc.installConfigHeader(opencc_config, .{
        .dest_rel_path = "../../deps/opencc/src/opencc_config.h",
    });
    opencc.installHeadersDirectoryOptions(.{
        .source_dir = "deps/opencc/src",
        .install_dir = .header,
        .install_subdir = "opencc",
        .exclude_extensions = &.{ "cpp", "txt", "md" },
    });

    // leveldb
    // const leveldb = b.addSharedLibrary(.{
    const leveldb = b.addStaticLibrary(.{
        .name = "leveldb",
        .target = target,
        .optimize = optimize,
    });
    leveldb.linkLibC();
    leveldb.linkLibCpp();
    // TODO leveldb port_config
    const port_config = b.addConfigHeader(.{
        // .style = .{ .cmake = .{ .path = "deps/leveldb/port/port_config.h.in" } },
        .style = .blank,
        .include_path = "deps/leveldb/port/port_config.h",
    }, .{
        .HAVE_FDATASYNC = 0,
        .HAVE_FULLFSYNC = 0,
        .HAVE_O_CLOEXEC = 0,
        .HAVE_CRC32C = 0,
        .HAVE_SNAPPY = 0,
    });
    leveldb.addConfigHeader(port_config);
    leveldb.addIncludePath("deps/leveldb/include");
    leveldb.addIncludePath("deps/leveldb");

    const leveldb_files = [_][]const u8{
        "deps/leveldb/db/builder.cc",
        "deps/leveldb/db/c.cc",
        "deps/leveldb/db/db_impl.cc",
        "deps/leveldb/db/db_iter.cc",
        "deps/leveldb/db/dbformat.cc",
        "deps/leveldb/db/dumpfile.cc",
        "deps/leveldb/db/filename.cc",
        "deps/leveldb/db/log_reader.cc",
        "deps/leveldb/db/log_writer.cc",
        "deps/leveldb/db/memtable.cc",
        "deps/leveldb/db/repair.cc",
        "deps/leveldb/db/table_cache.cc",
        "deps/leveldb/db/version_edit.cc",
        "deps/leveldb/db/version_set.cc",
        "deps/leveldb/db/write_batch.cc",
        "deps/leveldb/table/block_builder.cc",
        "deps/leveldb/table/block.cc",
        "deps/leveldb/table/filter_block.cc",
        "deps/leveldb/table/format.cc",
        "deps/leveldb/table/iterator.cc",
        "deps/leveldb/table/merger.cc",
        "deps/leveldb/table/table_builder.cc",
        "deps/leveldb/table/table.cc",
        "deps/leveldb/table/two_level_iterator.cc",
        "deps/leveldb/util/arena.cc",
        "deps/leveldb/util/bloom.cc",
        "deps/leveldb/util/cache.cc",
        "deps/leveldb/util/coding.cc",
        "deps/leveldb/util/comparator.cc",
        "deps/leveldb/util/crc32c.cc",
        "deps/leveldb/util/env.cc",
        "deps/leveldb/util/filter_policy.cc",
        "deps/leveldb/util/hash.cc",
        "deps/leveldb/util/logging.cc",
        "deps/leveldb/util/options.cc",
        "deps/leveldb/util/status.cc",

        "deps/leveldb/helpers/memenv/memenv.cc",
    };
    const leveldb_flags = [_][]const u8{
        "-std=c++11",
    };
    switch (leveldb.target_info.target.os.tag) {
        .windows => {
            const files = leveldb_files ++ [_][]const u8{"deps/leveldb/util/env_windows.cc"};
            const flags = leveldb_flags ++ [_][]const u8{"-DUNICODE"};
            leveldb.addCSourceFiles(&files, &flags);
            leveldb.defineCMacro("LEVELDB_PLATFORM_WINDOWS", "1");
        },
        else => {
            const files = leveldb_files ++ [_][]const u8{"deps/leveldb/util/env_posix.cc"};
            const flags = leveldb_flags;
            leveldb.addCSourceFiles(&files, &flags);
            leveldb.defineCMacro("LEVELDB_PLATFORM_POSIX", "1");
        },
    }
    leveldb.installConfigHeader(port_config, .{
        // .{ .dest_rel_path = "../../deps/leveldb/port/port_config.h" },
        .dest_rel_path = "../../deps/leveldb/port/port_config.h",
    });
    leveldb.installHeadersDirectory("deps/leveldb/include", "");

    const rime_api_src = [_][]const u8{"src/rime_api.cc"};
    const rime_base_src = [_][]const u8{
        "src/rime/candidate.cc",
        "src/rime/commit_history.cc",
        "src/rime/composition.cc",
        "src/rime/context.cc",
        "src/rime/core_module.cc",
        "src/rime/deployer.cc",
        "src/rime/engine.cc",
        "src/rime/key_event.cc",
        "src/rime/key_table.cc",
        "src/rime/language.cc",
        "src/rime/menu.cc",
        "src/rime/module.cc",
        "src/rime/registry.cc",
        "src/rime/resource.cc",
        "src/rime/schema.cc",
        "src/rime/segmentation.cc",
        "src/rime/service.cc",
        "src/rime/setup.cc",
        "src/rime/signature.cc",
        "src/rime/switcher.cc",
        "src/rime/switches.cc",
        "src/rime/ticket.cc",
        "src/rime/translation.cc",
    };
    const rime_algo_src = [_][]const u8{
        "src/rime/algo/algebra.cc",
        "src/rime/algo/calculus.cc",
        "src/rime/algo/encoder.cc",
        "src/rime/algo/syllabifier.cc",
        "src/rime/algo/utilities.cc",
    };
    const rime_config_src = [_][]const u8{
        "src/rime/config/auto_patch_config_plugin.cc",
        "src/rime/config/build_info_plugin.cc",
        "src/rime/config/config_compiler.cc",
        "src/rime/config/config_component.cc",
        "src/rime/config/config_data.cc",
        "src/rime/config/config_types.cc",
        "src/rime/config/default_config_plugin.cc",
        "src/rime/config/legacy_dictionary_config_plugin.cc",
        "src/rime/config/legacy_preset_config_plugin.cc",
        "src/rime/config/save_output_plugin.cc",
    };

    const rime_dict_src = [_][]const u8{
        "src/rime/dict/corrector.cc",
        "src/rime/dict/db_utils.cc",
        "src/rime/dict/db.cc",
        "src/rime/dict/dict_compiler.cc",
        "src/rime/dict/dict_module.cc",
        "src/rime/dict/dict_settings.cc",
        "src/rime/dict/dictionary.cc",
        "src/rime/dict/entry_collector.cc",
        "src/rime/dict/level_db.cc",
        "src/rime/dict/mapped_file.cc",
        "src/rime/dict/preset_vocabulary.cc",
        "src/rime/dict/prism.cc",
        "src/rime/dict/reverse_lookup_dictionary.cc",
        "src/rime/dict/string_table.cc",
        "src/rime/dict/table_db.cc",
        "src/rime/dict/table.cc",
        "src/rime/dict/text_db.cc",
        "src/rime/dict/tsv.cc",
        "src/rime/dict/user_db_recovery_task.cc",
        "src/rime/dict/user_db.cc",
        "src/rime/dict/user_dictionary.cc",
        "src/rime/dict/vocabulary.cc",
    };
    const rime_gears_src = [_][]const u8{
        "src/rime/gear/abc_segmentor.cc",
        "src/rime/gear/affix_segmentor.cc",
        "src/rime/gear/ascii_composer.cc",
        "src/rime/gear/ascii_segmentor.cc",
        "src/rime/gear/charset_filter.cc",
        "src/rime/gear/chord_composer.cc",
        "src/rime/gear/contextual_translation.cc",
        "src/rime/gear/echo_translator.cc",
        "src/rime/gear/editor.cc",
        "src/rime/gear/fallback_segmentor.cc",
        "src/rime/gear/filter_commons.cc",
        "src/rime/gear/gears_module.cc",
        "src/rime/gear/history_translator.cc",
        "src/rime/gear/key_binder.cc",
        "src/rime/gear/matcher.cc",
        "src/rime/gear/memory.cc",
        "src/rime/gear/navigator.cc",
        "src/rime/gear/poet.cc",
        "src/rime/gear/punctuator.cc",
        "src/rime/gear/recognizer.cc",
        "src/rime/gear/reverse_lookup_filter.cc",
        "src/rime/gear/reverse_lookup_translator.cc",
        "src/rime/gear/schema_list_translator.cc",
        "src/rime/gear/script_translator.cc",
        "src/rime/gear/selector.cc",
        "src/rime/gear/shape.cc",
        "src/rime/gear/simplifier.cc",
        "src/rime/gear/single_char_filter.cc",
        "src/rime/gear/speller.cc",
        "src/rime/gear/switch_translator.cc",
        "src/rime/gear/table_translator.cc",
        "src/rime/gear/translator_commons.cc",
        "src/rime/gear/uniquifier.cc",
        "src/rime/gear/unity_table_encoder.cc",
    };

    const rime_levers_src = [_][]const u8{
        "src/rime/lever/custom_settings.cc",
        "src/rime/lever/customizer.cc",
        "src/rime/lever/deployment_tasks.cc",
        "src/rime/lever/levers_module.cc",
        "src/rime/lever/switcher_settings.cc",
        "src/rime/lever/user_dict_manager.cc",
    };

    const rime_core_module_src = rime_api_src ++ rime_base_src ++ rime_config_src;
    const rime_dict_module_src = rime_algo_src ++ rime_dict_src;
    const rime_src = rime_core_module_src ++ rime_dict_module_src ++ rime_gears_src ++ rime_levers_src;

    // rime
    // const lib = b.addSharedLibrary(.{
    const lib = b.addStaticLibrary(.{
        .name = "rime",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        // .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    lib.linkLibrary(yamlcpp);
    lib.linkLibrary(marisa);
    lib.linkLibrary(opencc);
    lib.linkLibrary(leveldb);
    // lib.linkSystemLibrary("");
    // lib.addIncludePath("deps/yaml-cpp/include");
    // lib.addIncludePath("deps/marisa-trie/include");
    // lib.addIncludePath("deps/opencc/src");
    // lib.addIncludePath("deps/leveldb/include");
    lib.addIncludePath("include");
    lib.addIncludePath("zig-out/include/opencc");
    lib.addIncludePath("src");
    // lib.defineCMacro("RIME_VERSION", "18");
    lib.addCSourceFiles(&rime_src, &.{
        "-std=c++14",
        "-DRIME_VERSION=\"1.8.6\"",
    });
    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    // b.installArtifact(yamlcpp);
    // b.installArtifact(marisa);
    // b.installArtifact(opencc);
    // b.installArtifact(leveldb);
    lib.installHeader("src/rime_api.h", "rime_api.h");
    lib.installHeader("src/rime_levers_api.h", "rime_levers_api.h");
    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    // const main_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_main_tests = b.addRunArtifact(main_tests);

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build test`
    // This will evaluate the `test` step rather than the default, which is "install".
    // const test_step = b.step("test", "Run library tests");
    // test_step.dependOn(&run_main_tests.step);
}
