const std = @import("std");
const builtin = @import("builtin");
const Pkg = std.build.Pkg;
const string = []const u8;

pub const cache = ".zigmod\\deps";

pub fn addAllTo(exe: *std.build.LibExeObjStep) void {
    @setEvalBranchQuota(1_000_000);
    for (packages) |pkg| {
        exe.addPackage(pkg.pkg.?);
    }
    var llc = false;
    var vcpkg = false;
    inline for (std.meta.declarations(package_data)) |decl| {
        const pkg = @as(Package, @field(package_data, decl.name));
        inline for (pkg.system_libs) |item| {
            exe.linkSystemLibrary(item);
            llc = true;
        }
        inline for (pkg.c_include_dirs) |item| {
            exe.addIncludeDir(@field(dirs, decl.name) ++ "/" ++ item);
            llc = true;
        }
        inline for (pkg.c_source_files) |item| {
            exe.addCSourceFile(@field(dirs, decl.name) ++ "/" ++ item, pkg.c_source_flags);
            llc = true;
        }
    }
    if (llc) exe.linkLibC();
    if (builtin.os.tag == .windows and vcpkg) exe.addVcpkgPaths(.static) catch |err| @panic(@errorName(err));
}

pub const Package = struct {
    directory: string,
    pkg: ?Pkg = null,
    c_include_dirs: []const string = &.{},
    c_source_files: []const string = &.{},
    c_source_flags: []const string = &.{},
    system_libs: []const string = &.{},
    vcpkg: bool = false,
};

const dirs = struct {
    pub const _root = "";
    pub const _muh5sqkmx04g = cache ++ "/../..";
    pub const _cyghmh8qzz6y = cache ++ "/git/github.com/ducdetronquito/zigmod_dep";
};

pub const package_data = struct {
    pub const _cyghmh8qzz6y = Package{
        .directory = dirs._cyghmh8qzz6y,
        .pkg = Pkg{ .name = "zigmod_dep", .path = .{ .path = dirs._cyghmh8qzz6y ++ "/src/main.zig" }, .dependencies = null },
    };
    pub const _muh5sqkmx04g = Package{
        .directory = dirs._muh5sqkmx04g,
        .pkg = Pkg{ .name = "zigmod_base", .path = .{ .path = dirs._muh5sqkmx04g ++ "/src/main.zig" }, .dependencies = &.{ _cyghmh8qzz6y.pkg.? } },
    };
    pub const _root = Package{
        .directory = dirs._root,
    };
};

pub const packages = &[_]Package{
    package_data._muh5sqkmx04g,
};

pub const pkgs = struct {
    pub const zigmod_base = package_data._muh5sqkmx04g;
};

pub const imports = struct {
};
