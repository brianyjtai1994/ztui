const std = @import("std");
const os = std.os;
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var tty: fs.File = try fs.cwd().openFile("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    const termios_backup = try os.tcgetattr(tty.handle);

    print("termios_backup             = {any}\n", .{termios_backup});
    print("@TypeOf(termios_backup)    = {any}\n", .{@TypeOf(termios_backup)});
    print("@TypeOf(termios_backup.cc) = {any}\n", .{@TypeOf(termios_backup.cc)});

    print("os.system.tcflag_t = {any}\n", .{os.system.tcflag_t});
    print("os.system.ECHO     = {any}\n", .{os.system.ECHO});
    print("os.system.ICANON   = {any}\n", .{os.system.ICANON});
    print("os.system.ISIG     = {any}\n", .{os.system.ISIG});
    print("os.system.IEXTEN   = {any}\n", .{os.system.IEXTEN});
    print("os.system.IXON     = {any}\n", .{os.system.IXON});
    print("os.system.ICRNL    = {any}\n", .{os.system.ICRNL});
    print("os.system.BRKINT   = {any}\n", .{os.system.BRKINT});
    print("os.system.INPCK    = {any}\n", .{os.system.INPCK});
    print("os.system.ISTRIP   = {any}\n", .{os.system.ISTRIP});
    print("os.system.OPOST    = {any}\n", .{os.system.OPOST});
    print("os.system.CS8      = {any}\n", .{os.system.CS8});

    print("os.system.V.TIME   = {any}\n", .{os.system.V.TIME});
    print("os.system.V.MIN    = {any}\n", .{os.system.V.MIN});

    // = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =

    var termios_runtime = termios_backup; // copy

    termios_runtime.lflag &= ~@as(
        os.system.tcflag_t,
        os.system.ECHO | os.system.ICANON | os.system.ISIG | os.system.IEXTEN,
    );
    termios_runtime.iflag &= ~@as(
        os.system.tcflag_t,
        os.system.IXON | os.system.ICRNL | os.system.BRKINT | os.system.INPCK | os.system.ISTRIP,
    );
    termios_runtime.oflag &= ~@as(os.system.tcflag_t, os.system.OPOST);
    termios_runtime.cflag |= os.system.CS8;
    termios_runtime.cc[os.system.V.TIME] = 0;
    termios_runtime.cc[os.system.V.MIN] = 1;

    print("termios_runtime = {any}\n", .{termios_runtime});

    try os.tcsetattr(tty.handle, .FLUSH, termios_runtime);
    try os.tcsetattr(tty.handle, .FLUSH, termios_backup);
}
