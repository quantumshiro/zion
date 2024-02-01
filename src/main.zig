const std = @import("std");
const testing = std.testing;

const this = @This();

pub const quaternion = struct {
    x: f32,
    i: f32,
    j: f32,
    k: f32,

    pub fn init(x: f32, i: f32, j: f32, k: f32) quaternion {
        return quaternion{
            .x = x,
            .i = i,
            .j = j,
            .k = k,
        };
    }
    // unit
    pub fn unit() quaternion {
        return quaternion{
            .x = 1.0,
            .i = 0.0,
            .j = 0.0,
            .k = 0.0,
        };
    }

    // quaternion conjugate
    pub fn conjugate(q: quaternion) quaternion {
        return quaternion{
            .x = q.x,
            .i = -q.i,
            .j = -q.j,
            .k = -q.k,
        };
    }

    // quaternion norm
    pub fn norm(q: quaternion) f32 {
        return q.x * q.x + q.i * q.i + q.j * q.j + q.k * q.k;
    }

    // inverse
    pub fn inverse() quaternion {
        const n = quaternion.norm(this);
        const conj = quaternion.conjugate(this);
        return quaternion{
            .x = conj.x / (n * n),
            .i = conj.i / (n * n),
            .j = conj.j / (n * n),
            .k = conj.k / (n * n),
        };
    }
};

// quaternion multiplications
pub fn mul(lhs: quaternion, rhs: quaternion) quaternion {
    return quaternion{
        .x = lhs.i * rhs.j - lhs.j * rhs.i + lhs.k * rhs.x + lhs.k * rhs.x,
        .i = lhs.j * rhs.x - lhs.x * rhs.j + lhs.k * rhs.i + lhs.k * rhs.i,
        .j = lhs.x * rhs.i - lhs.i * rhs.x + lhs.k * rhs.j + lhs.k * rhs.j,
        .k = lhs.k * rhs.k - lhs.x * rhs.x - lhs.i * rhs.i - lhs.j * rhs.j,
    };
}

// quaternion addition
pub fn add(lhs: quaternion, rhs: quaternion) quaternion {
    return quaternion{
        .x = lhs.x + rhs.x,
        .i = lhs.i + rhs.i,
        .j = lhs.j + rhs.j,
        .k = lhs.k + rhs.k,
    };
}

// quaternion subtraction
pub fn sub(lhs: quaternion, rhs: quaternion) quaternion {
    return quaternion{
        .x = lhs.x - rhs.x,
        .i = lhs.i - rhs.i,
        .j = lhs.j - rhs.j,
        .k = lhs.k - rhs.k,
    };
}

test "quaternion addition" {
    const a = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const b = quaternion{ .x = 5.0, .i = 6.0, .j = 7.0, .k = 8.0 };
    const c = add(a, b);
    try testing.expect(c.x == 6.0);
    try testing.expect(c.i == 8.0);
    try testing.expect(c.j == 10.0);
    try testing.expect(c.k == 12.0);
}

test "quaternion subtraction" {
    const a = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const b = quaternion{ .x = 5.0, .i = 6.0, .j = 7.0, .k = 8.0 };
    const c = sub(a, b);
    try testing.expect(c.x == -4.0);
    try testing.expect(c.i == -4.0);
    try testing.expect(c.j == -4.0);
    try testing.expect(c.k == -4.0);
}

test "quaternion norm" {
    const a = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const n = quaternion.norm(a);
    try testing.expect(n == 30.0);
}
