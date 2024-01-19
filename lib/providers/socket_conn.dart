import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketChannel {
  
  SocketChannel(this._getConnectionWSSChannel) {
    _startConnection();
  }

  final IOWebSocketChannel Function() _getConnectionWSSChannel;

  late IOWebSocketChannel _ioWebSocketChannel;

  WebSocketSink get _sink => _ioWebSocketChannel.sink;

  late Stream<dynamic> _innerStream;

  final _outerStreamSubject = BehaviorSubject<dynamic>();

  Stream<dynamic> get stream => _outerStreamSubject.stream;

  bool _isFirstRestart = false;
  bool _isFollowingRestart = false;
  bool _isManuallyClosed = false;

  void _handleLostConnection() {
    if (_isFirstRestart && !_isFollowingRestart) {
      Future.delayed(const Duration(seconds: 3), () {
        _isFollowingRestart = false;
        _startConnection();
      });
      _isFollowingRestart = true;
    } else {
      _isFirstRestart = true;
      _startConnection();
    }
  }

  void _startConnection() {
    _ioWebSocketChannel = _getConnectionWSSChannel();
    final innerStream = _ioWebSocketChannel.stream;
    innerStream.listen(
      
      (event) {
        _isFirstRestart = false;
        _outerStreamSubject.add(event);
      },
      onError: (error) {
        _handleLostConnection();
      },
      onDone: () {
        if (!_isManuallyClosed) {
          _handleLostConnection();
        }
      },
    );
  }

  void sendMessage(String message) => _sink.add(message);

  void close() {
    _isManuallyClosed = true;
    _sink.close();
  }
}