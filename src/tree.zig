const Strategy = @import("Strategy.zig");
const Board = @import("Board.zig");

const TreeError = error {
    IntegrityError,
};

const ValueType = enum { yellow, red, strategy };

const NodeTransition = packed struct {
    index: u15,
    flip: bool,
};

const RedTransition = struct {
    child: u8,
    transition: NodeTransition,
};

const Node = union(ValueType) {
    yellow: [7]NodeTransition,
    red: RedTransition,
    strategy: Strategy,
};

pub const NodeCursor = struct {
    node: *const Node = &node_list[1],
    orientation: bool = false,
    board: Board = Board {},

    pub fn doTransition(self: *NodeCursor, transition: NodeTransition) void {
        self.node = &node_list[transition.index];

        self.orientation ^= transition.flip;
    }

    pub fn redMove(self: *NodeCursor) !usize {
        switch(self.node.*) {
            .red => |r| {
                const col = if (self.orientation) 6 - r.child else r.child;
                self.doTransition(r.transition);
                try self.board.play(col, 0);
                return col;
            },
            .strategy => |s| return s.apply(self.orientation, &self.board),
            .yellow => return TreeError.IntegrityError,
        }
    }

    pub fn yellowMove(self: *NodeCursor, col: usize) !void {
        const child = if (self.orientation) 6 - col else col;

        try self.board.play(col, 1);

        switch(self.node.*) {
            .red => unreachable,
            .strategy => {},
            .yellow => |y| self.doTransition(y[child]),
        }
    }
};



