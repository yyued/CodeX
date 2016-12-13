//
//  COMAssetsWritter.m
//  components
//
//  Created by 崔明辉 on 2016/12/13.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMAssetsWritter.h"

@implementation NSImage (COM)

- (NSData *)imagePNGRepresentation {
    return [[NSBitmapImageRep imageRepWithData:self.TIFFRepresentation] representationUsingType:NSPNGFileType properties:@{}];
}

@end

@implementation COMAssetsWritter

+ (NSImage *)resizeImage:(NSImage *)image newSize:(NSSize)newSize {
    NSImage *newImage = [[NSImage alloc] initWithSize:newSize];
    [newImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    image.size = newSize;
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositingOperationCopy fraction:1.0];
    [newImage unlockFocus];
    return newImage;
}

+ (void)writeIOSImage:(NSImage *)image baseSize:(CGSize)baseSize toAssetsPath:(NSString *)assetsPath fileName:(NSString *)fileName {
    NSString *basePath = [NSString stringWithFormat:@"%@/%@.imageset", assetsPath, fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:basePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSMutableArray<NSDictionary<NSString *, NSString *> *> *images = [NSMutableArray array];
    CGFloat scale = 1.0;
    if (image.size.height >= baseSize.height * 3 && image.size.width >= baseSize.width * 3) {
        scale = MAX(3.0, scale);
        NSData *newData = [[self resizeImage:image newSize:NSMakeSize(image.size.width, image.size.height)] imagePNGRepresentation];
        [newData writeToFile:[NSString stringWithFormat:@"%@/%@@3x.png", basePath, fileName] atomically:YES];
        [images addObject:@{
                            @"idiom": @"universal",
                            @"scale": @"3x",
                            @"filename": [NSString stringWithFormat:@"%@@3x.png", [fileName lastPathComponent]],
                            }];
    }
    if (image.size.height >= baseSize.height * 2 && image.size.width >= baseSize.width * 2) {
        scale = MAX(2.0, scale);
        NSData *newData = [[self resizeImage:image newSize:NSMakeSize(image.size.width / scale * 2, image.size.height / scale * 2)] imagePNGRepresentation];
        [newData writeToFile:[NSString stringWithFormat:@"%@/%@@2x.png", basePath, fileName] atomically:YES];
        [images addObject:@{
                            @"idiom": @"universal",
                            @"scale": @"2x",
                            @"filename": [NSString stringWithFormat:@"%@@2x.png", [fileName lastPathComponent]],
                            }];
    }
    if (image.size.height >= baseSize.height * 1 && image.size.width >= baseSize.width * 1) {
        scale = MAX(1.0, scale);
        NSData *newData = [[self resizeImage:image newSize:NSMakeSize(image.size.width / scale * 1, image.size.height / scale * 1)] imagePNGRepresentation];
        [newData writeToFile:[NSString stringWithFormat:@"%@/%@.png", basePath, fileName] atomically:YES];
        [images addObject:@{
                            @"idiom": @"universal",
                            @"scale": @"1x",
                            @"filename": [NSString stringWithFormat:@"%@.png", [fileName lastPathComponent]],
                            }];
    }
    NSDictionary *JSONObject = @{
                                 @"images": images,
                                 @"info": @{
                                         @"version": @(1),
                                         @"author": @"xcode",
                                         },
                                 };
    [[NSJSONSerialization dataWithJSONObject:JSONObject options:kNilOptions error:NULL]
     writeToFile:[NSString stringWithFormat:@"%@/Contents.json", basePath] atomically:YES];
}

@end
