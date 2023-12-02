const std = @import("std");
const testing = std.testing;


const Literal = struct {
	lit: []const u8,
	val: u8,

	pos: usize = 0,

	pub fn next(self: *Literal) !u8 {
		if (self.pos == self.lit.len) {
			self.pos = 0;
			return error.EOL;
		}

		const c = self.lit[self.pos];
		self.pos += 1;
		return c;
	}

	pub fn done(self: *const Literal) bool {
		return self.pos == self.lit.len;
	}

	pub fn reset(self: *Literal) void {
		self.pos = 0;
	}
};

pub fn day1(r: anytype, size: usize) !u64 {
	var dict = [_]Literal {
		.{ .lit = "one", .val = '1' },
		.{ .lit = "two", .val = '2' },
		.{ .lit = "three", .val = '3' },
		.{ .lit = "four", .val = '4' },
		.{ .lit = "five", .val = '5' },
		.{ .lit = "six", .val = '6' },
		.{ .lit = "seven", .val = '7' },
		.{ .lit = "eight", .val = '8' },
		.{ .lit = "nine", .val = '9' },
	};

	var first: ?u8 = null;
	var last: ?u8 = null;

	var total: u64 = 0;

	for (0..size) |_| {
		const c = try r.readByte();
		if (c == '\n') {
			const combined = [2]u8 {
				first orelse return error.NoNumberFound,
				last orelse first.?,
			};
			total += std.fmt.parseInt(u64, &combined, 10) catch unreachable;

			first = null;
			last = null;

			for (0..dict.len) |i| dict[i].reset();

			continue;
		}

		for (0..dict.len) |i| {
			if (dict[i].next() catch 0 == c) {
				if (dict[i].done()) {
					if (first == null) first = dict[i].val else last = dict[i].val;
				}
			} else {
				dict[i].reset();
				if (dict[i].lit[0] == c) _ = dict[i].next() catch unreachable;
			}
		}

		if (std.ascii.isDigit(c)) {
			if (first == null) first = c else last = c;
		}
	}

	return total;
}

pub fn main() !void {
	const input = try std.fs.cwd().openFile("input.txt", .{});
	const r = input.reader();

	const total = try day1(r, try input.getEndPos());

	std.debug.print("Total: {d}\n", .{ total });
}


test "Failing case" {
	const input = "qkvc7pvsv6rvsxlqzpjdjkd1eightthree\n";

	var buf = std.io.fixedBufferStream(input);
	const r = buf.reader();

	const total = try day1(r, input.len);
	const expected = 73;

	std.debug.print("total: {d} | expected: {d}\n", .{ total, expected });
	try testing.expect(total == expected);
}

test "Failing case 2" {
	const input = "oneight\n";

	var buf = std.io.fixedBufferStream(input);
	const r = buf.reader();

	const total = try day1(r, input.len);
	const expected = 18;

	std.debug.print("total: {d} | expected: {d}\n", .{ total, expected });
	try testing.expect(total == expected);
}
