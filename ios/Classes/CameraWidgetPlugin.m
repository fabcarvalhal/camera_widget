#import "CameraWidgetPlugin.h"
#if __has_include(<camera_widget/camera_widget-Swift.h>)
#import <camera_widget/camera_widget-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "camera_widget-Swift.h"
#endif

@implementation CameraWidgetPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCameraWidgetPlugin registerWithRegistrar:registrar];
}
@end
