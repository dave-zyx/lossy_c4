const std = @import("std");
const Board = @import("Board.zig");
const Strategy = @This();


data: [21]u8 = @splat(0),


const StrategyError = error {
    MissingStrategy,
};

// non-inclusive maximum
pub const s1_max = 9;
pub const s1_invalid = s1_max;


pub fn get(self: Strategy, col: usize, row: usize, flip: bool) u4 {
    std.debug.assert(col < 7);
    std.debug.assert(row < 6);

    const col2 = if (flip) 6 - col else col;

    const value = self.data[3 * col2 + row / 2];
    const shift: u3 = @truncate((row & 1) * 4);

    return @truncate(value >> shift);
}


fn put(self: *Strategy, col: usize, row: usize, value: u4) void {
    // Assumes existing value is zero
    std.debug.assert(col < 7);
    std.debug.assert(row < 6);

    self.data[3 * col + row / 2] |= @shlExact(@as(u8, value), (row & 1) * 4);
}

pub fn apply(strategy: Strategy, flip: bool, b: *Board) !usize {
    // Given that the strategy is to play next, resolve a single move and
    // update the board accordingly.

    // Step 1: if we can win then win
    var child0: [7]Board = undefined;

    for (0..7) |i| {
        child0[i] = b.*;

        // If any move results in a win then take it now
        if (child0[i].playHasWon(i, 0) catch continue) {
            b.* = child0[i];
            return i;
        }
    }

    // Step 2: do we need to block a move? Note that if there is more than
    // one move to block then the strategy will play without being well-defined,
    // though all cases will result in a loss upon the subsequent opponent move.
    for (0..7) |i| {
        // If any opponent move results in a loss then take it preventatively
        var child1 = b.*;

        if (child1.playHasWon(i, 1) catch continue) {
            b.* = child0[i];
            return i;
        }
    }

    // Step 3: compute least strategy that occurs precisely once
    var strategy_to_col:[s1_max]u8 = undefined;

    // We only need as many bits as strategies
    var at_least_1: u32 = 0;
    var at_least_2: u32 = 0;

    for (0..7) |col| {
        const col_len = b.getColLen(col);

        if (col_len == 6) continue;

        const value = strategy.get(col, col_len, flip);

        if (value >= Strategy.s1_max) continue;

        const bit = @as(u32, 1) << @as(u5, @intCast(value));

        if (at_least_1 & bit == 0) {
            strategy_to_col[value] = @intCast(col);
            at_least_1 |= bit;
        }
        else { at_least_2 |= bit; }
    }

    // Choose least of strategies that occur precisely once
    const chosen_strategy = @ctz(at_least_1 & ~at_least_2);

    if (chosen_strategy == 32) return StrategyError.MissingStrategy;

    const col = strategy_to_col[chosen_strategy];

    b.* = child0[col];

    return col;
}


pub fn fromString(str: []const u8) Strategy {
    @setEvalBranchQuota(100000);

    var res = Strategy {};
    var i: usize = 0;

    for (str) |c| {
        const v: u8 = switch (c) {
            '0'...'9' => c - '0',
            '.' => s1_invalid,
            else => continue,
        };

        // String rows are from top to bottom; internal rows are from bottom to top
        res.put(i % 7, 6 - 1 - i / 7, v);
        i += 1;

        if (i == 42) { break; }
    }

    std.debug.assert(i == 42);

    return res;
}
