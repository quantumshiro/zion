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

    pub fn init(allocator: std.mem.Allocator) !this {
        return quaternion{
            .x = try bigInt.Managed.init(allocator),
            .i = try bigInt.Managed.init(allocator),
            .j = try bigInt.Managed.init(allocator),
            .k = try bigInt.Managed.init(allocator),
        };
    }

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

    pub fn conjugate(self: *this) *quaternion {
        self.i.negate();
        self.j.negate();
        self.k.negate();

        return self;
    }
};

test "quaternion init" {
    var q = try quaternion.init(std.testing.allocator);
    defer q.deinit();

    try q.x.set(1);
    try q.i.set(2);
    try q.j.set(3);
    try q.k.set(4);

    var x = try bigInt.Managed.initSet(std.testing.allocator, 1);
    var i = try bigInt.Managed.initSet(std.testing.allocator, 2);
    var j = try bigInt.Managed.initSet(std.testing.allocator, 3);
    var k = try bigInt.Managed.initSet(std.testing.allocator, 4);
    defer x.deinit();
    defer i.deinit();
    defer j.deinit();
    defer k.deinit();

    try testing.expect(bigInt.Managed.eql(q.x, x));
    try testing.expect(bigInt.Managed.eql(q.i, i));
    try testing.expect(bigInt.Managed.eql(q.j, j));
    try testing.expect(bigInt.Managed.eql(q.k, k));
}

test "quaternion uint" {
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

test "quaternion conjugate" {
    var q = try quaternion.init(std.testing.allocator);
    defer q.deinit();

    try q.x.set(1);
    try q.i.set(2);
    try q.j.set(3);
    try q.k.set(4);

    var expect = try quaternion.init(std.testing.allocator);
    defer expect.deinit();

    try expect.x.set(1);
    try expect.i.set(-2);
    try expect.j.set(-3);
    try expect.k.set(-4);

    const result = q.conjugate();

    try testing.expect(bigInt.Managed.eql(result.x, expect.x));
    try testing.expect(bigInt.Managed.eql(result.i, expect.i));
    try testing.expect(bigInt.Managed.eql(result.j, expect.j));
    try testing.expect(bigInt.Managed.eql(result.k, expect.k));
}
