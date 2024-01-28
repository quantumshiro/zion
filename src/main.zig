const std = @import("std");
const testing = std.testing;

const this = @This();

pub const quaternion = struct {
    x: f32,
    i: f32,
    j: f32,
    k: f32,
};
