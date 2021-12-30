const std = @import("std");
const testing = std.testing;
const zigmod_dep = @import("zigmod_dep");

export fn multiply_by_two(a: i32) i32 {
    return zigmod_dep.add(a, a);
}

test "multiply by two" {
    try testing.expect(multiply_by_two(3) == 6);
}
