const std = @import("std");

const Board = @This();


data: u56 = 0,
valid: u56 = 0,


pub const BoardError = error {
    ColumnFull,
};


/// Return number of pieces in given column, 0 <= col < 7
pub fn getColLen(self: Board, col: usize) u8 {
    const col_bitmask: u8 = @truncate(self.valid >> @intCast(8 * col));

    return @popCount(col_bitmask);
}

/// Play in the given column or Error if column is full.
pub fn play(self: *Board, col: usize, comptime player: u1) !void {
    const shift: u6 = @intCast(8 * col);
    const valid_mask_delta: u56 = self.valid + (@as(u56, 1) << shift);

    if (valid_mask_delta & 0xc0c0c0c0c0c0c0 != 0) return BoardError.ColumnFull;

    // Assume cell already contains a 0 when player == 0.
    if (player == 1) self.data |= valid_mask_delta & ~self.valid;

    self.valid |= valid_mask_delta;
}


/// Swap the two players
pub fn invert(self: Board) Board {
    return .{ .data = ~self.data & self.valid, .valid = self.valid };
}


/// Does the given player have four-in-a-row?
pub fn hasWon(self: Board, comptime player: u1) bool {
    if (player == 0)
        return self.invert().hasWon(1);

    inline for (.{ 8, 9, 7, 1 }) |shift| {
        var t = self.data;
        t &= t >> shift;
        t &= t >> 2 * shift;
        if (t != 0) return true;
    }

    return false;
}


/// Call play() then return whether or not the move resulted in victory.
/// Assumes neither player has already won.
pub fn playHasWon(self: *Board, col: usize, comptime player: u1) !bool {
    try self.play(col, player);

    return self.hasWon(player);
}
