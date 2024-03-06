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

    pub fn mul(lhs: *this, rhs: this, allocator: std.mem.Allocator) !this {
        var x = try bigInt.Managed.initSet(allocator, 0);
        var i = try bigInt.Managed.initSet(allocator, 0);
        var j = try bigInt.Managed.initSet(allocator, 0);
        var k = try bigInt.Managed.initSet(allocator, 0);
        defer x.deinit();
        defer i.deinit();
        defer j.deinit();
        defer k.deinit();

        var zero = try bigInt.Managed.initSet(allocator, 0);
        defer zero.deinit();

        // lhs.x * rhs.x - lhs.i * rhs.i - lhs.j * rhs.j - lhs.k * rhs.k
        var tmp = try bigInt.Managed.initSet(allocator, 0);
        defer tmp.deinit();
        try tmp.mul(&lhs.x, &rhs.x);

        var tmp2 = try bigInt.Managed.initSet(allocator, 0);
        defer tmp2.deinit();
        try tmp2.mul(&lhs.i, &rhs.i);
        tmp2.negate();

        var tmp3 = try bigInt.Managed.initSet(allocator, 0);
        defer tmp3.deinit();
        try tmp3.mul(&lhs.j, &rhs.j);
        tmp3.negate();

        var tmp4 = try bigInt.Managed.initSet(allocator, 0);
        defer tmp4.deinit();
        try tmp4.mul(&lhs.k, &rhs.k);
        tmp4.negate();

        // set x
        try x.add(&tmp, &tmp2);
        try x.add(&x, &tmp3);
        try x.add(&x, &tmp4);

        // init
        try tmp.mul(&tmp, &zero);
        try tmp2.mul(&tmp2, &zero);
        try tmp3.mul(&tmp3, &zero);
        try tmp4.mul(&tmp4, &zero);

        // lhs.x * rhs.i + lhs.i * rhs.x + lhs.j * rhs.k - lhs.k * rhs.j
        try tmp.mul(&lhs.x, &rhs.i);
        try tmp2.mul(&lhs.i, &rhs.x);
        try tmp3.mul(&lhs.j, &rhs.k);
        try tmp4.mul(&lhs.k, &rhs.j);
        tmp4.negate();

        // set i
        try i.add(&tmp, &tmp2);
        try i.add(&i, &tmp3);
        try i.add(&i, &tmp4);

        // init
        try tmp.mul(&tmp, &zero);
        try tmp2.mul(&tmp2, &zero);
        try tmp3.mul(&tmp3, &zero);
        try tmp4.mul(&tmp4, &zero);

        // lhs.x * rhs.j - lhs.i * rhs.k + lhs.j * rhs.x + lhs.k * rhs.i
        try tmp.mul(&lhs.x, &rhs.j);
        try tmp2.mul(&lhs.i, &rhs.k);
        tmp2.negate();
        try tmp3.mul(&lhs.j, &rhs.x);
        try tmp4.mul(&lhs.k, &rhs.i);

        // set j
        try j.add(&tmp, &tmp2);
        try j.add(&j, &tmp3);
        try j.add(&j, &tmp4);

        // init
        try tmp.mul(&tmp, &zero);
        try tmp2.mul(&tmp2, &zero);
        try tmp3.mul(&tmp3, &zero);
        try tmp4.mul(&tmp4, &zero);

        // lhs.x * rhs.k + lhs.i * rhs.j - lhs.j * rhs.i + lhs.k * rhs.x
        try tmp.mul(&lhs.x, &rhs.k);
        try tmp2.mul(&lhs.i, &rhs.j);
        try tmp3.mul(&lhs.j, &rhs.i);
        tmp3.negate();
        try tmp4.mul(&lhs.k, &rhs.x);

        // set k
        try k.add(&tmp, &tmp2);
        try k.add(&k, &tmp3);
        try k.add(&k, &tmp4);

        return quaternion{
            .x = x,
            .i = i,
            .j = j,
            .k = k,
        };
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

    var result = q.conjugate();

    try testing.expect(bigInt.Managed.eql(result.x, expect.x));
    try testing.expect(bigInt.Managed.eql(result.i, expect.i));
    try testing.expect(bigInt.Managed.eql(result.j, expect.j));
    try testing.expect(bigInt.Managed.eql(result.k, expect.k));

    var expect2 = try quaternion.init(std.testing.allocator);
    defer expect2.deinit();
    try expect2.x.set(1);
    try expect2.i.set(2);
    try expect2.j.set(3);
    try expect2.k.set(4);

    result = q.conjugate();
    try testing.expect(bigInt.Managed.eql(result.x, expect2.x));
    try testing.expect(bigInt.Managed.eql(result.i, expect2.i));
    try testing.expect(bigInt.Managed.eql(result.j, expect2.j));
    try testing.expect(bigInt.Managed.eql(result.k, expect2.k));
}

test "quaternion multiplication" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var a = try quaternion.init(allocator);
    defer a.deinit();

    try a.x.set(1);
    try a.i.set(2);
    try a.j.set(3);
    try a.k.set(4);

    var b = try quaternion.init(allocator);
    defer b.deinit();

    try b.x.set(7);
    try b.i.set(6);
    try b.j.set(7);
    try b.k.set(8);

    const result = try a.mul(b, allocator);

    var expect = try quaternion.init(allocator);
    defer expect.deinit();

    try expect.x.set(-58);
    try expect.i.set(16);
    try expect.j.set(36);
    try expect.k.set(32);

    try testing.expect(bigInt.Managed.eql(result.x, expect.x));
    try testing.expect(bigInt.Managed.eql(result.i, expect.i));
    try testing.expect(bigInt.Managed.eql(result.j, expect.j));
    try testing.expect(bigInt.Managed.eql(result.k, expect.k));
}
