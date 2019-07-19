#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                            methodChannelWithName:@"fairy.e.validator/qrcode"
                                            binaryMessenger:controller];
    
    
    
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
         NSLog(@"method=%@ \narguments = %@", call.method, call.arguments);
        if ([@"imageStream" isEqualToString:call.method]) {
             NSLog(@"imageStreamddd");
             result(call.method);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
