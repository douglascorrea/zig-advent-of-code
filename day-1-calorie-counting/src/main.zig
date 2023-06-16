const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    // var num: []const u8 = "123";
    // var value = std.fmt.parseInt(i32, num, 10) catch unreachable;
    // std.debug.print("{}", .{value});
    var file = try std.fs.cwd().openFile("calories.txt", .{});
    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var file_reader = buf_reader.reader();

    var lines: [256]u8 = undefined;
    var lines_buf = std.io.fixedBufferStream(&lines);
    var lines_writer = lines_buf.writer();
    var sum: i32 = 0;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var list_of_elf_food = ArrayList(i32).init(allocator);

    while (file_reader.streamUntilDelimiter(lines_writer, '\r', lines_buf.buffer.len)) {
        const current_line: []const u8 = lines_buf.getWritten();
        const last_character = current_line[current_line.len - 1];
        std.debug.print("{s}", .{current_line});
        if (last_character == '\n') {
            // this separates each elf
            std.debug.print("Sum for this Elf: {}\n", .{sum});
            try list_of_elf_food.append(sum);
            sum = 0;
        } else {
            sum = perform_sum(current_line, sum);
        }
        lines_buf.reset();
    } else |_| {
        std.debug.print("\nSum for this Elf: {}\n", .{sum});
        try list_of_elf_food.append(sum);
        std.debug.print("\nFinishing process file", .{});
    }
    std.debug.print("\nThe elf with most food has: {}", .{std.mem.max(i32, list_of_elf_food.items)});
}

pub fn perform_sum(current_line: []const u8, sum: i32) i32 {
    var current_line_trimmed = std.mem.trim(u8, current_line, "\n \r\t");
    var current_line_value = std.fmt.parseInt(i32, current_line_trimmed, 10) catch
        @panic("something");
    return sum + current_line_value;
}
