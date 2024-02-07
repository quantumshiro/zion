const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

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
        return @sqrt(self.x * self.x + self.i * self.i + self.j * self.j + self.k * self.k);
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

    // 単位四元数から回転行列を生成
    // M = 1 - 2(q_j^2 + q_k^2)  2(q_iq_j - q_kq_r)    2(q_iq_k + q_jq_r)   0
    //     2(q_iq_j + q_kq_r)    1 - 2(q_i^2 + q_k^2)  2(q_jq_k - q_iq_r)   0
    //     2(q_iq_k - q_jq_r)    2(q_jq_k + q_iq_r)    1 - 2(q_i^2 + q_j^2) 0
    //     0                     0                     0                    1
    pub fn to_matrix(self: this) matrix {
        const x2 = self.x + self.x;
        const y2 = self.i + self.i;
        const z2 = self.j + self.j;
        const xx = self.x * x2;
        const xy = self.x * y2;
        const xz = self.x * z2;
        const yy = self.i * y2;
        const yz = self.i * z2;
        const zz = self.j * z2;
        const wx = self.x * self.k;
        const wy = self.i * self.k;
        const wz = self.j * self.k;

        return matrix{
            .m11 = 1.0 - (yy + zz),
            .m12 = xy - wz,
            .m13 = xz + wy,
            .m14 = 0.0,
            .m21 = xy + wz,
            .m22 = 1.0 - (xx + zz),
            .m23 = yz - wx,
            .m24 = 0.0,
            .m31 = xz - wy,
            .m32 = yz + wx,
            .m33 = 1.0 - (xx + yy),
            .m34 = 0.0,
            .m41 = 0.0,
            .m42 = 0.0,
            .m43 = 0.0,
            .m44 = 1.0,
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
    try testing.expect(n == @sqrt(30.0));
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

pub const axis = struct {
    x: f32,
    y: f32,
    z: f32,

    const this = @This();

    // 回転軸と角度から単位四元数を生成
    // axis: 回転軸 (x, y, z)
    // angle: 回転角度 angle
    // pub fn from_axis_angle(q: axis, angle: f32) !quaternion {
    //     const half_angle = angle / 2;
    //     const s = @sin(half_angle);
    //     const c = @cos(half_angle);
    //     return quaternion{
    //         .x = c,
    //         .i = q.x * s,
    //         .j = q.y * s,
    //         .k = q.z * s,
    //     };
    // }
    pub fn from_axis_angle(self: this, angle: f32) quaternion {
        const half_angle = angle / 2;
        const s = @sin(half_angle);
        const c = @cos(half_angle);
        return quaternion{
            .x = c,
            .i = self.x * s,
            .j = self.y * s,
            .k = self.z * s,
        };
    }
};

fn trace(m: matrix) f32 {
    return m.m11 + m.m22 + m.m33 + m.m44;
}

pub const matrix = struct {
    m11: f32,
    m12: f32,
    m13: f32,
    m14: f32,
    m21: f32,
    m22: f32,
    m23: f32,
    m24: f32,
    m31: f32,
    m32: f32,
    m33: f32,
    m34: f32,
    m41: f32,
    m42: f32,
    m43: f32,
    m44: f32,

    const this = @This();

    // 直行行列から単位四元数を生成
    // M = 1 - 2(q_j^2 + q_k^2)  2(q_iq_j - q_kq_r)    2(q_iq_k + q_jq_r)   0
    //     2(q_iq_j + q_kq_r)    1 - 2(q_i^2 + q_k^2)  2(q_jq_k - q_iq_r)   0
    //     2(q_iq_k - q_jq_r)    2(q_jq_k + q_iq_r)    1 - 2(q_i^2 + q_j^2) 0
    //     0                     0                     0                    1
    pub fn from_matrix(m: this) quaternion {
        var x = 1 / 2 * @sqrt(trace(m));
        return quaternion{
            .x = x,
            .i = (m.m32 - m.m23) / (4 * x),
            .j = (m.m13 - m.m31) / (4 * x),
            .k = (m.m21 - m.m12) / (4 * x),
        };
    }
};

test "quaternion from axis angle" {
    const q = axis{ .x = 1.0, .y = 0.0, .z = 0.0 };
    const r = q.from_axis_angle(std.math.pi / 2.0);
    try testing.expect(r.x == @cos(std.math.pi / 4.0));
    try testing.expect(r.i == @sin(std.math.pi / 4.0));
    try testing.expect(r.j == 0.0);
    try testing.expect(r.k == 0.0);
}

test "to_matrix function" {
    var q = quaternion{
        .x = 0.0,
        .i = 0.0,
        .j = 0.0,
        .k = 1.0,
    };

    var m = q.to_matrix();

    var expected = matrix{
        .m11 = 1.0,
        .m12 = 0.0,
        .m13 = 0.0,
        .m14 = 0.0,
        .m21 = 0.0,
        .m22 = 1.0,
        .m23 = 0.0,
        .m24 = 0.0,
        .m31 = 0.0,
        .m32 = 0.0,
        .m33 = 1.0,
        .m34 = 0.0,
        .m41 = 0.0,
        .m42 = 0.0,
        .m43 = 0.0,
        .m44 = 1.0,
    };

    assert(m.m11 == expected.m11);
    assert(m.m12 == expected.m12);
    assert(m.m13 == expected.m13);
    assert(m.m14 == expected.m14);
    assert(m.m21 == expected.m21);
    assert(m.m22 == expected.m22);
    assert(m.m23 == expected.m23);
    assert(m.m24 == expected.m24);
    assert(m.m31 == expected.m31);
    assert(m.m32 == expected.m32);
    assert(m.m33 == expected.m33);
    assert(m.m34 == expected.m34);
    assert(m.m41 == expected.m41);
    assert(m.m42 == expected.m42);
    assert(m.m43 == expected.m43);
    assert(m.m44 == expected.m44);
}

pub const polynoimal = struct {
    coefficients: []quaternion,

    pub fn init(allocator: *std.mem.Allocator, degree: usize) !polynoimal {
        const coefficients = try allocator.alloc(quaternion, degree + 1);
        return polynoimal{
            .coefficients = coefficients,
        };
    }

    pub fn set(self: *polynoimal, index: usize, value: quaternion) void {
        self.coefficients[index] = value;
    }
};
