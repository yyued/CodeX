//
//  AppDelegate.m
//  TestApp
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    JSContext *context = [JSContext new];
    [context evaluateScript:@"function a(b){eval('var e = '+b);return e}"];
    context[@"hello"] = ^(){
        return @"123";
    };
    JSValue *aValue = [context evaluateScript:@"hello()"];
    NSDictionary *dict = [aValue toDictionary];
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
