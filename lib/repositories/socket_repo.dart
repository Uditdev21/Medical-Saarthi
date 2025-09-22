import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketRepo {
  IO.Socket? socket;

  void connect(String token) {
    socket = IO.io(
      "http://10.0.2.2:8000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setPath("/chat")
          .setExtraHeaders({'Authorization': token})
          .build(),
    );

    socket!.connect();

    // Default events
    socket!.onConnect((_) => print("✅ Connected to socket server"));
    socket!.onDisconnect((_) => print("❌ Disconnected"));
    socket!.onError((data) => print("⚠️ Error: $data"));
    socket!.onReconnect((_) => print("🔄 Reconnected"));
  }

  /// Generic event handler
  void onEvent(String event, void Function(dynamic) callback) {
    socket?.on(event, callback);
  }

  void offEvent(String event) {
    socket?.off(event);
  }

  void emitEvent(String event, dynamic data) {
    socket?.emit(event, data);
  }

  void disconnect() {
    socket?.disconnect();
    socket?.dispose();
  }
}
