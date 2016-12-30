//
//  COMCloudStorager.m
//  components
//
//  Created by 崔明辉 on 2016/12/30.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "COMCloudOperator.h"
#import "COMCloudComponentEntity.h"
#import <SSZipArchive/SSZipArchive.h>
#import <MCSketchPluginFramework/MCSketchPluginFramework.h>
#import <AppKit/AppKit.h>

@implementation COMCloudOperator

+ (void)createTmpDirectory {
    [[NSFileManager defaultManager] createDirectoryAtPath:@"/tmp/com.yy.ued.sketch.components/" withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (void)installDependencies:(NSMutableArray *)dependencies component:(COMCloudComponentEntity *)component {
    if (dependencies.count == 0) {
        component.dependencies = nil;
        [self addComponent:component completionBlock:nil];
        return;
    }
    [self addComponent:[dependencies firstObject] completionBlock:^{
        [dependencies removeObjectAtIndex:0];
        [self installDependencies:dependencies component:component];
    }];
}

+ (void)addComponent:(COMCloudComponentEntity *)component completionBlock:(void(^)())completionBlock {
    if (component.dependencies.count > 0) {
        NSMutableArray *dependencies = [component.dependencies mutableCopy];
        [self installDependencies:dependencies component:component];
        return;
    }
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:component.zip] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data != nil) {
            NSString *zipPath = [NSString stringWithFormat:@"/tmp/com.yy.ued.sketch.components/%@", [component.zip lastPathComponent]];
            NSString *unzipPath = [NSString stringWithFormat:@"/tmp/com.yy.ued.sketch.components/%@_unzipped/", [component.zip lastPathComponent]];
            [data writeToFile:zipPath atomically:YES];
            [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath];
            NSString *libraryPath = [NSString stringWithFormat:@"/tmp/com.yy.ued.sketch.components/%@_unzipped/Library/", [component.zip lastPathComponent]];
            [self copyLibrary:libraryPath];
            for (NSString *file in [[NSFileManager defaultManager] enumeratorAtPath:unzipPath]) {
                if ([file containsString:@"__MACOSX"]) {
                    continue;
                }
                if ([file hasSuffix:@".sketch"]) {
                    NSString *sketchPath = [NSString stringWithFormat:@"%@%@", unzipPath, file];
                    [self clonePagesToCurrent:sketchPath];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            }
        }
    }] resume];
}

+ (void)copyLibrary:(NSString *)libraryPath {
    NSString *localLibrary = [NSString stringWithFormat:@"%@/CodeX/Library", [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject]];
    [[NSFileManager defaultManager] createDirectoryAtPath:localLibrary withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:localLibrary forKey:@"com.yy.ued.sketch.components.libPath"];
    for (NSString *file in [[NSFileManager defaultManager] enumeratorAtPath:libraryPath]) {
        [[NSFileManager defaultManager] replaceItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", localLibrary, file]]
                                           withItemAtURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", libraryPath, file]]
                                          backupItemName:nil
                                                 options:kNilOptions
                                        resultingItemURL:nil
                                                   error:nil];
    }
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
+ (void)clonePagesToCurrent:(NSString *)sketchPath {
    MSDocument *currentDocument = Sketch_GetCurrentDocument();
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:sketchPath] display:YES completionHandler:^(NSDocument * _Nullable document, BOOL documentWasAlreadyOpen, NSError * _Nullable error) {
        MSDocument *cloudDocument = (id)document;
        [[cloudDocument pages] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MSPage *cloudPage = obj;
            if (![cloudPage.name hasPrefix:@"TPL -"]) {
                return ;
            }
            for (MSPage *cPage in [currentDocument pages]) {
                if ([cPage.name isEqualToString:cloudPage.name]) {
                    [cPage removeAllLayers];
                    [cPage addLayers:(id)[cloudPage layers]];
                    return;
                }
            }
            MSPage *addPage = [currentDocument performSelector:@selector(addBlankPage) withObject:nil];
            addPage.name = cloudPage.name;
            [addPage addLayers:(id)[cloudPage layers]];
        }];
        [cloudDocument close];
    }];
}
#pragma GCC diagnostic

@end
