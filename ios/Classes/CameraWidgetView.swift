import Flutter
import UIKit
import AVFoundation

class CameraWidgetViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return CameraWidgetView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class CameraWidgetView: NSObject, FlutterPlatformView {
    private var _view: UIView
    

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView){
        _view.backgroundColor = UIColor.blue
        let myview = MyView()
        _view.addSubview(myview)
    }

}

class MyView: UIView {
    var codeReader: CodeReader = AVCodeReader()
    private var eventStreamHandler = CameraEventStreamHandler.shared
    var hasFailed = false

    override func didMoveToWindow() {
        super.didMoveToWindow()
        layer.insertSublayer(codeReader.videoPreview, at: 0)
        checkCameraAccess()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        codeReader.videoPreview.frame = superview!.layer.bounds
    }

    private func checkCameraAccess() {
        // guard !hasFailed else {
        //     return
        // }
        
        guard codeReader.hasCameraAvailable else {
            // let options = AlertOptions(title: "", message: "Sem camera")
            self.hasFailed = true
            print("sem camera")
            return
        }
        
        let authorizationStatus = codeReader.authorization
        
        switch authorizationStatus {
        case .notDetermined:
            askForPermission()
        case .restricted, .denied:
            print("restrito")
        case .authorized:
            startCameraCapture()
        @unknown default: break
        }
    }
    
    private func startCameraCapture() {
        codeReader.startReading {  [weak self] code in
            self?.eventStreamHandler.sendCameraEvent(with: code)
        }
    }
    
    private func askForPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                self?.startCameraCapture()
            }
        }
    }
}

class CameraEventStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var eventChannel: FlutterEventChannel?

    public static let shared = CameraEventStreamHandler()
    
    public func onListen(withArguments arguments: Any?,
                    eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    public func sendCameraEvent(with code: String) {
        guard let eventSink = eventSink else { return }
        print("codigo aqui", code)
        eventSink(code)
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

}
