//
//  AppDelegate.m
//  TestApp
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "COMGenerator.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    COMGenerator *generator = [COMGenerator new];
    generator.className = @"MyView";
    COMGenLayer *layer = [generator parse];
    [[generator oc_code:layer genType:COMGenTypeView] enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [obj writeToFile:[NSString stringWithFormat:@"/Users/PonyCui_Home/Desktop/ttt/ttt/%@", key]
              atomically:YES
                encoding:NSUTF8StringEncoding
                   error:NULL];
    }];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
