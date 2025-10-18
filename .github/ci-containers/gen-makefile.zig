// zig-0.15 run gen-makefile.zig
const Libc = enum {
    glibc,
    musl,

    const all: []const Libc = all_tags(Libc);

    fn container(libc: Libc) []const u8 {
        return switch (libc) {
            .glibc => "manylinux",
            .musl => "musllinux",
        };
    }
    fn version(libc: Libc) []const u8 {
        return switch (libc) {
            .glibc => "2_28",
            .musl => "1_2",
        };
    }
};

const Arch = enum {
    aarch64,
    x86_64,

    const all: []const Arch = all_tags(Arch);
};

fn all_tags(comptime T: type) []const T {
    var result: []const T = &.{};
    for (@typeInfo(T).@"enum".fields) |field| {
        result = result ++ @as([]const T, &.{@field(T, field.name)});
    }
    return result;
}

pub fn main() !void {
    const file = try std.fs.cwd().createFile("Makefile", .{ .truncate = true });

    var write_buffer: [4096]u8 = undefined;
    var file_writer = file.writer(&write_buffer);
    const writer: *std.Io.Writer = &file_writer.interface;
    defer writer.flush() catch @panic("write flush failed");

    try writer.writeAll(
        \\DOCKER_REGISTRY := ghcr.io
        \\DOCKER_PROJECT := torque/deqr
        \\REGISTRY_PREFIX := $(DOCKER_REGISTRY)/$(DOCKER_PROJECT)
        \\IMAGE_BASENAME := $(REGISTRY_PREFIX)/linux-build
        \\
        \\
    );

    try writer.print(
        \\.PHONY: all
        \\all:
        \\{[t]s}@echo Build and push images containing multi-python linux build environments.
        \\{[t]s}@echo
        \\{[t]s}@echo Usage:
        \\{[t]s}@echo "    make <libc>@<arch> "#" build an individual image e.g. for local testing"
        \\{[t]s}@echo "    make push-<libc>@<arch> "#" build and push an individual image"
        \\{[t]s}@echo "    make push "#" build all images"
        \\{[t]s}@echo "    make push "#" build and push all images"
        \\{[t]s}@echo
        \\{[t]s}@echo Available libc:
        \\{[t]s}@echo "    - glibc"
        \\{[t]s}@echo "    - musl"
        \\{[t]s}@echo
        \\{[t]s}@echo Available arch:
        \\{[t]s}@echo "    - aarch64"
        \\{[t]s}@echo "    - x86_64"
        \\
        \\
    ,
        .{ .t = "\t" },
    );

    for (Libc.all) |libc|
        for (Arch.all) |arch|
            try writeLibcArch(writer, libc, arch);

    try writer.writeAll(".PHONY: build\nbuild:");
    for (Libc.all) |libc|
        for (Arch.all) |arch|
            try writer.print(
                " {[libc]s}@{[arch]s}",
                .{ .libc = @tagName(libc), .arch = @tagName(arch) },
            );
    try writer.writeByte('\n');

    try writer.writeAll(".PHONY: push\npush:");
    for (Libc.all) |libc|
        for (Arch.all) |arch|
            try writer.print(
                " push-{[libc]s}@{[arch]s}",
                .{ .libc = @tagName(libc), .arch = @tagName(arch) },
            );
    try writer.writeByte('\n');
}

pub fn writeLibcArch(writer: *std.Io.Writer, libc: Libc, arch: Arch) !void {
    try writer.print(
        \\.PHONY: {[libc]s}@{[arch]s}
        \\{[libc]s}@{[arch]s}:
        \\{[t]s}@echo ">> Pulling base image for $@"
        \\{[t]s}@docker pull quay.io/pypa/{[container]s}_{[version]s}_{[arch]s}:latest
        \\{[t]s}@echo ">> Building build image for $@"
        \\{[t]s}@docker build \
        \\{[t]s}{[t]s}--progress=plain \
        \\{[t]s}{[t]s}-f "{[container]s}.Dockerfile" \
        \\{[t]s}{[t]s}--build-arg "ARCHITECTURE={[version]s}_{[arch]s}" \
        \\{[t]s}{[t]s}-t "$(IMAGE_BASENAME):{[container]s}_{[version]s}_{[arch]s}" ../..
        \\{[t]s}@echo ">> Tagged $(IMAGE_BASENAME):{[container]s}_{[version]s}_{[arch]s}"
        \\
        \\.PHONY: push-{[libc]s}@{[arch]s}
        \\push-{[libc]s}@{[arch]s}: {[libc]s}@{[arch]s}
        \\{[t]s}@echo ">> Pushing $(IMAGE_BASENAME):{[container]s}_{[version]s}_{[arch]s}"
        \\{[t]s}@docker push $(IMAGE_BASENAME):{[container]s}_{[version]s}_{[arch]s}
        \\{[t]s}@echo ">> Pushed $(IMAGE_BASENAME):{[container]s}_{[version]s}_{[arch]s}"
        \\
        \\
    ,
        .{
            .libc = @tagName(libc),
            .arch = @tagName(arch),
            .container = libc.container(),
            .version = libc.version(),
            .t = "\t",
        },
    );
}

const std = @import("std");
