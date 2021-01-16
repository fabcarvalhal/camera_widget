import Flutter
import UIKit

public class SwiftCameraWidgetPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // let channel = FlutterMethodChannel(name: "camera_widget", binaryMessenger: registrar.messenger())
    // let instance = SwiftCameraWidgetPlugin()
    // registrar.addMethodCallDelegate(instance, channel: channel)
    let eventChannel = FlutterEventChannel(name: "codeReaderEventChannel",
                                              binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(CameraEventStreamHandler.shared)
    let factory = CameraWidgetViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "CameraWidgetView")
  }
}
