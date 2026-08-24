const w4 = @import("wasm4.zig");
const std = @import("std");
const Board = @import("Board.zig");
const Strategy = @import("Strategy.zig");
const tree = @import("tree.zig");


const title = std.fmt.comptimePrint("lossy_c4, {d} nodes", .{ tree.node_list.len });


const transparent = 0;
const white = 1;
const green = 2;
const dark = 3;
const orange = 4;

const player_colour: [2]u4 = .{ orange, green };


const square_size = 20;
const Coordinate = struct { x: u8, y: u8, };

const Move = struct {
    col: usize,
    row: usize,
    frame_num: u8,
    player: u1,
};

var move_buffer: [42]Move = undefined;
var move: std.ArrayList(Move) = undefined;
const max_frame_num = 20;

var animating = true;
var highlighted_col: ?usize = null;

var mouse_buttons: w4.MouseButtons = undefined;
var mouse_unclick: w4.MouseButtons = undefined;


var cursor = tree.NodeCursor {};
var game_ended = false;


fn cellCoord(col: usize, row: usize) Coordinate {
    return .{
        .x = @intCast(w4.SCREEN_SIZE / 2 + (2 * col - 7) * square_size / 2),
        .y = @intCast(w4.SCREEN_SIZE / 2 + (6 - 2 * row) * square_size / 2),
    };
}

fn drawGrid() void {
    setDrawColours(dark, undefined);

    for (0..8) |c| {
        const coord1 = cellCoord(c, 0);
        const coord2 = cellCoord(c, 6);

        w4.line(coord1.x, coord1.y, coord2.x, coord2.y);
    }

    for (0..7) |r| {
        const coord1 = cellCoord(0, r);
        const coord2 = cellCoord(7, r);

        w4.line(coord1.x, coord1.y, coord2.x, coord2.y);
    }
}

fn drawColumnHighlight(col: usize) void {
    setDrawColours(transparent, dark);

    const coord = cellCoord(col, 6);

    w4.rect(coord.x + 1, coord.y + 1, square_size - 1, 6 * square_size - 1);
}


fn updateHighlightedColumn() bool {
    const top_left = cellCoord(0, 6);
    const bottom_right = cellCoord(7, 0);

    const mouse_x = w4.MOUSE_X.*;
    const mouse_y = w4.MOUSE_Y.*;

    var new_highlighted_col: ?usize = null;

    if (mouse_x >= top_left.x and mouse_x < bottom_right.x
        and mouse_y >= top_left.y and mouse_y < bottom_right.y) {
            new_highlighted_col = @intCast(@divFloor(mouse_x - top_left.x, square_size));
        }

    const res = new_highlighted_col != highlighted_col;

    highlighted_col = new_highlighted_col;
    return res;
}


fn drawPiece(col: usize, row: usize, fill_colour: u4, edge_colour: u4, frame_num: u8) void {
    const coord = cellCoord(col, row);

    setDrawColours(fill_colour, edge_colour);

    var y_shift: i32 = frame_num;
    y_shift = @divFloor(y_shift * y_shift, 2);

    w4.oval(coord.x + 3, coord.y + 3 - square_size - y_shift, square_size - 5, square_size - 5);
}


fn drawStrategyNumber(col: usize, row: usize, n: u8, highlight: bool) void {
    if (n == Strategy.s1_invalid) return;

    var coord = cellCoord(col, row);

    coord.x += square_size / 2 - (w4.FONT_SIZE - 1) / 2;
    coord.y -= square_size / 2 + (w4.FONT_SIZE - 1) / 2;

    const msg: [2]u8 = .{ n + '0', 0 };

    if (highlight) {
        setDrawColours(orange, undefined);
        w4.text(&msg, coord.x - 1, coord.y);
        w4.text(&msg, coord.x + 1, coord.y);
        w4.text(&msg, coord.x, coord.y - 1);
        w4.text(&msg, coord.x, coord.y + 1);
    }

    setDrawColours(dark, undefined);
    w4.text(&msg, coord.x, coord.y);
}

fn setDrawColours(colour1: u4, colour2: u4) void {
    w4.DRAW_COLORS.*.c1 = colour1;
    w4.DRAW_COLORS.*.c2 = colour2;
}

fn fillScreen(colour: u4) void {
    setDrawColours(colour, colour);

    w4.rect(0, 0, w4.SCREEN_SIZE, w4.SCREEN_SIZE);
}

