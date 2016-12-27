//
//  AppDelegate.m
//  TestApp
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "AppDelegate.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "COMGenerator.h"
#import "COMPropsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //    COMGenerator *generator = [COMGenerator new];
    //    generator.className = @"MyView";
    //    COMGenLayer *layer = [generator parse];
    //    [[generator oc_code:layer genType:COMGenTypeView] enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull
    //    key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
    //        [obj writeToFile:[NSString stringWithFormat:@"/Users/cuiminghui/Desktop/test/test/%@", key]
    //              atomically:YES
    //                encoding:NSUTF8StringEncoding
    //                   error:NULL];
    //    }];
    //    [[NSApplication sharedApplication] mainWindow]

    //    COMGenerator *generator = [COMGenerator new];
    //    generator.className = @"ViewController";
    //    generator.assetsPath = @"/Users/cuiminghui/Desktop/test/test/Assets.xcassets";
    //    generator.libraryPath = @"/Users/cuiminghui/Documents/Works/OpenSource/CodeX/Library";
    //    COMGenLayer *layer = [generator parse];
    //    [[generator oc_code:layer genType:COMGenTypeViewController] enumerateKeysAndObjectsUsingBlock:^(NSString *
    //    _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
    //        [obj writeToFile:[NSString stringWithFormat:@"/Users/cuiminghui/Desktop/test/test/%@", key]
    //              atomically:YES
    //                encoding:NSUTF8StringEncoding
    //                   error:NULL];
    //    }];

    COMGenerator *generator = [COMGenerator new];
    generator.className = @"ViewController";
    generator.assetsPath = @"/Users/cuiminghui/Desktop/test/test/Assets.xcassets";
    generator.libraryPath = @"/Users/cuiminghui/Documents/Works/OpenSource/CodeX/Library";
    COMGenLayer *layer = [generator parse];
    NSXMLDocument *doc = [generator xib_code:layer genType:COMGenTypeViewController];
    [[doc XMLStringWithOptions:NSXMLNodePrettyPrint]
        writeToFile:@"/Users/cuiminghui/Desktop/test/test/ViewController.xib"
         atomically:YES
           encoding:NSUTF8StringEncoding
              error:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
