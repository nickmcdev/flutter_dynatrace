#import "FlutterDynatracePlugin.h"
#if __has_include(<flutter_dynatrace/flutter_dynatrace-Swift.h>)
#import <flutter_dynatrace/flutter_dynatrace-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_dynatrace-Swift.h"
#endif

@implementation FlutterDynatracePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterDynatracePlugin registerWithRegistrar:registrar];
}
@end