pub const node_list = [_]Node {
Node { .strategy = Strategy.fromString("444444444444444444444444444444444444444444") }, //
Node { .red = .{ .child = 3, .transition = .{ .index = 2, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 302, .flip = false}, .{ .index = 3, .flip = false}, .{ .index = 99, .flip = false}, .{ .index = 311, .flip = false}, .{ .index = 99, .flip = true}, .{ .index = 3, .flip = true}, .{ .index = 302, .flip = true}, } },
Node { .red = .{ .child = 5, .transition = .{ .index = 4, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 5, .flip = false}, .{ .index = 5, .flip = false}, .{ .index = 97, .flip = false}, .{ .index = 5, .flip = false}, .{ .index = 6, .flip = true}, .{ .index = 5, .flip = false}, .{ .index = 72, .flip = true}, } },
Node { .strategy = Strategy.fromString("....... ....... ....... .0.0... 0....0. ....1..") }, // 426
Node { .red = .{ .child = 1, .transition = .{ .index = 7, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 8, .flip = false}, .{ .index = 13, .flip = false}, .{ .index = 52, .flip = false}, .{ .index = 40, .flip = false}, .{ .index = 36, .flip = false}, .{ .index = 58, .flip = false}, .{ .index = 27, .flip = true}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 9, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 10, .flip = false}, .{ .index = 12, .flip = false}, .{ .index = 12, .flip = false}, .{ .index = 11, .flip = false}, .{ .index = 10, .flip = false}, .{ .index = 10, .flip = false}, .{ .index = 10, .flip = false}, } },
Node { .strategy = Strategy.fromString(".00..00 ....... ..1..00 2030... ...2043 .......") }, // 4623213
Node { .strategy = Strategy.fromString(".040.00 ....... ..05..0 .01231. 3..2..1 ....4..") }, // 4623213
Node { .strategy = Strategy.fromString("0003.0. ...0... .11..0. ...00.0 ...0.2. ....4.2") }, // 4623213
Node { .red = .{ .child = 3, .transition = .{ .index = 14, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 15, .flip = false}, .{ .index = 15, .flip = false}, .{ .index = 23, .flip = false}, .{ .index = 16, .flip = false}, .{ .index = 15, .flip = false}, .{ .index = 15, .flip = false}, .{ .index = 15, .flip = false}, } },
Node { .strategy = Strategy.fromString("000100. ...2..0 .30..0. ...00.0 ..1..4. ....5.4") }, // 4623224
Node { .red = .{ .child = 3, .transition = .{ .index = 17, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 19, .flip = false}, .{ .index = 18, .flip = false}, .{ .index = 18, .flip = false}, .{ .index = 18, .flip = false}, .{ .index = 18, .flip = false}, .{ .index = 18, .flip = false}, .{ .index = 18, .flip = false}, } },
Node { .strategy = Strategy.fromString("0114.11 ....... 362..01 0.1.1.. 5.2..54 3...2..") }, // 462322444
Node { .red = .{ .child = 4, .transition = .{ .index = 20, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 21, .flip = false}, .{ .index = 21, .flip = false}, .{ .index = 22, .flip = false}, .{ .index = 21, .flip = false}, .{ .index = 21, .flip = false}, .{ .index = 21, .flip = false}, .{ .index = 21, .flip = false}, } },
Node { .strategy = Strategy.fromString("00.0044 .....31 .0..144 ..3.122 5...144 ......3") }, // 46232244415
Node { .strategy = Strategy.fromString("0.54.6. ..24.0. 4.2..1. ..0.13. 6...163 .......") }, // 46232244415
Node { .red = .{ .child = 2, .transition = .{ .index = 24, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 25, .flip = false}, .{ .index = 25, .flip = false}, .{ .index = 26, .flip = false}, .{ .index = 25, .flip = false}, .{ .index = 25, .flip = false}, .{ .index = 26, .flip = false}, .{ .index = 25, .flip = false}, } },
Node { .strategy = Strategy.fromString("5040.13 5.1.013 5310.76 5...023 5....76 5...4.6") }, // 462322433
Node { .strategy = Strategy.fromString("00030.0 ...3.0. 5021..0 1..321. 5.....4 5......") }, // 462322433
Node { .red = .{ .child = 3, .transition = .{ .index = 28, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 30, .flip = false}, .{ .index = 29, .flip = false}, .{ .index = 29, .flip = false}, .{ .index = 31, .flip = false}, .{ .index = 30, .flip = false}, .{ .index = 29, .flip = false}, .{ .index = 29, .flip = false}, } },
Node { .strategy = Strategy.fromString(".0.000. 0...... .0..03. 0.01.0. .4..2.. ..5....") }, // 4265614
Node { .strategy = Strategy.fromString("00.0.00 ....0.. 00..... ...130. 22..3.5 ..4...5") }, // 4265614
Node { .red = .{ .child = 3, .transition = .{ .index = 32, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 35, .flip = false}, .{ .index = 35, .flip = false}, .{ .index = 33, .flip = false}, .{ .index = 33, .flip = false}, .{ .index = 34, .flip = false}, .{ .index = 33, .flip = false}, .{ .index = 33, .flip = false}, } },
Node { .strategy = Strategy.fromString("5343.00 2112... 556..40 221..1. 556...0 ..6...0") }, // 426561444
Node { .strategy = Strategy.fromString("4402300 10..0.. 445.020 110.0.. 445...3 ..5...1") }, // 426561444
Node { .strategy = Strategy.fromString("23.2.11 ....... 11...31 ......1 23..0.1 ..0...1") }, // 426561444
Node { .red = .{ .child = 2, .transition = .{ .index = 37, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 38, .flip = false}, .{ .index = 38, .flip = false}, .{ .index = 39, .flip = false}, .{ .index = 38, .flip = false}, .{ .index = 39, .flip = false}, .{ .index = 38, .flip = false}, .{ .index = 38, .flip = false}, } },
Node { .strategy = Strategy.fromString(".000.00 ..3.... .420.00 .0215.. 3..1430 3......") }, // 4623253
Node { .strategy = Strategy.fromString(".000001 ......1 ..5..01 .010.74 2...326 ......6") }, // 4623253
Node { .red = .{ .child = 1, .transition = .{ .index = 41, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 42, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 3, .transition = .{ .index = 43, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 46, .flip = false}, .{ .index = 45, .flip = false}, .{ .index = 44, .flip = false}, .{ .index = 47, .flip = false}, .{ .index = 46, .flip = false}, .{ .index = 45, .flip = false}, .{ .index = 46, .flip = false}, } },
Node { .strategy = Strategy.fromString(".477000 .432... ..02500 ..0.... ....166 5......") }, // 462324224
Node { .strategy = Strategy.fromString(".2.3.21 ...3... 5..0011 ..0.... 4.6.024 1...5..") }, // 462324224
Node { .strategy = Strategy.fromString("1235111 ..00... 3..5111 3.0.... 6...402 3...4..") }, // 462324224
Node { .red = .{ .child = 5, .transition = .{ .index = 48, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 51, .flip = false}, .{ .index = 51, .flip = false}, .{ .index = 49, .flip = false}, .{ .index = 50, .flip = false}, .{ .index = 51, .flip = false}, .{ .index = 49, .flip = false}, .{ .index = 51, .flip = false}, } },
Node { .strategy = Strategy.fromString("02.3032 ..21.1. 0...002 4.0.41. 6...7.2 4...5..") }, // 46232422446
Node { .strategy = Strategy.fromString("23.3100 ..0.0.. .....00 2.0.1.. 4.6.5.0 2...1..") }, // 46232422446
Node { .strategy = Strategy.fromString("02.5000 ..01... 3...200 1.0.1.. 6...7.3 6...4..") }, // 46232422446
Node { .red = .{ .child = 2, .transition = .{ .index = 53, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 56, .flip = false}, .{ .index = 57, .flip = false}, .{ .index = 56, .flip = false}, .{ .index = 54, .flip = false}, .{ .index = 56, .flip = false}, .{ .index = 55, .flip = false}, .{ .index = 55, .flip = false}, } },
Node { .strategy = Strategy.fromString("03.6010 ..30... 0.10300 .0.4... 7....53 2...7..") }, // 4623233
Node { .strategy = Strategy.fromString("053.000 .210... 0.1.000 .0.0... 0...034 6.....4") }, // 4623233
Node { .strategy = Strategy.fromString("000.000 ...0... 1.2.200 10.04.. 6...513 4...5..") }, // 4623233
Node { .red = .{ .child = 3, .transition = .{ .index = 24, .flip = false }, }, },
Node { .red = .{ .child = 3, .transition = .{ .index = 59, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 60, .flip = false}, .{ .index = 61, .flip = false}, .{ .index = 60, .flip = false}, .{ .index = 66, .flip = false}, .{ .index = 60, .flip = false}, .{ .index = 62, .flip = true}, .{ .index = 60, .flip = false}, } },
Node { .strategy = Strategy.fromString("00.0.00 ..0.... ......0 .021... 5.3...2 5...4..") }, // 4623264
Node { .strategy = Strategy.fromString(".000.0. ......0 .31.... .110.40 ..2.... ....5.3") }, // 4623264
Node { .red = .{ .child = 1, .transition = .{ .index = 63, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 64, .flip = false}, .{ .index = 64, .flip = false}, .{ .index = 64, .flip = false}, .{ .index = 65, .flip = false}, .{ .index = 64, .flip = false}, .{ .index = 65, .flip = false}, .{ .index = 64, .flip = false}, } },
Node { .strategy = Strategy.fromString("02.0.00 ....0.. 0...... ...021. 2...3.5 ..4...5") }, // 426562422
Node { .strategy = Strategy.fromString(".2.000. 0...... ...102. 0.21.3. ....0.. 4.5....") }, // 426562422
Node { .red = .{ .child = 3, .transition = .{ .index = 67, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 70, .flip = false}, .{ .index = 71, .flip = false}, .{ .index = 69, .flip = false}, .{ .index = 71, .flip = false}, .{ .index = 70, .flip = false}, .{ .index = 68, .flip = false}, .{ .index = 70, .flip = false}, } },
Node { .strategy = Strategy.fromString("1323.4. .1....0 120.... 151...0 6.1.0.. ....7.6") }, // 462326444
Node { .strategy = Strategy.fromString("1.02.25 4.1..30 100..3. 4.0.630 4...0.5 ....6.5") }, // 462326444
Node { .strategy = Strategy.fromString("0004.0. ...20.0 ..0.... .0..260 2.3.2.. 1...5.4") }, // 462326444
Node { .strategy = Strategy.fromString("11.2.11 ....... 23....1 1...... 2.0...3 1...0..") }, // 462326444
Node { .red = .{ .child = 2, .transition = .{ .index = 73, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 74, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 1, .transition = .{ .index = 75, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 76, .flip = false}, .{ .index = 77, .flip = false}, .{ .index = 89, .flip = false}, .{ .index = 81, .flip = false}, .{ .index = 76, .flip = false}, .{ .index = 76, .flip = false}, .{ .index = 76, .flip = false}, } },
Node { .strategy = Strategy.fromString("0000000 ....... ..1..02 .010.61 2.1.434 ......5") }, // 4621352
Node { .red = .{ .child = 3, .transition = .{ .index = 78, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 79, .flip = false}, .{ .index = 80, .flip = false}, .{ .index = 79, .flip = false}, .{ .index = 79, .flip = false}, .{ .index = 80, .flip = false}, .{ .index = 79, .flip = false}, .{ .index = 80, .flip = false}, } },
Node { .strategy = Strategy.fromString("0501340 .2.004. 0202.23 ...0041 6.3..47 ......7") }, // 462135224
Node { .strategy = Strategy.fromString("....... ....... .....0. ..0..1. ..0..1. .......") }, // 462135224
Node { .red = .{ .child = 1, .transition = .{ .index = 82, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 83, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 3, .transition = .{ .index = 84, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 86, .flip = false}, .{ .index = 87, .flip = false}, .{ .index = 87, .flip = false}, .{ .index = 85, .flip = false}, .{ .index = 86, .flip = false}, .{ .index = 86, .flip = false}, .{ .index = 88, .flip = false}, } },
Node { .strategy = Strategy.fromString("0545406 .2030.1 2...606 3...1.. 4...700 .......") }, // 46213524224
Node { .strategy = Strategy.fromString("2615503 ..2.0.1 2.43406 2...4.. 7...001 .......") }, // 46213524224
Node { .strategy = Strategy.fromString("0434511 ..021.. 0..2511 0...5.. 6...713 .......") }, // 46213524224
Node { .strategy = Strategy.fromString("0426000 ..01... 2..6000 1...... 7...534 .......") }, // 46213524224
Node { .red = .{ .child = 1, .transition = .{ .index = 90, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 91, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 92, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 96, .flip = false}, .{ .index = 96, .flip = false}, .{ .index = 96, .flip = false}, .{ .index = 93, .flip = false}, .{ .index = 94, .flip = false}, .{ .index = 95, .flip = false}, .{ .index = 95, .flip = false}, } },
Node { .strategy = Strategy.fromString("20.1000 ..03... 2..1.00 ...0.2. 4...521 .......") }, // 46213523223
Node { .strategy = Strategy.fromString("003.0.0 ..304.. 0.2.400 ....05. 2....10 .......") }, // 46213523223
Node { .strategy = Strategy.fromString("4564.70 15120.. 4.14.00 3..027. 3..0.76 .......") }, // 46213523223
Node { .strategy = Strategy.fromString("043.104 ...0... 3.3.112 0..02.. 6...514 .......") }, // 46213523223
Node { .red = .{ .child = 4, .transition = .{ .index = 98, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 74, .flip = true}, } },
Node { .red = .{ .child = 5, .transition = .{ .index = 100, .flip = true }, }, },
Node { .yellow = .{ .{ .index = 101, .flip = false}, .{ .index = 145, .flip = false}, .{ .index = 128, .flip = false}, .{ .index = 243, .flip = false}, .{ .index = 275, .flip = false}, .{ .index = 97, .flip = true}, .{ .index = 240, .flip = true}, } },
Node { .red = .{ .child = 1, .transition = .{ .index = 102, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 104, .flip = false}, .{ .index = 105, .flip = false}, .{ .index = 103, .flip = false}, .{ .index = 104, .flip = false}, .{ .index = 104, .flip = false}, .{ .index = 121, .flip = false}, .{ .index = 122, .flip = false}, } },
Node { .strategy = Strategy.fromString(".654510 ..040.. ..0..00 .010... ..21366 .......") }, // 45212
Node { .strategy = Strategy.fromString("3022500 ...21.. 3.42500 30011.. 3..6500 ..4....") }, // 45212
Node { .red = .{ .child = 3, .transition = .{ .index = 106, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 107, .flip = false}, .{ .index = 108, .flip = false}, .{ .index = 108, .flip = false}, .{ .index = 109, .flip = false}, .{ .index = 108, .flip = false}, .{ .index = 108, .flip = false}, .{ .index = 107, .flip = false}, } },
Node { .strategy = Strategy.fromString("0002000 ...0... 020..35 ...0041 5.3..46 ..3..45") }, // 4521224
Node { .strategy = Strategy.fromString("00.0000 ....... 04..530 ...123. 3.0..60 ..7..4.") }, // 4521224
Node { .red = .{ .child = 0, .transition = .{ .index = 110, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 112, .flip = false}, .{ .index = 112, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 113, .flip = false}, .{ .index = 111, .flip = false}, .{ .index = 112, .flip = false}, .{ .index = 112, .flip = false}, } },
Node { .strategy = Strategy.fromString(".0.0052 0....11 .0.3056 4....11 ....456 ..7..52") }, // 452122441
Node { .strategy = Strategy.fromString("00.4.00 ...10.. 54.0300 ....0.. ....322 ..3....") }, // 452122441
Node { .red = .{ .child = 1, .transition = .{ .index = 114, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 116, .flip = false}, .{ .index = 116, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 117, .flip = false}, .{ .index = 115, .flip = false}, .{ .index = 115, .flip = false}, .{ .index = 115, .flip = false}, } },
Node { .strategy = Strategy.fromString(".0..020 0....0. ....1.0 2...13. ....400 ..5....") }, // 45212244142
Node { .strategy = Strategy.fromString(".3..023 0....11 ....056 4....11 ....256 ..7..50") }, // 45212244142
Node { .red = .{ .child = 3, .transition = .{ .index = 118, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 119, .flip = false}, .{ .index = 119, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 120, .flip = false}, .{ .index = 120, .flip = false}, .{ .index = 119, .flip = false}, } },
Node { .strategy = Strategy.fromString(".4..101 0...2.2 ....505 4...1.3 ....100 ..6....") }, // 4521224414244
Node { .strategy = Strategy.fromString(".3..024 0....11 ....044 5....11 ....344 ..6..20") }, // 4521224414244
Node { .red = .{ .child = 2, .transition = .{ .index = 75, .flip = false }, }, },
Node { .red = .{ .child = 2, .transition = .{ .index = 123, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 127, .flip = false}, .{ .index = 124, .flip = false}, .{ .index = 126, .flip = false}, .{ .index = 125, .flip = false}, .{ .index = 127, .flip = false}, .{ .index = 127, .flip = false}, .{ .index = 126, .flip = false}, } },
Node { .strategy = Strategy.fromString("1103010 ...0... 031..56 ...2450 6.10.57 .....5.") }, // 4521273
Node { .strategy = Strategy.fromString("0032000 ..02... 1..5000 10.1... 6...403 .......") }, // 4521273
Node { .strategy = Strategy.fromString("000.000 ...0... 1.3.100 20102.. 5.1.403 .......") }, // 4521273
Node { .strategy = Strategy.fromString(".000000 ....... ..1..01 .010.54 2.1.324 .....5.") }, // 4521273
Node { .red = .{ .child = 1, .transition = .{ .index = 129, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 130, .flip = false}, .{ .index = 137, .flip = false}, .{ .index = 132, .flip = false}, .{ .index = 132, .flip = false}, .{ .index = 131, .flip = false}, .{ .index = 36, .flip = false}, .{ .index = 133, .flip = true}, } },
Node { .strategy = Strategy.fromString(".665500 ..1...4 ..0.001 .021..4 ..21341 .......") }, // 45232
Node { .strategy = Strategy.fromString("0001000 ...1... 0.16300 .0011.. 2..6.04 5.....4") }, // 45232
Node { .strategy = Strategy.fromString("0041200 ..121.. 2.41200 30123.. 5...600 5......") }, // 45232
Node { .red = .{ .child = 4, .transition = .{ .index = 134, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 135, .flip = false}, .{ .index = 135, .flip = false}, .{ .index = 135, .flip = false}, .{ .index = 136, .flip = false}, .{ .index = 135, .flip = false}, .{ .index = 136, .flip = false}, .{ .index = 135, .flip = false}, } },
Node { .strategy = Strategy.fromString(".0.015. 5.3..3. .0..5.. 5630203 3634..2 .6....1") }, // 4365615
Node { .strategy = Strategy.fromString(".0.260. 0..3... .01122. 2731.0. .541... .7....3") }, // 4365615
Node { .red = .{ .child = 3, .transition = .{ .index = 138, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 139, .flip = false}, .{ .index = 139, .flip = false}, .{ .index = 140, .flip = false}, .{ .index = 141, .flip = false}, .{ .index = 139, .flip = false}, .{ .index = 139, .flip = false}, .{ .index = 139, .flip = false}, } },
Node { .strategy = Strategy.fromString(".000.0. ......0 .20..0. ...04.0 ..1..3. .....32") }, // 4523224
Node { .strategy = Strategy.fromString("0001002 ...0..0 010.547 ...0063 4.2..67 .....67") }, // 4523224
Node { .red = .{ .child = 3, .transition = .{ .index = 142, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 143, .flip = false}, .{ .index = 143, .flip = false}, .{ .index = 144, .flip = false}, .{ .index = 143, .flip = false}, .{ .index = 143, .flip = false}, .{ .index = 143, .flip = false}, .{ .index = 143, .flip = false}, } },
Node { .strategy = Strategy.fromString("00.1032 .....32 44...36 0....32 4.7..66 0....55") }, // 452322444
Node { .strategy = Strategy.fromString("0403..0 .4..... 040.2.0 ..0.12. 5.1.213 .....2.") }, // 452322444
Node { .red = .{ .child = 0, .transition = .{ .index = 146, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 147, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 148, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 149, .flip = false}, .{ .index = 210, .flip = false}, .{ .index = 154, .flip = false}, .{ .index = 206, .flip = false}, .{ .index = 202, .flip = false}, .{ .index = 150, .flip = false}, .{ .index = 149, .flip = false}, } },
Node { .strategy = Strategy.fromString("2140201 3...... 5706201 5201... 5...304 .......") }, // 4522133
Node { .red = .{ .child = 2, .transition = .{ .index = 151, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 153, .flip = false}, .{ .index = 152, .flip = false}, .{ .index = 153, .flip = false}, .{ .index = 152, .flip = false}, .{ .index = 153, .flip = false}, .{ .index = 153, .flip = false}, .{ .index = 153, .flip = false}, } },
Node { .strategy = Strategy.fromString("1551000 .3.4... 6102..0 62.1.0. 6..27.0 .......") }, // 452213363
Node { .strategy = Strategy.fromString("0053000 ...6... 0734000 .1.0... 5...642 .......") }, // 452213363
Node { .red = .{ .child = 4, .transition = .{ .index = 155, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 157, .flip = false}, .{ .index = 170, .flip = false}, .{ .index = 187, .flip = false}, .{ .index = 158, .flip = false}, .{ .index = 157, .flip = false}, .{ .index = 156, .flip = false}, .{ .index = 183, .flip = false}, } },
Node { .strategy = Strategy.fromString("0211.0. ..1...0 035.... .3.0.40 2..0..4 ......1") }, // 452213335
Node { .strategy = Strategy.fromString("604.1.0 ..2.5.. 40211.2 ...0512 4....03 ......3") }, // 452213335
Node { .red = .{ .child = 3, .transition = .{ .index = 159, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 160, .flip = false}, .{ .index = 161, .flip = false}, .{ .index = 165, .flip = false}, .{ .index = 160, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 160, .flip = false}, .{ .index = 160, .flip = false}, } },
Node { .strategy = Strategy.fromString("00501.0 ..2.0.. 0.01..0 ....30. 5.....4 ......3") }, // 45221333544
Node { .red = .{ .child = 1, .transition = .{ .index = 162, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 164, .flip = false}, .{ .index = 164, .flip = false}, .{ .index = 163, .flip = false}, .{ .index = 164, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 164, .flip = false}, .{ .index = 164, .flip = false}, } },
Node { .strategy = Strategy.fromString("14.40.0 13.1... 7.01..0 3...60. 4.....2 .....52") }, // 4522133354422
Node { .strategy = Strategy.fromString("....... ..2.... ..01... .....00 .....34 ......4") }, // 4522133354422
Node { .red = .{ .child = 2, .transition = .{ .index = 166, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 169, .flip = false}, .{ .index = 169, .flip = false}, .{ .index = 168, .flip = false}, .{ .index = 167, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 168, .flip = false}, .{ .index = 168, .flip = false}, } },
Node { .strategy = Strategy.fromString("0024.00 ...0... 0.....3 ....531 2....63 .....41") }, // 4522133354433
Node { .strategy = Strategy.fromString("0.3200. ...2... 0..0.5. ....40. 1...... .....53") }, // 4522133354433
Node { .strategy = Strategy.fromString("0534.40 .2.0.2. 0.....1 ....621 3....71 .....41") }, // 4522133354433
Node { .red = .{ .child = 1, .transition = .{ .index = 171, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 172, .flip = false}, .{ .index = 172, .flip = false}, .{ .index = 175, .flip = false}, .{ .index = 174, .flip = false}, .{ .index = 172, .flip = false}, .{ .index = 173, .flip = false}, .{ .index = 172, .flip = false}, } },
Node { .strategy = Strategy.fromString("676.4.0 .22.4.. 6.111.3 ...0413 6....05 ......3") }, // 45221333522
Node { .strategy = Strategy.fromString("355.322 .1100.. 3.5.0.0 ...12.. 3....44 .......") }, // 45221333522
Node { .red = .{ .child = 3, .transition = .{ .index = 162, .flip = false }, }, },
Node { .red = .{ .child = 2, .transition = .{ .index = 176, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 177, .flip = false}, .{ .index = 179, .flip = false}, .{ .index = 178, .flip = false}, .{ .index = 177, .flip = false}, .{ .index = 178, .flip = false}, .{ .index = 177, .flip = false}, .{ .index = 177, .flip = false}, } },
Node { .strategy = Strategy.fromString("0225000 .1.0... 0..5000 ...067. 4....03 .....74") }, // 4522133352233
Node { .strategy = Strategy.fromString("153.311 .1.00.. 4...0.0 ...12.. 4....45 .......") }, // 4522133352233
Node { .red = .{ .child = 1, .transition = .{ .index = 180, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 181, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 182, .flip = false}, .{ .index = 182, .flip = false}, .{ .index = 181, .flip = false}, .{ .index = 181, .flip = false}, .{ .index = 182, .flip = false}, } },
Node { .strategy = Strategy.fromString("0.3.000 ....... 3...030 1...045 3....42 .....45") }, // 452213335223322
Node { .strategy = Strategy.fromString("1.30200 ....2.. 3...242 1...005 6....75 .....45") }, // 452213335223322
Node { .red = .{ .child = 2, .transition = .{ .index = 184, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 186, .flip = false}, .{ .index = 186, .flip = false}, .{ .index = 186, .flip = false}, .{ .index = 185, .flip = false}, .{ .index = 186, .flip = false}, .{ .index = 185, .flip = false}, .{ .index = 186, .flip = false}, } },
Node { .strategy = Strategy.fromString("0002300 ....0.. 0..0..0 .5.0.1. 3..0..4 .......") }, // 45221333573
Node { .strategy = Strategy.fromString("034.000 .1..... 00..000 ...0... 3....22 .....1.") }, // 45221333573
Node { .red = .{ .child = 2, .transition = .{ .index = 188, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 192, .flip = false}, .{ .index = 201, .flip = false}, .{ .index = 196, .flip = false}, .{ .index = 191, .flip = false}, .{ .index = 189, .flip = false}, .{ .index = 190, .flip = false}, .{ .index = 189, .flip = false}, } },
Node { .strategy = Strategy.fromString("0104111 ...1... 01..2.2 ...15.3 0....61 .....4.") }, // 45221333533
Node { .strategy = Strategy.fromString("004.0.0 ....... 40..0.2 1...122 4....02 ......3") }, // 45221333533
Node { .red = .{ .child = 3, .transition = .{ .index = 166, .flip = false }, }, },
Node { .red = .{ .child = 6, .transition = .{ .index = 193, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 195, .flip = false}, .{ .index = 195, .flip = false}, .{ .index = 195, .flip = false}, .{ .index = 194, .flip = false}, .{ .index = 195, .flip = false}, .{ .index = 194, .flip = false}, .{ .index = 195, .flip = false}, } },
Node { .strategy = Strategy.fromString("1144..0 ...2... 1.....3 ...0610 ...0.73 .....5.") }, // 4522133353317
Node { .strategy = Strategy.fromString("0443100 .3.0... 00..0.2 ...15.2 .....62 .....6.") }, // 4522133353317
Node { .red = .{ .child = 6, .transition = .{ .index = 197, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 200, .flip = false}, .{ .index = 199, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 200, .flip = false}, .{ .index = 198, .flip = false}, .{ .index = 198, .flip = false}, .{ .index = 200, .flip = false}, } },
Node { .strategy = Strategy.fromString("00..0.0 ....... 10..0.2 1...122 4....03 .......") }, // 4522133353337
Node { .strategy = Strategy.fromString("03.5001 .2.0... 00..0.4 ...16.4 3....74 .....5.") }, // 4522133353337
Node { .strategy = Strategy.fromString("00.5600 ...02.. 00..113 ...0452 6....71 .....7.") }, // 4522133353337
Node { .red = .{ .child = 1, .transition = .{ .index = 176, .flip = false }, }, },
Node { .red = .{ .child = 2, .transition = .{ .index = 203, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 205, .flip = false}, .{ .index = 204, .flip = false}, .{ .index = 205, .flip = false}, .{ .index = 204, .flip = false}, .{ .index = 205, .flip = false}, .{ .index = 205, .flip = false}, .{ .index = 205, .flip = false}, } },
Node { .strategy = Strategy.fromString("0032..0 ...2... 0102..0 4..1.0. 4..2..0 .....3.") }, // 452213353
Node { .strategy = Strategy.fromString("030.200 ....... 031..00 .0.0... 3....21 .......") }, // 452213353
Node { .red = .{ .child = 3, .transition = .{ .index = 207, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 208, .flip = false}, .{ .index = 208, .flip = false}, .{ .index = 209, .flip = false}, .{ .index = 208, .flip = false}, .{ .index = 208, .flip = false}, .{ .index = 208, .flip = false}, .{ .index = 208, .flip = false}, } },
Node { .strategy = Strategy.fromString("5533020 44...2. 5603..0 440..2. 5...2.1 .....2.") }, // 452213344
Node { .red = .{ .child = 4, .transition = .{ .index = 159, .flip = false }, }, },
Node { .red = .{ .child = 1, .transition = .{ .index = 211, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 225, .flip = false}, .{ .index = 212, .flip = false}, .{ .index = 229, .flip = false}, .{ .index = 230, .flip = false}, .{ .index = 216, .flip = false}, .{ .index = 221, .flip = false}, .{ .index = 235, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 213, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 215, .flip = false}, .{ .index = 215, .flip = false}, .{ .index = 214, .flip = false}, .{ .index = 215, .flip = false}, .{ .index = 215, .flip = false}, .{ .index = 215, .flip = false}, .{ .index = 215, .flip = false}, } },
Node { .strategy = Strategy.fromString("0451000 ..32... 0...110 ...012. 4...065 .....62") }, // 45221332223
Node { .strategy = Strategy.fromString("04410.0 ...3... 0.030.0 7..1.0. 6..32.5 .....6.") }, // 45221332223
Node { .red = .{ .child = 2, .transition = .{ .index = 217, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 220, .flip = false}, .{ .index = 220, .flip = false}, .{ .index = 218, .flip = false}, .{ .index = 218, .flip = false}, .{ .index = 219, .flip = false}, .{ .index = 220, .flip = false}, .{ .index = 220, .flip = false}, } },
Node { .strategy = Strategy.fromString("1031000 4.30... 5.6.1.0 5..020. 5....70 .....4.") }, // 45221332253
Node { .strategy = Strategy.fromString("0033000 ..00... 0.5..00 ...02.. 1....60 .....4.") }, // 45221332253
Node { .strategy = Strategy.fromString("0213..0 ...3... 0.03..0 4..3.0. 4..3..2 .....1.") }, // 45221332253
Node { .red = .{ .child = 4, .transition = .{ .index = 222, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 223, .flip = false}, .{ .index = 223, .flip = false}, .{ .index = 223, .flip = false}, .{ .index = 223, .flip = false}, .{ .index = 223, .flip = false}, .{ .index = 224, .flip = false}, .{ .index = 224, .flip = false}, } },
Node { .strategy = Strategy.fromString("4400..0 .4..3.. 6.13..3 ...0.23 6..0..5 ......5") }, // 45221332265
Node { .strategy = Strategy.fromString("553.242 .1100.. 5.3.0.0 ..312.. 5....44 .......") }, // 45221332265
Node { .red = .{ .child = 2, .transition = .{ .index = 226, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 227, .flip = false}, .{ .index = 228, .flip = false}, .{ .index = 227, .flip = false}, .{ .index = 228, .flip = false}, .{ .index = 228, .flip = false}, .{ .index = 228, .flip = false}, .{ .index = 228, .flip = false}, } },
Node { .strategy = Strategy.fromString("4054000 ..30... 4.3.110 ...012. ....065 .....62") }, // 45221332213
Node { .strategy = Strategy.fromString(".4400.0 .2..... 3.050.0 7..1.0. ...53.3 .....6.") }, // 45221332213
Node { .red = .{ .child = 4, .transition = .{ .index = 171, .flip = false }, }, },
Node { .red = .{ .child = 3, .transition = .{ .index = 231, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 233, .flip = false}, .{ .index = 233, .flip = false}, .{ .index = 234, .flip = false}, .{ .index = 232, .flip = false}, .{ .index = 232, .flip = false}, .{ .index = 232, .flip = false}, .{ .index = 233, .flip = false}, } },
Node { .strategy = Strategy.fromString("0565000 .323... 0.61.60 ..0..0. 4...7.0 .....6.") }, // 45221332244
Node { .strategy = Strategy.fromString("0300..0 .3..1.. 0.01..0 .....0. 4...0.2 .....15") }, // 45221332244
Node { .red = .{ .child = 4, .transition = .{ .index = 162, .flip = false }, }, },
Node { .red = .{ .child = 4, .transition = .{ .index = 236, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 239, .flip = false}, .{ .index = 238, .flip = false}, .{ .index = 239, .flip = false}, .{ .index = 237, .flip = false}, .{ .index = 239, .flip = false}, .{ .index = 239, .flip = false}, .{ .index = 238, .flip = false}, } },
Node { .strategy = Strategy.fromString("03.0..0 .3..... 4.04..0 1..0.0. 4.....5 .....2.") }, // 45221332275
Node { .strategy = Strategy.fromString(".6450.2 ..43... ..136.0 2.10... ...0..5 .......") }, // 45221332275
Node { .strategy = Strategy.fromString("433.211 .0002.. 4.5.200 ..502.. 4....16 .......") }, // 45221332275
Node { .red = .{ .child = 4, .transition = .{ .index = 241, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 242, .flip = true}, } },
Node { .red = .{ .child = 1, .transition = .{ .index = 123, .flip = false }, }, },
Node { .red = .{ .child = 3, .transition = .{ .index = 244, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 247, .flip = false}, .{ .index = 272, .flip = false}, .{ .index = 245, .flip = false}, .{ .index = 260, .flip = false}, .{ .index = 246, .flip = false}, .{ .index = 254, .flip = true}, .{ .index = 246, .flip = false}, } },
Node { .strategy = Strategy.fromString("0044100 ..021.. 54.2600 510.3.. 50..600 3......") }, // 45244
Node { .strategy = Strategy.fromString("4102011 ...2... 43.2111 00..... 51..314 0......") }, // 45244
Node { .red = .{ .child = 1, .transition = .{ .index = 248, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 249, .flip = false}, .{ .index = 250, .flip = false}, .{ .index = 249, .flip = false}, .{ .index = 249, .flip = false}, .{ .index = 249, .flip = false}, .{ .index = 249, .flip = false}, .{ .index = 249, .flip = false}, } },
Node { .strategy = Strategy.fromString("0034000 ..02... 4..4000 20..... 5...311 ..3....") }, // 4524412
Node { .red = .{ .child = 3, .transition = .{ .index = 251, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 252, .flip = false}, .{ .index = 253, .flip = false}, .{ .index = 253, .flip = false}, .{ .index = 252, .flip = false}, .{ .index = 253, .flip = false}, .{ .index = 253, .flip = false}, .{ .index = 253, .flip = false}, } },
Node { .strategy = Strategy.fromString("00.1300 ....0.. 00..300 ....24. 1...240 ..3....") }, // 452441224
Node { .strategy = Strategy.fromString("433.200 43.01.. 43..500 4.0.2.. 4...511 ..5....") }, // 452441224
Node { .red = .{ .child = 5, .transition = .{ .index = 255, .flip = true }, }, },
Node { .yellow = .{ .{ .index = 259, .flip = false}, .{ .index = 257, .flip = false}, .{ .index = 259, .flip = false}, .{ .index = 256, .flip = false}, .{ .index = 257, .flip = false}, .{ .index = 258, .flip = false}, .{ .index = 257, .flip = false}, } },
Node { .strategy = Strategy.fromString("0616107 .3040.2 3...107 41..1.. 5...820 ..0....") }, // 4524462
Node { .strategy = Strategy.fromString("1104010 ...0... 35.4010 31..... 6...225 0......") }, // 4524462
Node { .strategy = Strategy.fromString("0005106 ....0.. 0513400 .0..4.. 7...220 1......") }, // 4524462
Node { .strategy = Strategy.fromString("00.0200 ..0.1.. 55.2200 110.4.. 5...430 1.5....") }, // 4524462
Node { .red = .{ .child = 4, .transition = .{ .index = 261, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 264, .flip = false}, .{ .index = 263, .flip = false}, .{ .index = 264, .flip = false}, .{ .index = 262, .flip = false}, .{ .index = 265, .flip = false}, .{ .index = 262, .flip = false}, .{ .index = 263, .flip = false}, } },
Node { .strategy = Strategy.fromString("0006600 ...34.. 000.0.0 ....01. 252...7 2....37") }, // 4524445
Node { .strategy = Strategy.fromString("00461.0 ...21.. 000...0 ....30. 460...5 0....15") }, // 4524445
Node { .strategy = Strategy.fromString("0005400 ...2... 000.0.0 ....00. 415...6 .....36") }, // 4524445
Node { .red = .{ .child = 4, .transition = .{ .index = 266, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 268, .flip = false}, .{ .index = 267, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 267, .flip = false}, .{ .index = 267, .flip = false}, .{ .index = 267, .flip = false}, .{ .index = 267, .flip = false}, } },
Node { .strategy = Strategy.fromString("...0... ...0... ....... ....... ......0 ..1...0") }, // 452444555
Node { .red = .{ .child = 3, .transition = .{ .index = 269, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 271, .flip = false}, .{ .index = 271, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 271, .flip = false}, .{ .index = 270, .flip = false}, .{ .index = 270, .flip = false}, .{ .index = 270, .flip = false}, } },
Node { .strategy = Strategy.fromString(".3.2400 01..... .0...00 010.... .0...33 ..5....") }, // 45244455514
Node { .strategy = Strategy.fromString("12.42.1 ....300 02....1 .....00 54....1 .....50") }, // 45244455514
Node { .red = .{ .child = 0, .transition = .{ .index = 273, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 274, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 207, .flip = false }, }, },
Node { .red = .{ .child = 0, .transition = .{ .index = 276, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 277, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 1, .transition = .{ .index = 278, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 279, .flip = false}, .{ .index = 282, .flip = false}, .{ .index = 287, .flip = false}, .{ .index = 280, .flip = false}, .{ .index = 296, .flip = false}, .{ .index = 281, .flip = false}, .{ .index = 281, .flip = false}, } },
Node { .strategy = Strategy.fromString("03.0022 .....11 3..0.22 100..11 ...2.55 .....44") }, // 4525132
Node { .strategy = Strategy.fromString(".0.1001 ...4... 0..1252 .0.41.. 6....06 ......3") }, // 4525132
Node { .strategy = Strategy.fromString(".100104 ......4 ..3..04 .000.54 3.1..24 .....54") }, // 4525132
Node { .red = .{ .child = 2, .transition = .{ .index = 283, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 285, .flip = false}, .{ .index = 286, .flip = false}, .{ .index = 286, .flip = false}, .{ .index = 284, .flip = false}, .{ .index = 285, .flip = false}, .{ .index = 286, .flip = false}, .{ .index = 284, .flip = false}, } },
Node { .strategy = Strategy.fromString("06350.0 ...0... 030.1.0 ..0.20. 5..1..4 .....6.") }, // 452513223
Node { .strategy = Strategy.fromString("06310.0 .2..... 061.4.0 ..1.40. 0..5..0 .....3.") }, // 452513223
Node { .strategy = Strategy.fromString("100100. ...2..0 233..0. 4..01.0 ...0.5. .....65") }, // 452513223
Node { .red = .{ .child = 1, .transition = .{ .index = 288, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 289, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 290, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 291, .flip = false}, .{ .index = 291, .flip = false}, .{ .index = 291, .flip = false}, .{ .index = 291, .flip = false}, .{ .index = 292, .flip = false}, .{ .index = 291, .flip = false}, .{ .index = 291, .flip = false}, } },
Node { .strategy = Strategy.fromString("030.000 ....... 0.1.200 ....0.. 2....13 .......") }, // 45251323223
Node { .red = .{ .child = 4, .transition = .{ .index = 293, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 295, .flip = false}, .{ .index = 295, .flip = false}, .{ .index = 295, .flip = false}, .{ .index = 295, .flip = false}, .{ .index = 295, .flip = false}, .{ .index = 294, .flip = false}, .{ .index = 295, .flip = false}, } },
Node { .strategy = Strategy.fromString(".066500 ..324.. .....05 0..6..1 7..0.15 ......3") }, // 4525132322355
Node { .strategy = Strategy.fromString(".604601 ...33.. .....51 0..4... 7..1.25 .......") }, // 4525132322355
Node { .red = .{ .child = 4, .transition = .{ .index = 297, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 298, .flip = false}, .{ .index = 298, .flip = false}, .{ .index = 299, .flip = false}, .{ .index = 298, .flip = false}, .{ .index = 298, .flip = false}, .{ .index = 298, .flip = false}, .{ .index = 298, .flip = false}, } },
Node { .strategy = Strategy.fromString("0000200 ...0... 022..00 .3.0... 4.1..22 .......") }, // 452513255
Node { .red = .{ .child = 1, .transition = .{ .index = 300, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 301, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 293, .flip = false }, }, },
Node { .red = .{ .child = 4, .transition = .{ .index = 303, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 304, .flip = false}, .{ .index = 304, .flip = false}, .{ .index = 310, .flip = false}, .{ .index = 304, .flip = false}, .{ .index = 304, .flip = false}, .{ .index = 305, .flip = false}, .{ .index = 304, .flip = false}, } },
Node { .strategy = Strategy.fromString("....... ....... ....... ....... .0..... ..0..1.") }, // 415
Node { .red = .{ .child = 4, .transition = .{ .index = 306, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 307, .flip = false}, .{ .index = 309, .flip = false}, .{ .index = 307, .flip = false}, .{ .index = 309, .flip = false}, .{ .index = 308, .flip = false}, .{ .index = 309, .flip = false}, .{ .index = 308, .flip = false}, } },
Node { .strategy = Strategy.fromString("0005000 ...2... 003..10 ..4001. 504..63 ..4...1") }, // 41565
Node { .strategy = Strategy.fromString("...000. 4...... .0..60. 4.632.5 .500.4. .17....") }, // 41565
Node { .strategy = Strategy.fromString("1056401 ..20... 105..73 .621023 415..73 ..5...3") }, // 41565
Node { .red = .{ .child = 5, .transition = .{ .index = 241, .flip = false }, }, },
Node { .red = .{ .child = 3, .transition = .{ .index = 312, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 467, .flip = false}, .{ .index = 454, .flip = false}, .{ .index = 477, .flip = false}, .{ .index = 313, .flip = false}, .{ .index = 477, .flip = true}, .{ .index = 454, .flip = true}, .{ .index = 467, .flip = true}, } },
Node { .red = .{ .child = 3, .transition = .{ .index = 314, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 356, .flip = false}, .{ .index = 397, .flip = false}, .{ .index = 315, .flip = false}, .{ .index = 424, .flip = false}, .{ .index = 315, .flip = true}, .{ .index = 397, .flip = true}, .{ .index = 356, .flip = true}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 316, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 317, .flip = false}, .{ .index = 317, .flip = false}, .{ .index = 319, .flip = false}, .{ .index = 317, .flip = false}, .{ .index = 317, .flip = false}, .{ .index = 317, .flip = false}, .{ .index = 318, .flip = false}, } },
Node { .strategy = Strategy.fromString("0003..0 ....00. 102...0 100.00. 14....0 14..23.") }, // 4444433
Node { .strategy = Strategy.fromString("0.04000 ....... 0.1.000 .00.... 2...301 23.....") }, // 4444433
Node { .red = .{ .child = 2, .transition = .{ .index = 320, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 322, .flip = false}, .{ .index = 322, .flip = false}, .{ .index = 323, .flip = false}, .{ .index = 322, .flip = false}, .{ .index = 321, .flip = false}, .{ .index = 325, .flip = true}, .{ .index = 324, .flip = true}, } },
Node { .strategy = Strategy.fromString("02120.0 ....... 0...0.0 ....01. 11..0.3 ......3") }, // 444443333
Node { .strategy = Strategy.fromString("0054..0 ..1..0. 00....0 .....3. 44...32 ....602") }, // 444443333
Node { .strategy = Strategy.fromString("0053.4. .....10 00...0. ....020 44...0. ....601") }, // 444443333
Node { .red = .{ .child = 1, .transition = .{ .index = 269, .flip = false }, }, },
Node { .red = .{ .child = 4, .transition = .{ .index = 326, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 348, .flip = false}, .{ .index = 352, .flip = false}, .{ .index = 327, .flip = false}, .{ .index = 328, .flip = false}, .{ .index = 328, .flip = false}, .{ .index = 328, .flip = false}, .{ .index = 329, .flip = true}, } },
Node { .strategy = Strategy.fromString("0335400 .10.... 0.....0 .23.... 621..44 6....0.") }, // 44444555525
Node { .strategy = Strategy.fromString("0..3310 .00..1. 0....40 .00..45 0....42 ..2..40") }, // 44444555525
Node { .red = .{ .child = 5, .transition = .{ .index = 330, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 331, .flip = false}, .{ .index = 344, .flip = false}, .{ .index = 331, .flip = false}, .{ .index = 331, .flip = false}, .{ .index = 331, .flip = false}, .{ .index = 332, .flip = false}, .{ .index = 331, .flip = false}, } },
Node { .strategy = Strategy.fromString("0024.20 ....00. 00...61 ....001 3.....5 ....3.1") }, // 4444433336316
Node { .red = .{ .child = 3, .transition = .{ .index = 333, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 336, .flip = false}, .{ .index = 340, .flip = false}, .{ .index = 335, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 335, .flip = false}, .{ .index = 334, .flip = false}, .{ .index = 335, .flip = false}, } },
Node { .strategy = Strategy.fromString("001..10 .....0. 00....0 ....... 2.....0 ....2..") }, // 444443333631664
Node { .strategy = Strategy.fromString("001.10. ....1.. 20..30. 2...4.0 5...4.. ....4.3") }, // 444443333631664
Node { .red = .{ .child = 0, .transition = .{ .index = 337, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 339, .flip = false}, .{ .index = 339, .flip = false}, .{ .index = 339, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 339, .flip = false}, .{ .index = 338, .flip = false}, .{ .index = 339, .flip = false}, } },
Node { .strategy = Strategy.fromString("0.2..00 .....0. 1.....0 ....... ......1 ....2..") }, // 44444333363166411
Node { .strategy = Strategy.fromString("0.3.10. ....1.. 1...10. ....2.0 ....2.. ....2.3") }, // 44444333363166411
Node { .red = .{ .child = 1, .transition = .{ .index = 341, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 342, .flip = false}, .{ .index = 342, .flip = false}, .{ .index = 342, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 342, .flip = false}, .{ .index = 343, .flip = false}, .{ .index = 342, .flip = false}, } },
Node { .strategy = Strategy.fromString("034.200 .1..2.. 11..52. 0...3.0 6...5.. ....3.4") }, // 44444333363166422
Node { .strategy = Strategy.fromString("011...0 .0..02. 30....0 .1..0.. 3.....2 ....2..") }, // 44444333363166422
Node { .red = .{ .child = 1, .transition = .{ .index = 345, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 346, .flip = false}, .{ .index = 347, .flip = false}, .{ .index = 347, .flip = false}, .{ .index = 347, .flip = false}, .{ .index = 346, .flip = false}, .{ .index = 346, .flip = false}, .{ .index = 347, .flip = false}, } },
Node { .strategy = Strategy.fromString("0233.10 ....00. 50...71 55..004 2.....6 ....2.6") }, // 444443333631622
Node { .strategy = Strategy.fromString("0443130 .0..00. 50...71 51..111 2.....6 ....7.6") }, // 444443333631622
Node { .red = .{ .child = 1, .transition = .{ .index = 349, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 350, .flip = false}, .{ .index = 350, .flip = false}, .{ .index = 351, .flip = false}, .{ .index = 350, .flip = false}, .{ .index = 350, .flip = false}, .{ .index = 350, .flip = false}, .{ .index = 351, .flip = false}, } },
Node { .strategy = Strategy.fromString("0..5402 .00..01 0....62 .50..13 4....63 ..2..60") }, // 4444455552512
Node { .strategy = Strategy.fromString("0102132 .00.... 0....02 .00.... 4.5..22 ..5....") }, // 4444455552512
Node { .red = .{ .child = 1, .transition = .{ .index = 353, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 355, .flip = false}, .{ .index = 354, .flip = false}, .{ .index = 355, .flip = false}, .{ .index = 354, .flip = false}, .{ .index = 354, .flip = false}, .{ .index = 354, .flip = false}, .{ .index = 355, .flip = false}, } },
Node { .strategy = Strategy.fromString("02.4410 .00..1. 06...50 ..0..5. 0....53 ..3..51") }, // 4444455552522
Node { .strategy = Strategy.fromString("0225300 .20.... 16...00 1.1.... 1.7..55 6.4....") }, // 4444455552522
Node { .red = .{ .child = 4, .transition = .{ .index = 357, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 358, .flip = false}, .{ .index = 358, .flip = false}, .{ .index = 359, .flip = false}, .{ .index = 358, .flip = false}, .{ .index = 358, .flip = false}, .{ .index = 364, .flip = false}, .{ .index = 358, .flip = false}, } },
Node { .strategy = Strategy.fromString("....... ....... ....... ....... ....... ..0..10") }, // 4444415
Node { .red = .{ .child = 2, .transition = .{ .index = 360, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 362, .flip = false}, .{ .index = 362, .flip = false}, .{ .index = 361, .flip = false}, .{ .index = 362, .flip = false}, .{ .index = 363, .flip = false}, .{ .index = 362, .flip = false}, .{ .index = 363, .flip = false}, } },
Node { .strategy = Strategy.fromString("21053.0 ....... 014.2.1 ....010 5...0.2 .....32") }, // 444441533
Node { .strategy = Strategy.fromString("0001000 ....... 021...0 .20.00. 45....0 .5...3.") }, // 444441533
Node { .strategy = Strategy.fromString("0.02000 ....... 0.1.000 .00.... 4...301 .2.....") }, // 444441533
Node { .red = .{ .child = 5, .transition = .{ .index = 365, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 367, .flip = false}, .{ .index = 388, .flip = false}, .{ .index = 367, .flip = false}, .{ .index = 367, .flip = false}, .{ .index = 366, .flip = false}, .{ .index = 368, .flip = false}, .{ .index = 367, .flip = false}, } },
Node { .strategy = Strategy.fromString("100203. ..5..50 104..1. 5...751 440.... .0....6") }, // 444441566
Node { .strategy = Strategy.fromString("0002.00 ....0.. 004..23 ..1.001 405...6 ..5...3") }, // 444441566
Node { .red = .{ .child = 5, .transition = .{ .index = 369, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 370, .flip = false}, .{ .index = 381, .flip = false}, .{ .index = 370, .flip = false}, .{ .index = 370, .flip = false}, .{ .index = 370, .flip = false}, .{ .index = 371, .flip = false}, .{ .index = 370, .flip = false}, } },
Node { .strategy = Strategy.fromString("0015.52 ..1.002 006...7 ..1.3.2 306...2 ..4...2") }, // 44444156666
Node { .red = .{ .child = 1, .transition = .{ .index = 372, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 373, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 2, .transition = .{ .index = 374, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 375, .flip = false}, .{ .index = 375, .flip = false}, .{ .index = 376, .flip = false}, .{ .index = 375, .flip = false}, .{ .index = 375, .flip = false}, .{ .index = 375, .flip = false}, .{ .index = 375, .flip = false}, } },
Node { .strategy = Strategy.fromString("2031140 ....1.. 120...3 .20.5.0 4...5.6 ......6") }, // 444441566666233
Node { .red = .{ .child = 1, .transition = .{ .index = 377, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 379, .flip = false}, .{ .index = 378, .flip = false}, .{ .index = 379, .flip = false}, .{ .index = 380, .flip = false}, .{ .index = 379, .flip = false}, .{ .index = 379, .flip = false}, .{ .index = 378, .flip = false}, } },
Node { .strategy = Strategy.fromString("2462341 .10.0.. 617...2 05..3.0 6...3.5 ......5") }, // 44444156666623332
Node { .strategy = Strategy.fromString("0000.3. ....... 001.... ....4.0 3...2.. ......1") }, // 44444156666623332
Node { .strategy = Strategy.fromString(".341.4. .12.0.. ..2.... .0..5.0 1...5.. ......6") }, // 44444156666623332
Node { .red = .{ .child = 1, .transition = .{ .index = 382, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 383, .flip = false}, .{ .index = 384, .flip = false}, .{ .index = 383, .flip = false}, .{ .index = 383, .flip = false}, .{ .index = 383, .flip = false}, .{ .index = 383, .flip = false}, .{ .index = 383, .flip = false}, } },
Node { .strategy = Strategy.fromString("3505040 ..0..2. 200.6.0 301.1.. 3...6.4 ..6....") }, // 4444415666622
Node { .red = .{ .child = 1, .transition = .{ .index = 385, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 386, .flip = false}, .{ .index = 386, .flip = false}, .{ .index = 387, .flip = false}, .{ .index = 386, .flip = false}, .{ .index = 386, .flip = false}, .{ .index = 387, .flip = false}, .{ .index = 386, .flip = false}, } },
Node { .strategy = Strategy.fromString("04.4250 ..0.00. 0...3.0 ..1.2.. 5.1.2.6 ..3....") }, // 444441566662222
Node { .strategy = Strategy.fromString("55.3230 120.1.. 7...6.0 1.0.6.. 7...6.4 ..4....") }, // 444441566662222
Node { .red = .{ .child = 1, .transition = .{ .index = 389, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 391, .flip = false}, .{ .index = 393, .flip = false}, .{ .index = 391, .flip = false}, .{ .index = 391, .flip = false}, .{ .index = 390, .flip = false}, .{ .index = 392, .flip = false}, .{ .index = 391, .flip = false}, } },
Node { .strategy = Strategy.fromString("15.3410 ....0.. 02..430 .2..01. 5.....6 ..6....") }, // 44444156622
Node { .strategy = Strategy.fromString("0004100 ....0.. 001..23 ..1.003 2.5...3 ..5...3") }, // 44444156622
Node { .red = .{ .child = 5, .transition = .{ .index = 382, .flip = false }, }, },
Node { .red = .{ .child = 5, .transition = .{ .index = 394, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 396, .flip = false}, .{ .index = 395, .flip = false}, .{ .index = 396, .flip = false}, .{ .index = 395, .flip = false}, .{ .index = 396, .flip = false}, .{ .index = 396, .flip = false}, .{ .index = 396, .flip = false}, } },
Node { .strategy = Strategy.fromString("4010101 2.2.1.. 603..01 2.5.1.3 6.7...3 ..5...1") }, // 4444415662226
Node { .strategy = Strategy.fromString("1103042 ....0.. 110..42 ..0.0.2 3.5...2 ..5...2") }, // 4444415662226
Node { .red = .{ .child = 1, .transition = .{ .index = 398, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 399, .flip = false}, .{ .index = 400, .flip = false}, .{ .index = 399, .flip = false}, .{ .index = 399, .flip = false}, .{ .index = 399, .flip = false}, .{ .index = 420, .flip = false}, .{ .index = 399, .flip = false}, } },
Node { .strategy = Strategy.fromString("0013000 ..0.... 24..100 200.1.. 2...503 2.5.1..") }, // 4444422
Node { .red = .{ .child = 1, .transition = .{ .index = 401, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 403, .flip = false}, .{ .index = 404, .flip = false}, .{ .index = 402, .flip = false}, .{ .index = 403, .flip = false}, .{ .index = 402, .flip = false}, .{ .index = 413, .flip = false}, .{ .index = 402, .flip = false}, } },
Node { .strategy = Strategy.fromString("43.3500 100.1.. 4...500 4.0.1.. 4...502 4.2.1..") }, // 444442222
Node { .strategy = Strategy.fromString("0524.00 .00.0.. 0.3..00 ..2.1.. 5.2.104 ..2.3..") }, // 444442222
Node { .red = .{ .child = 5, .transition = .{ .index = 405, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 406, .flip = false}, .{ .index = 406, .flip = false}, .{ .index = 406, .flip = false}, .{ .index = 407, .flip = false}, .{ .index = 408, .flip = false}, .{ .index = 407, .flip = false}, .{ .index = 412, .flip = true}, } },
Node { .strategy = Strategy.fromString(".320000 0.1.... ..4.502 0.4.6.1 ..4.015 3.4.6.2") }, // 44444222226
Node { .strategy = Strategy.fromString("....... ....... ....... ....... ....... ....0..") }, // 44444222226
Node { .red = .{ .child = 4, .transition = .{ .index = 409, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 410, .flip = false}, .{ .index = 410, .flip = false}, .{ .index = 410, .flip = false}, .{ .index = 410, .flip = false}, .{ .index = 411, .flip = false}, .{ .index = 411, .flip = false}, .{ .index = 410, .flip = false}, } },
Node { .strategy = Strategy.fromString("04.14.0 ....... 0...1.0 ....00. 2.2...3 ......3") }, // 4444422222655
Node { .strategy = Strategy.fromString(".3.0000 ....... ....200 0.4.... ..1..22 1.4....") }, // 4444422222655
Node { .red = .{ .child = 4, .transition = .{ .index = 372, .flip = false }, }, },
Node { .red = .{ .child = 5, .transition = .{ .index = 414, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 415, .flip = false}, .{ .index = 415, .flip = false}, .{ .index = 415, .flip = false}, .{ .index = 415, .flip = false}, .{ .index = 415, .flip = false}, .{ .index = 416, .flip = false}, .{ .index = 415, .flip = false}, } },
Node { .strategy = Strategy.fromString("3203021 ....0.. 1.0..21 ..0.001 3.4...1 ..4.5.1") }, // 44444222266
Node { .red = .{ .child = 5, .transition = .{ .index = 417, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 418, .flip = false}, .{ .index = 418, .flip = false}, .{ .index = 418, .flip = false}, .{ .index = 418, .flip = false}, .{ .index = 418, .flip = false}, .{ .index = 419, .flip = false}, .{ .index = 418, .flip = false}, } },
Node { .strategy = Strategy.fromString("3124.45 ..0.000 2.6...5 ..2.1.0 3.2...5 ..2.3.5") }, // 4444422226666
Node { .strategy = Strategy.fromString("45.4212 000.0.. 6...7.2 0.1.3.. 6...3.2 6.5.3..") }, // 4444422226666
Node { .red = .{ .child = 5, .transition = .{ .index = 421, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 422, .flip = false}, .{ .index = 423, .flip = false}, .{ .index = 422, .flip = false}, .{ .index = 422, .flip = false}, .{ .index = 422, .flip = false}, .{ .index = 423, .flip = true}, .{ .index = 422, .flip = false}, } },
Node { .strategy = Strategy.fromString("0012000 ....... 361.100 300.1.. 3...7.2 3.5.4..") }, // 444442266
Node { .red = .{ .child = 1, .transition = .{ .index = 414, .flip = false }, }, },
Node { .red = .{ .child = 2, .transition = .{ .index = 425, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 426, .flip = false}, .{ .index = 432, .flip = false}, .{ .index = 426, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 427, .flip = true}, .{ .index = 426, .flip = false}, .{ .index = 426, .flip = false}, } },
Node { .strategy = Strategy.fromString("....... ....... ....... ....... ....... .0..10.") }, // 4444443
Node { .red = .{ .child = 2, .transition = .{ .index = 428, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 430, .flip = false}, .{ .index = 430, .flip = false}, .{ .index = 429, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 430, .flip = false}, .{ .index = 430, .flip = false}, .{ .index = 431, .flip = false}, } },
Node { .strategy = Strategy.fromString("000.0.0 ....... 005.3.1 ....121 00..0.3 .....43") }, // 444444533
Node { .strategy = Strategy.fromString("003.000 ..3.... 020.2.0 .20.21. 47....1 45...6.") }, // 444444533
Node { .strategy = Strategy.fromString("0.0.000 ....... 0.1.000 .00.... 3...201 32.....") }, // 444444533
Node { .red = .{ .child = 5, .transition = .{ .index = 433, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 434, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, } },
Node { .red = .{ .child = 4, .transition = .{ .index = 435, .flip = true }, }, },
Node { .yellow = .{ .{ .index = 436, .flip = false}, .{ .index = 436, .flip = false}, .{ .index = 444, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 436, .flip = false}, .{ .index = 437, .flip = true}, .{ .index = 436, .flip = false}, } },
Node { .strategy = Strategy.fromString("000..00 ....... 003..42 ..1..02 34..5.0 .......") }, // 44444456233
Node { .red = .{ .child = 2, .transition = .{ .index = 438, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 439, .flip = false}, .{ .index = 439, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 440, .flip = false}, .{ .index = 439, .flip = false}, .{ .index = 439, .flip = false}, } },
Node { .strategy = Strategy.fromString("053.520 .11.2.. 6...200 113.07. 6.....4 6.....4") }, // 4444443265523
Node { .red = .{ .child = 4, .transition = .{ .index = 441, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 443, .flip = false}, .{ .index = 443, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 442, .flip = false}, .{ .index = 443, .flip = false}, .{ .index = 442, .flip = false}, } },
Node { .strategy = Strategy.fromString("052.254 .31...4 63....6 134..01 7.....6 7.....4") }, // 444444326552355
Node { .strategy = Strategy.fromString("054.406 720...1 76....6 024..23 7.....6 7.....3") }, // 444444326552355
Node { .red = .{ .child = 2, .transition = .{ .index = 445, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 447, .flip = false}, .{ .index = 447, .flip = false}, .{ .index = 450, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 446, .flip = false}, .{ .index = 449, .flip = true}, .{ .index = 448, .flip = false}, } },
Node { .strategy = Strategy.fromString("0.3.100 ..3.0.. 0....00 .0..1.. 2....40 0......") }, // 4444445623333
Node { .strategy = Strategy.fromString("135.300 405.0.. .....40 20..32. ....176 ......6") }, // 4444445623333
Node { .strategy = Strategy.fromString("6.4.341 01..02. 6....65 01..325 6...065 1.....5") }, // 4444445623333
Node { .red = .{ .child = 2, .transition = .{ .index = 441, .flip = false }, }, },
Node { .red = .{ .child = 4, .transition = .{ .index = 451, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 452, .flip = false}, .{ .index = 453, .flip = false}, .{ .index = 453, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 0, .flip = false}, .{ .index = 452, .flip = false}, .{ .index = 452, .flip = false}, } },
Node { .strategy = Strategy.fromString("441.150 2...03. 7....55 24..036 7....76 2.....6") }, // 444444562333335
Node { .strategy = Strategy.fromString("503.320 0...154 77....4 10..124 70....4 ......6") }, // 444444562333335
Node { .red = .{ .child = 5, .transition = .{ .index = 455, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 456, .flip = false}, .{ .index = 456, .flip = false}, .{ .index = 254, .flip = false}, .{ .index = 456, .flip = false}, .{ .index = 462, .flip = true}, .{ .index = 456, .flip = false}, .{ .index = 457, .flip = true}, } },
Node { .strategy = Strategy.fromString("....... ...0... ...0... ....... ....... ....1.0") }, // 44426
Node { .red = .{ .child = 3, .transition = .{ .index = 458, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 459, .flip = false}, .{ .index = 460, .flip = false}, .{ .index = 461, .flip = false}, .{ .index = 459, .flip = false}, .{ .index = 460, .flip = false}, .{ .index = 461, .flip = false}, .{ .index = 459, .flip = false}, } },
Node { .strategy = Strategy.fromString("0.65.00 .010... 0.3..00 .03.... 5.0.216 ..1.2.4") }, // 4446214
Node { .strategy = Strategy.fromString("00..000 ..00... 00..400 ..3.1.. 631.514 ..5.2.4") }, // 4446214
Node { .strategy = Strategy.fromString("01...00 ..000.. 04...00 .51.6.. 451.233 ....2..") }, // 4446214
Node { .red = .{ .child = 2, .transition = .{ .index = 463, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 465, .flip = false}, .{ .index = 464, .flip = false}, .{ .index = 466, .flip = false}, .{ .index = 464, .flip = false}, .{ .index = 464, .flip = false}, .{ .index = 465, .flip = false}, .{ .index = 466, .flip = false}, } },
Node { .strategy = Strategy.fromString("0140.00 ..0.... 0221.10 .30..0. 02..5.0 ....5..") }, // 4446233
Node { .strategy = Strategy.fromString("0135100 ..010.. 05.0.00 .23.6.. 47..640 ....6..") }, // 4446233
Node { .strategy = Strategy.fromString("02.5.00 ..100.. 02.0.00 .73.6.. 15..423 ....4..") }, // 4446233
Node { .red = .{ .child = 3, .transition = .{ .index = 468, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 472, .flip = false}, .{ .index = 469, .flip = false}, .{ .index = 472, .flip = false}, .{ .index = 473, .flip = false}, .{ .index = 470, .flip = false}, .{ .index = 471, .flip = false}, .{ .index = 472, .flip = false}, } },
Node { .strategy = Strategy.fromString("112..0. ..010.. 10...00 ..6.57. 436.274 ..6.20.") }, // 44414
Node { .strategy = Strategy.fromString("001..10 ..2004. 006..40 ..2.257 406.153 ..2..57") }, // 44414
Node { .strategy = Strategy.fromString("000.100 ...0... 000..31 ....011 304..12 ..5.4.2") }, // 44414
Node { .strategy = Strategy.fromString("137.001 .330... 0.0.200 .10.5.. 4.1.566 .73.2..") }, // 44414
Node { .red = .{ .child = 4, .transition = .{ .index = 474, .flip = false }, }, },
Node { .yellow = .{ .{ .index = 475, .flip = false}, .{ .index = 475, .flip = false}, .{ .index = 476, .flip = false}, .{ .index = 475, .flip = false}, .{ .index = 475, .flip = false}, .{ .index = 475, .flip = false}, .{ .index = 475, .flip = false}, } },
Node { .strategy = Strategy.fromString("0.65.00 ..1.... 0.3..00 .03.... 5.0.214 .01..04") }, // 4441445
Node { .strategy = Strategy.fromString("0002.00 ....... 000..00 ....0.. 201..03 ..4..30") }, // 4441445
Node { .red = .{ .child = 5, .transition = .{ .index = 244, .flip = true }, }, },
};
