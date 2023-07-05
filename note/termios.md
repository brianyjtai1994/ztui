```zig
var tty: fs.File = try fs.cwd().openFile("/dev/tty", .{ .mode = .read_write });
defer tty.close();

const termios_backup = try os.tcgetattr(tty.handle);
```

gives

```shell
termios_backup = c.darwin.termios{
    .iflag = 27394,
    .oflag = 3,
    .cflag = 19200,
    .lflag = 536872395,
    .cc = {
         4, 255, 255, 127,  23,
        21,  18, 255,   3,  28,
        26,  25,  17,  19,  22,
        15,   1,   0,  20, 255
    },
    .ispeed = 9600,
    .ospeed = 9600
}
```

To modify the following default values

```shell
os.system.tcflag_t = u64

# Stop the terminal from displaying pressed keys.
os.system.ECHO     = 8
# Disable canonical ("cooked") input mode. Allows us to read inputs byte-wise instead of line-wise.
os.system.ICANON   = 256
# Disable signals for Ctrl-C (SIGINT) and Ctrl-Z (SIGTSTP), so we can handle them as "normal" escape sequences.
os.system.ISIG     = 128
# Disable input preprocessing. This allows us to handle Ctrl-V, which would otherwise be intercepted by some terminals.
os.system.IEXTEN   = 1024

# Disable software control flow. This allows us to handle Ctrl-S and Ctrl-Q.
os.system.IXON     = 512
# Disable converting carriage returns to newlines. Allows us to handle Ctrl-J and Ctrl-M.
os.system.ICRNL    = 256
# Disable converting sending SIGINT on break conditions.
os.system.BRKINT   = 2
# Disable parity checking.
os.system.INPCK    = 16
# Disable stripping the 8th bit of characters.
os.system.ISTRIP   = 32

# Disable output processing.
os.system.OPOST    = 1

# Set the character size to 8 bits per byte.
os.system.CS8      = 768
```

, we use

```zig
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
```

, which gives

```shell
termios_runtime = c.darwin.termios{
    .iflag = 26624,
    .oflag = 2,
    .cflag = 19200,
    .lflag = 536870979,
    .cc = {
         4, 255, 255, 127,  23,
        21,  18, 255,   3,  28,
        26,  25,  17,  19,  22,
        15,   1,   0,  20, 255 },
    .ispeed = 9600,
    .ospeed = 9600
}
```
