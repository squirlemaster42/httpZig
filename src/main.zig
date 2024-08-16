const std = @import("std");
const net = std.net;
const print = std.debug.print;

const HttpError = error{InvalidRequest};

pub fn main() !void {
    const addr = try net.Ip4Address.parse("127.0.0.1", 0);
    const localhost = net.Address{ .in = addr };
    var server = try localhost.listen(.{ .reuse_port = true });
    defer server.deinit();

    const listenAddress = server.listen_address;
    print("Server Listening on port {}\n", .{listenAddress.getPort()});

    while (server.accept()) |client| {
        defer client.stream.close();

        print("Connection recieved from {}\n", .{client.address});

        _ = try client.stream.write("Test Message");

        var buffer: [4096]u8 = undefined;
        while (true) {
            const recBytes = try client.stream.read(&buffer);
            const chunk = buffer[0..recBytes];

            if (chunk.len == 0) {
                break;
            }
            print("message: {s}\n", .{chunk});
            _ = try client.stream.writer().print("message: {s}", .{chunk});
        }
    } else |err| {
        print("{}\n", .{err});
    }
}
