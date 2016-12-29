//
//  QPBuilder.m
//  QikPackage
//
//  Created by Jack on 16/5/3.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "QPBuilder.h"
#import "QPPreference.h"
#import "QPTask.h"

static NSString * const kArchive = @"Archive";

static NSString * const EXTENSION_WORKSPACE = @"xcworkspace";

static NSString * const EXTENSION_PROJECT   = @"xcodeproj";

static NSString * const EXTENSION_ARCHIVE   = @"xcarchive";

@implementation QPBuilder

+ (void)archiveScheme:(NSString *)aScheme
               toPath:(NSString *)aPath
          withOptions:(QPPreference *)aOptions {
    QPArchiver *task = [[QPArchiver alloc] initWithCurrentDirectPath:aOptions.projectDirectory];
    
    [task archiveToPath:aPath
          withWorkspace:aOptions.workSpaceName
                project:aOptions.projectName
                 scheme:aScheme];
}

+ (void)exportAtArchivePath:(NSString *)aPath withOptions:(QPPreference *)aOptions {
    QPExporter *task = [[QPExporter alloc] initWithCurrentDirectPath:aOptions.targetDirectory];
        
    [task exportAtPath:aPath withOptionsFile:aOptions.filePathOfOptionList];
}

+ (void)runWithOptions:(QPPreference *)aOptions
            usingBlock:(void (^)(NSString *progrssingInfo, BOOL isFinished))aBlock {
    __block NSString *archivePath = [aOptions.targetDirectory stringByAppendingPathComponent:kArchive];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:archivePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:archivePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSString *scheme in aOptions.schemes) {
            NSString *archiveName = [scheme stringByAppendingPathExtension:EXTENSION_ARCHIVE];
            
            archivePath = [archivePath stringByAppendingPathComponent:archiveName];

            if (aBlock) {
                aBlock ([NSString stringWithFormat:@"正在编译 %@ ", scheme], NO);
            }
            [QPBuilder archiveScheme:scheme toPath:archivePath withOptions:aOptions];
            if (aBlock) {
                aBlock ([NSString stringWithFormat:@"编译 %@ 完成", scheme], NO);
            }
            
            if (aBlock) {
                aBlock ([NSString stringWithFormat:@"正在打包 %@ ", scheme], NO);
            }
            [QPBuilder exportAtArchivePath:archivePath withOptions:aOptions];
            if (aBlock) {
                aBlock ([NSString stringWithFormat:@"打包 %@ 完成", scheme], NO);
            }
            
            [[NSFileManager defaultManager] removeItemAtPath:archivePath error:nil]; 
        }
        
        if (aBlock) {
            aBlock (@"打包完成", YES);
        }
        
    });
}

+ (void)parseSchemesAtProjectPath:(NSString *)aPath
                  completionBlock:(void (^)(NSArray <NSString *> * result))aBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        QPSchemeParser *task = [[QPSchemeParser alloc] initWithCurrentDirectPath:aPath];
        
        NSArray *result = [task parseSchemes];
        
        if (aBlock) {
            aBlock(result);
        }
    });
}

@end
