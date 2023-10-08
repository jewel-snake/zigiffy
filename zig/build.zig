const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{ .name = "zig", .root_source_file = .{ .path = "src/zig.zig" }, .optimize = mode, .target = target });

    // Need these flags in order to compile
    lib.bundle_compiler_rt = true;
    lib.force_pic = true;
    lib.single_threaded = true;
    lib.strip = true;

    //lib.setBuildMode(mode);
    //lib.install();
    b.installArtifact(lib);
    var main_tests = b.addTest(.{ .root_source_file = .{ .path = "src/zig.zig" } });
    //main_tests.setBuildMode(mode);
    main_tests.optimize = mode;
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
