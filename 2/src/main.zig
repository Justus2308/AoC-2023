const std = @import("std");
const fmt = std.fmt;
const meta = std.meta;
const mem = std.mem;


const Color = enum(u32) {
	red = 12,
	green = 13,
	blue = 14,
};

const Mins = struct {
	red: u32 = 0,
	blue: u32 = 0,
	green: u32 = 0,
};

pub fn day2(reader: anytype) !struct { u64, u64 } {
	var total: u64 = 0;
	var powers: u64 = 0;

	outer: while (true) {
		var game: [8]u8 = undefined;
		_ = try reader.readUntilDelimiterOrEof(&game, ' ') orelse break :outer;
		const game_num_chars = try reader.readUntilDelimiter(&game, ':');
		const game_num = try fmt.parseInt(u32, game_num_chars, 10);

		var possible = true;
		var mins = Mins {};

		var buf: [256]u8 = undefined;
		const read = try reader.readUntilDelimiter(&buf, '\n');
		var rounds = mem.tokenizeScalar(u8, read, ';');
		var rnd = rounds.next();
		while (rnd) |r| : (rnd = rounds.next()) {
			var tokens = mem.tokenizeScalar(u8, r, ',');

			var tkn = tokens.next();
			while (tkn) |t| : (tkn = tokens.next()) {
				var pair = mem.tokenizeScalar(u8, t, ' ');
				const num_chars = pair.next() orelse return error.ParseError;
				const col_chars = pair.next() orelse return error.ParseError;

				const num = try fmt.parseInt(u32, num_chars, 10);
				const col = meta.stringToEnum(Color, col_chars) orelse return error.ParseError;

				switch (col) {
					inline else => |c| {
						const val = @field(mins, @tagName(c));
						@field(mins, @tagName(c)) = @max(val, num);
					},
				}
				if (num > @intFromEnum(col)) possible = false;
			}
		}
		if (possible) total += game_num;

		var power: u64 = 1;
		inline for (meta.fields(Mins)) |f| power *= @field(mins, f.name);
		powers += power;
	}
	return .{ total, powers };
}

pub fn main() !void {
	const input = try std.fs.cwd().openFile("input.txt", .{});
	const r = input.reader();

	const totals = try day2(r);

	std.debug.print("1: Total: {d}\n", .{ totals.@"0" });
	std.debug.print("2: Powers: {d}\n", .{ totals.@"1" });
}
