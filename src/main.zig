const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

const bigInt = std.math.big.int;
const bigRatinal = std.math.big.Rational;

pub const quaternion = struct {
    x: bigRatinal,
    i: bigRatinal,
    j: bigRatinal,
    k: bigRatinal,

    const this = @This();

    pub fn deinit(self: *this) void {
        self.x.deinit();
        self.i.deinit();
        self.j.deinit();
        self.k.deinit();
    }

    // unit
    // sample usage: quaternion.unit()
    pub fn unit() quaternion {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        const one = try bigRatinal.setInt(allocator, 1.0);
        const zero = try bigRatinal.setInt(allocator, 0.0);
        return quaternion{
            .x = one,
            .i = zero,
            .j = zero,
            .k = zero,
        };
    }

    // quaternion conjugate
    // sample usage: var q = quaternion.init(1.0, 2.0, 3.0, 4.0).conjugate()
    pub fn conjugate(self: this) quaternion {
        return quaternion{
            .x = self.x,
            .i = try bigRatinal.mul(&self.i, -1, &self.i),
            .j = try bigRatinal.mul(&self.j, -1, &self.j),
            .k = try bigRatinal.mul(&self.k, -1, &self.k),
        };
    }

    // quaternion norm
    // sample usage: var n = quaternion.init(1.0, 2.0, 3.0, 4.0).norm()
    pub fn norm(allocator: *std.mem.Allocator, self: this) bigRatinal {
        // return @sqrt(self.x * self.x + self.i * self.i + self.j * self.j + self.k * self.k);

        // initialize
        const xx = try bigInt.Managed.init(allocator);
        const ii = try bigInt.Managed.init(allocator);
        const jj = try bigInt.Managed.init(allocator);
        const kk = try bigInt.Managed.init(allocator);
        var sum = try bigInt.Managed.init(allocator);
        var ans = try bigInt.Managed.init(allocator);

        // calculate
        xx = try bigInt.Managed.mul(&xx, &self.x, &self.x);
        ii = try bigInt.Managed.mul(&ii, &self.i, &self.i);
        jj = try bigInt.Managed.mul(&jj, &self.j, &self.j);
        kk = try bigInt.Managed.mul(&kk, &self.k, &self.k);

        sum = try bigInt.Managed.add(&sum, &xx, &ii);
        sum = try bigInt.Managed.add(&sum, &sum, &jj);
        sum = try bigInt.Managed.add(&sum, &sum, &kk);

        // conver to bigInt from bigRatinal
        var sum_copy = try bigRatinal.init(allocator);
        try bigRatinal.copyInt(&sum_copy, &sum);

        try bigInt.Managed.sqr(&ans, &sum);
        var ans_copy = try bigRatinal.init(allocator);
        try bigRatinal.copyInt(&ans_copy, &ans);

        return ans_copy;
    }

    // inverse
    pub fn inverse(self: this) quaternion {
        // allocate memory
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const allocator = arena.allocator();

        // get quaternion inverse
        const n = self.norm();
        const conj = self.conjugate();

        // initialize
        var x = try bigInt.Managed.init(allocator);
        var i = try bigInt.Managed.init(allocator);
        var j = try bigInt.Managed.init(allocator);
        var k = try bigInt.Managed.init(allocator);

        var n2 = try bigInt.Managed.init(allocator);
        n2 = n2.mul(&n, &n);

        x = x.div(&conj.x, &n2);
        i = i.div(&conj.i, &n2);
        j = j.div(&conj.j, &n2);
        k = k.div(&conj.k, &n2);

        return quaternion{
            .x = x,
            .i = i,
            .j = j,
            .k = k,
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

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const one = bigInt.Managed.initSet(allocator, 1.0);
    const zero = bigInt.Managed.initSet(allocator, 0.0);

    try testing.expectEqual(one, q.x);
    try testing.expectEqual(zero, q.i);
    try testing.expectEqual(zero, q.j);
    try testing.expectEqual(zero, q.k);
}

test "quaternion norm" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const q = quaternion{ .x = try bigInt.Managed.initSet(allocator, 1.0), .i = try bigInt.Managed.initSet(allocator, 2.0), .j = try bigInt.Managed.initSet(allocator, 3.0), .k = try bigInt.Managed.initSet(allocator, 4.0) };

    const n = q.norm();
    var expected = try bigInt.Managed.initSet(allocator, 30.0);
    try bigInt.Managed.sqr(&expected, &expected);
    try testing.expectEqual(expected, n);
}

test "quaternion conjugate" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const q = quaternion{ .x = try bigInt.Managed.initSet(allocator, 1.0), .i = try bigInt.Managed.initSet(allocator, 2.0), .j = try bigInt.Managed.initSet(allocator, 3.0), .k = try bigInt.Managed.initSet(allocator, 4.0) };
    const c = q.conjugate();

    const expected = quaternion{
        .x = try bigInt.Managed.initSet(allocator, 1.0),
        .i = try bigInt.Managed.initSet(allocator, -2.0),
        .j = try bigInt.Managed.initSet(allocator, -3.0),
        .k = try bigInt.Managed.initSet(allocator, -4.0),
    };

    try testing.expectEqual(expected.x, c.x);
    try testing.expectEqual(expected.i, c.i);
    try testing.expectEqual(expected.j, c.j);
    try testing.expectEqual(expected.k, c.k);
}

