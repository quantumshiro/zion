const std = @import("std");
const testing = std.testing;

const this = @This();

pub const quaternion = struct {
    x: f32,
    i: f32,
    j: f32,
    k: f32,
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