export fn start() void {
    w4.SYSTEM_FLAGS.preserve_framebuffer = true;

    w4.PALETTE[3] = 0xffa500; // orange

    mouse_buttons = w4.MOUSE_BUTTONS.*;

    move = .initBuffer(&move_buffer);

    computerMove();
}


fn updateMouse() bool {
    const new_mouse_buttons = w4.MOUSE_BUTTONS.*;
    const new_mouse_unclick = w4.MouseButtons {
        .left = mouse_buttons.left and !new_mouse_buttons.left,
        .middle = mouse_buttons.middle and !new_mouse_buttons.middle,
        .right = mouse_buttons.right and !new_mouse_buttons.right,
    };

    if (new_mouse_buttons == mouse_buttons and new_mouse_unclick == mouse_unclick) return false;

    mouse_buttons = new_mouse_buttons;
    mouse_unclick = new_mouse_unclick;

    return true;
}


fn drawBoard() void {
    drawGrid();

    animating = false;

    for (move.items) |*m| {
        drawPiece(m.col, m.row, player_colour[m.player], player_colour[m.player], m.frame_num);

        if (m.frame_num > 0) {
            animating = true;
            m.frame_num -= 1;
        }
    }

    var win_mask: u56 = 0;

    const b = cursor.board.invert();

    inline for (.{ 8, 9, 7, 1 }) |shift| {
        var t = b.data;
        t &= t >> shift;
        t &= t >> 2 * shift;
        t |= t << shift;
        t |= t << 2 * shift;
        win_mask |= t;
    }

    const bit_set : std.bit_set.IntegerBitSet(56) = .{ .mask = win_mask };
    var bit_set_iterator = bit_set.iterator( .{} );

    while (bit_set_iterator.next()) |pos|
        drawPiece(pos / 8, pos % 8, transparent, dark, 0);
}


fn computerMove() void {
    const col = cursor.redMove() catch unreachable;
    const row = cursor.board.getColLen(col) - 1;

    // Hack: reduce animation time for first move
    const frame_num: u8 = if (cursor.board.data == 0) max_frame_num else max_frame_num * 3 / 2;

    move.appendAssumeCapacity(Move { .col = col, .row = row, .player = 0, .frame_num = frame_num });
    animating = true;
}


fn playerMove(col: usize) bool {
    cursor.yellowMove(col) catch return false;
    const row = cursor.board.getColLen(col) - 1;

    move.appendAssumeCapacity(Move { .col = col, .row = row, .player = 1, .frame_num = max_frame_num});
    animating = true;

    return true;
}

fn drawStrategyNumbers(c: *tree.NodeCursor) void {
    switch (c.node.*) {
        .strategy => |strategy| {
            for (0..7) |col| {
                const first = cursor.board.getColLen(col);
                const highlight_row = c.board.getColLen(col);
                for (first..6) |row| {
                    const n = strategy.get(col, row, c.orientation);

                    drawStrategyNumber(col, row, n, row == highlight_row);
                }
            }
        },
        else => {},
    }
}



export fn update() void {
    var do_update = false;

    do_update |= updateHighlightedColumn();
    do_update |= updateMouse();
    do_update |= animating;

    if (!do_update)
        return;

    if (mouse_unclick.left and highlighted_col != null and !game_ended) {
        if (playerMove(highlighted_col.?)) {
            computerMove();

            if (cursor.board.hasWon(0)) game_ended = true;
        }
    }

    fillScreen(white);

    setDrawColours(dark, undefined);
    w4.text(title, (w4.SCREEN_SIZE - title.len * w4.FONT_SIZE) / 2, 4);

    // Draw grid and current pieces
    drawBoard();

    const col1 = highlighted_col.?;
    if (highlighted_col == null) {
        drawStrategyNumbers(&cursor);
        return;
    }

    drawColumnHighlight(col1);

    const row1 = cursor.board.getColLen(col1);

    if (row1 >= 6 or game_ended) {
        drawStrategyNumbers(&cursor);
        return;
    }

    drawPiece(col1, row1, transparent, player_colour[1], 0);

    var next_cursor = cursor;

    next_cursor.yellowMove(col1) catch unreachable;

    drawStrategyNumbers(&next_cursor);

    const col0 = next_cursor.redMove() catch unreachable;
    const row0 = next_cursor.board.getColLen(col0) - 1;

    drawPiece(col0, row0, transparent, player_colour[0], 0);
}
