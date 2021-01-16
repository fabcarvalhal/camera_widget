import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyCameraWidget extends StatefulWidget {
  final Function(String) onCodeRead;

  const MyCameraWidget({Key key, this.onCodeRead}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyCameraWidgetState();
}

class _MyCameraWidgetState extends State<MyCameraWidget> {
  EventChannel _eventChannel;

  void initState() {
    super.initState();
  }

  void _onEvent(Object event) {
    widget.onCodeRead(event);
  }

  void _onError(Object error) {
    print(error);
  }

  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    final String viewType = 'CameraWidgetView';
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    if (mounted) {
      _eventChannel = EventChannel('codeReaderEventChannel');
      _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }
    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
