import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketRepo {
  IO.Socket? socket;

  void connect(String token) {
    log("🔑 Attempting to connect with token: $token");

    // Always dispose old socket first
    disconnect();

    // Create new socket instance with fresh token
    socket = IO.io(
      "http://10.0.2.2:8000",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setPath("/chat")
          .setAuth({'token': token}) // Explicitly set new token
          .build(),
    );

    // Forcefully override auth to ensure no caching
    socket!.auth = {'token': token};

    socket!.onConnect((_) {
      print("✅ Connected to socket server with id: ${socket!.id}");
      print("🔑 Connected with token: ${socket!.auth?['token']}");
      log("✅ Socket connected successfully");
    });

    socket!.onDisconnect((_) => print("❌ Disconnected"));
    socket!.onError((data) => print("⚠️ Error: $data"));
    socket!.onReconnect((_) => print("🔄 Reconnected"));

    socket!.connect();
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
    if (socket != null) {
      print("🧹 Disconnecting socket...");
      socket!.clearListeners(); // Clear all listeners to avoid stale callbacks
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      print("✅ Socket fully disposed");
    }
  }

  bool get isConnected => socket != null && socket!.connected;

  // Called automatically on hot reload
  void reassemble() {
    print("♻️ Hot reload detected, cleaning socket");
    disconnect();
  }
}
