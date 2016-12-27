//
//  COMCodeWriter.m
//  components
//
//  Created by 崔明辉 on 2016/12/27.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMCodeWriter.h"

@implementation COMCodeWriter

+ (void)saveWithDictionary:(NSDictionary *)dictionary basePath:(NSString *)basePath {
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
      if ([key hasSuffix:@".h"]) {
          [self saveOCHeaderWithFilePath:[NSString stringWithFormat:@"%@/%@", basePath, key] contents:obj];
      } else if ([key hasSuffix:@".m"]) {
          [self saveOCImplementationWithFilePath:[NSString stringWithFormat:@"%@/%@", basePath, key] contents:obj];
      } else if ([key hasSuffix:@".xib"]) {
          [self saveXIBWithFilePath:[NSString stringWithFormat:@"%@/%@", basePath, key] contents:obj];
      }
    }];
}

+ (void)saveOCHeaderWithFilePath:(NSString *)filePath contents:(NSString *)contents {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        __block NSString *localCode =
            [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (![localCode containsString:@"#pragma mark - CodeX Outlets"]) {
            [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            return;
        }
        localCode = [localCode stringByReplacingOccurrencesOfString:@"\n.*?// CodeX managed."
                                                         withString:@""
                                                            options:NSRegularExpressionSearch
                                                              range:NSMakeRange(0, localCode.length)];

        [[contents componentsSeparatedByString:@"\n"] enumerateObjectsUsingBlock:^(
                                                          NSString *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          if ([obj hasSuffix:@"// CodeX managed."]) {
              localCode = [localCode stringByReplacingOccurrencesOfString:@"#pragma mark - CodeX Outlets"
                                                               withString:[NSString stringWithFormat:@"#pragma mark - CodeX Outlets\n%@", obj]];
          }
        }];
        [localCode writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    } else {
        [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (void)saveOCImplementationWithFilePath:(NSString *)filePath contents:(NSString *)contents {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *localCode = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (![localCode containsString:@"#pragma mark - COXManaged Interface"]) {
            [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            return;
        }
        NSArray *localComponents = [localCode componentsSeparatedByString:@"\n#pragma mark - "];
        NSArray *contentsComponents = [contents componentsSeparatedByString:@"\n#pragma mark - "];
        NSMutableString *newCode = [NSMutableString string];
        [localComponents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj hasPrefix:@"COXManaged Interface"]) {
                [newCode appendString:@"\n#pragma mark - "];
                [newCode appendString:contentsComponents[1]];
            }
            else if ([obj hasPrefix:@"COXManaged implementation"]) {
                [newCode appendString:@"\n#pragma mark - "];
                [newCode appendString:contentsComponents[3]];
            }
            else {
                if (idx > 0) {
                    [newCode appendString:@"\n#pragma mark - "];
                }
                [newCode appendString:obj];
            }
        }];
        [newCode writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else {
        [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

+ (void)saveXIBWithFilePath:(NSString *)filePath contents:(NSString *)contents {
    [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
