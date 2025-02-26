const std = @import("std");
const builtin = @import("builtin");
// warn is now print
const warn = std.debug.print;
// compiler demands all named variables to be used
pub fn panic(_: []const u8, _: ?*builtin.StackTrace) noreturn {
    std.os.exit(0xF);
}

fn pow(base: usize, exp: usize) usize {
    var x: usize = base;
    var i: usize = 1;

    while (i < exp) : (i += 1) {
        x *= base;
    }
    return x;
}

export fn add(a: i32, b: i32) callconv(.C) i32 {
    return a + b;
}

export fn printing(buf: [*]const u8, len: usize) callconv(.C) void {
    var s = buf[0..len];
    // formatting rules changed
    warn("Zig says: {s}\n", .{s});
}

fn itoa(comptime N: type, n: N, buff: []u8) void {
    @setRuntimeSafety(false);

    comptime var UNROLL_MAX: usize = 4;
    // double specification of comptime keyword is forbidden
    comptime var DIV_CONST: usize = pow(10, UNROLL_MAX);

    var num = n;
    var len = buff.len;

    while (len >= UNROLL_MAX) : (num = std.math.divTrunc(N, num, DIV_CONST) catch return) {
        comptime var DIV10: N = 1;
        comptime var CURRENT: usize = 0;

        // Write digits backwards into the buffer
        inline while (CURRENT != UNROLL_MAX) : ({
            CURRENT += 1;
            DIV10 *= 10;
        }) {
            var q = std.math.divTrunc(N, num, DIV10) catch break;
            // @turncate type should be inferred now so use @as
            var r: u8 = @as(u8, @truncate(std.math.mod(N, q, 10) catch break)) + 48;
            buff[len - CURRENT - 1] = r;
        }

        len -= UNROLL_MAX;
    }

    // On an empty buffer, this will wrapparoo to 0xfffff
    len -%= 1;

    // Stops at 0xfffff
    while (len != std.math.maxInt(usize)) : (len -%= 1) {
        var q: N = std.math.divTrunc(N, num, 10) catch break;
        // see line 50
        var r: u8 = @as(u8, @truncate(std.math.mod(N, num, 10) catch break)) + 48;
        buff[len] = r;
        num = q;
    }
}

export fn itoa_u64(n: u64, noalias buff: [*]u8, len: usize) callconv(.C) void {
    @setRuntimeSafety(false);
    var slice = buff[0..len];

    itoa(u64, n, slice);
}

test "empty buff" {
    var small_buff: []u8 = &[_]u8{};

    var small: u64 = 100;

    _ = itoa_u64(small, small_buff.ptr, small_buff.len);
}

test "small buff" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var small_buff = [_]u8{10} ** 3;

    comptime var small: u64 = 100;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    comptime itoa_u64(small, &small_buff, small_buff.len);

    assert(mem.eql(u8, &small_buff, "100"));
}

test "big buff" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var big_buff = [_]u8{0} ** 10;

    comptime var big: u64 = 1234123412;

    comptime itoa_u64(big, &big_buff, big_buff.len);

    assert(mem.eql(u8, &big_buff, "1234123412"));
}

test "unroll count buf" {
    const assert = @import("std").debug.assert;
    const mem = @import("std").mem;

    comptime var small_buff = [_]u8{10} ** 4;

    comptime var small: u64 = 1000;

    // Should only run the 2nd while-loop, which is kinda like a fixup loop.
    comptime itoa_u64(small, &small_buff, small_buff.len);

    assert(mem.eql(u8, &small_buff, "1000"));
}
