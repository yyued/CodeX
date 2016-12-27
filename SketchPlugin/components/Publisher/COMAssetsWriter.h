//
//  COMAssetsWritter.h
//  components
//
//  Created by 崔明辉 on 2016/12/13.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface COMAssetsWriter : NSObject

+ (void)writeIOSImage:(NSImage *)image baseSize:(CGSize)baseSize toAssetsPath:(NSString *)assetsPath fileName:(NSString *)fileName;
+ (NSString *)stripFilename:(NSString *)filename;

@end