test "quaternion inverse" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const q = quaternion{ .x = try bigInt.Managed.initSet(allocator, 1.0), .i = try bigInt.Managed.initSet(allocator, 2.0), .j = try bigInt.Managed.initSet(allocator, 3.0), .k = try bigInt.Managed.initSet(allocator, 4.0) };

    const c = q.inverse();
    const n = q.norm();

    const x = try bigInt.Managed.init(allocator);
    const i = try bigInt.Managed.init(allocator);
    const j = try bigInt.Managed.init(allocator);
    const k = try bigInt.Managed.init(allocator);

    var n2 = try bigInt.Managed.init(allocator);
    try bigInt.Managed.mul(&n2, &n, &n);

    try bigRatinal.div(&x, &c.x, &n2);
    try bigRatinal.div(&i, &c.i, &n2);
    try bigRatinal.div(&j, &c.j, &n2);
    try bigRatinal.div(&k, &c.k, &n2);

    try testing.expectEqual(q.x, x);
    try testing.expectEqual(q.i, i);
    try testing.expectEqual(q.j, j);
    try testing.expectEqual(q.k, k);
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
        const x = 1 / 2 * @sqrt(trace(m));
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

    const m = q.to_matrix();

    const expected = matrix{
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

pub const polynomial = struct {
    coefficients: []quaternion,

    const this = @This();

    pub fn init(allocator: *std.mem.Allocator, degree: usize) !polynomial {
        const coefficients = try allocator.alloc(quaternion, degree + 1);
        return polynomial{
            .coefficients = coefficients,
        };
    }

    pub fn set(self: *polynomial, index: usize, value: quaternion) void {
        self.coefficients[index] = value;
    }

    pub fn pow(x: quaternion, n: usize) quaternion {
        var result = quaternion.unit();
        for (0..n) |_| {
            result = mul(result, x);
        }
        return result;
    }

    pub fn evaluate(self: this, x: quaternion) quaternion {
        var result = quaternion{ .x = 0.0, .i = 0.0, .j = 0.0, .k = 0.0 };
        for (self.coefficients, 0..self.coefficients.len) |c, i| {
            result = add(result, mul(c, polynomial.pow(x, i)));
        }
        return result;
    }
};

test "polynomial evaluation" {
    var allocator = std.heap.page_allocator;
    var p = try polynomial.init(&allocator, 3); // 3次の多項式を初期化

    // 係数をセット（例：x^3 + 2x^2 + 3x + 4）
    p.set(0, quaternion{ .x = 4.0, .i = 0.0, .j = 0.0, .k = 0.0 });
    p.set(1, quaternion{ .x = 3.0, .i = 0.0, .j = 0.0, .k = 0.0 });
    p.set(2, quaternion{ .x = 2.0, .i = 0.0, .j = 0.0, .k = 0.0 });
    p.set(3, quaternion{ .x = 1.0, .i = 0.0, .j = 0.0, .k = 0.0 });

    // x = 1 で多項式を評価
    var x = quaternion{ .x = 1.0, .i = 0.0, .j = 0.0, .k = 0.0 };
    var result = p.evaluate(x);

    // 期待される結果は 10（1^3 + 2*1^2 + 3*1 + 4）
    try testing.expectEqual(quaternion{ .x = 10.0, .i = 0.0, .j = 0.0, .k = 0.0 }, result);

    var q = try polynomial.init(&allocator, 2); // 2次の多項式を初期化

    // 係数をセット（例：x^2 + x + 1）
    q.set(0, quaternion.unit());
    q.set(1, quaternion.unit());
    q.set(2, quaternion.unit());

    // x = 2 で多項式を評価
    x = quaternion{ .x = 2.0, .i = 0.0, .j = 0.0, .k = 0.0 };
    result = q.evaluate(x);

    // 期待される結果は 7（2^2 + 2 + 1）
    try testing.expectEqual(quaternion{ .x = 7.0, .i = 0.0, .j = 0.0, .k = 0.0 }, result);
}
