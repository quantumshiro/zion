const std = @import("std");
const testing = std.testing;

pub const quaternion = struct {
    x: f32,
    i: f32,
    j: f32,
    k: f32,

    const this = @This();

    // unit
    // sample usage: quaternion.unit()
    pub fn unit() quaternion {
        return quaternion{
            .x = 1.0,
            .i = 0.0,
            .j = 0.0,
            .k = 0.0,
        };
    }

    // quaternion conjugate
    // sample usage: var q = quaternion.init(1.0, 2.0, 3.0, 4.0).conjugate()
    pub fn conjugate(self: this) quaternion {
        return quaternion{
            .x = self.x,
            .i = -self.i,
            .j = -self.j,
            .k = -self.k,
        };
    }

    // quaternion norm
    // sample usage: var n = quaternion.init(1.0, 2.0, 3.0, 4.0).norm()
    pub fn norm(self: this) f32 {
        return self.x * self.x + self.i * self.i + self.j * self.j + self.k * self.k;
    }

    // inverse
    pub fn inverse(self: this) quaternion {
        const n = self.norm();
        const conj = self.conjugate();
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
        .x = lhs.x * rhs.x - lhs.i * rhs.i - lhs.j * rhs.j - lhs.k * rhs.k,
        .i = lhs.x * rhs.i + lhs.i * rhs.x + lhs.j * rhs.k - lhs.k * rhs.j,
        .j = lhs.x * rhs.j - lhs.i * rhs.k + lhs.j * rhs.x + lhs.k * rhs.i,
        .k = lhs.x * rhs.k + lhs.i * rhs.j - lhs.j * rhs.i + lhs.k * rhs.x,
    };
}

// quaternion division
// hls/rhs
pub fn div(lhs: quaternion, rhs: quaternion) quaternion {
    return mul(lhs, rhs.inverse());
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

test "quaternion unit" {
    const q = quaternion.unit();
    try testing.expect(q.x == 1.0);
    try testing.expect(q.i == 0.0);
    try testing.expect(q.j == 0.0);
    try testing.expect(q.k == 0.0);
}

test "quaternion norm" {
    const q = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const n = q.norm();
    try testing.expect(n == 30.0);
}

test "quaternion conjugate" {
    const q = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const c = q.conjugate();
    try testing.expect(c.x == 1.0);
    try testing.expect(c.i == -2.0);
    try testing.expect(c.j == -3.0);
    try testing.expect(c.k == -4.0);
}

test "quaternion inverse" {
    const q = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const c = q.inverse();
    const n = q.norm();
    try testing.expect(c.x == 1.0 / (n * n));
    try testing.expect(c.i == -2.0 / (n * n));
    try testing.expect(c.j == -3.0 / (n * n));
    try testing.expect(c.k == -4.0 / (n * n));
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

test "qaternion multiplication" {
    const a = quaternion{ .x = 1.0, .i = 2.0, .j = 3.0, .k = 4.0 };
    const b = quaternion{ .x = 7.0, .i = 6.0, .j = 7.0, .k = 8.0 };
    const c = mul(a, b);
    try testing.expect(c.x == -58.0);
    try testing.expect(c.i == 16.0);
    try testing.expect(c.j == 36.0);
    try testing.expect(c.k == 32.0);
}
