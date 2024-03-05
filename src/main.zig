const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const bigInt = std.math.big.int;

pub const quaternion = struct {
    x: bigInt.Managed,
    i: bigInt.Managed,
    j: bigInt.Managed,
    k: bigInt.Managed,

    const this = @This();

    pub fn deinit(self: *this) void {
        self.x.deinit();
        self.i.deinit();
        self.j.deinit();
        self.k.deinit();
    }

    pub fn uint(allocator: std.mem.Allocator) !this {
        return quaternion{
            .x = try bigInt.Managed.initSet(allocator, 1),
            .i = try bigInt.Managed.initSet(allocator, 0),
            .j = try bigInt.Managed.initSet(allocator, 0),
            .k = try bigInt.Managed.initSet(allocator, 0),
        };
    }
};

test "multi length quaternion" {
    var q = try quaternion.uint(std.testing.allocator);
    defer q.deinit();

    var expect_one = try bigInt.Managed.initSet(std.testing.allocator, 1);
    var expect_zero = try bigInt.Managed.initSet(std.testing.allocator, 0);
    defer expect_one.deinit();
    defer expect_zero.deinit();

    try testing.expect(bigInt.Managed.eql(q.x, expect_one));
    try testing.expect(bigInt.Managed.eql(q.i, expect_zero));
    try testing.expect(bigInt.Managed.eql(q.j, expect_zero));
    try testing.expect(bigInt.Managed.eql(q.k, expect_zero));
}
