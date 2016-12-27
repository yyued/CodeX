//
//  COMCodeWriter.h
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface COMCodeWriter : NSObject

+ (void)saveWithDictionary:(NSDictionary *)dictionary basePath:(NSString *)basePath;

+ (void)saveOCHeaderWithFilePath:(NSString *)filePath contents:(NSString *)contents;

+ (void)saveOCImplementationWithFilePath:(NSString *)filePath contents:(NSString *)contents;

+ (void)saveXIBWithFilePath:(NSString *)filePath contents:(NSString *)contents;

@end
