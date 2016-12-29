//
//  QPArchiver.m
//  QikPackage
//
//  Created by Jack on 2016/12/28.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "QPTask.h"

static NSString * const XCODEBUILD_PATH = @"/usr/bin/xcodebuild";

static NSString * const XCODEBUILD_COMMAND_EXPORTARCHIVE = @"-exportArchive";

static NSString * const XCODEBUILD_COMMAND_EXPORTOPTIONLIST = @"-exportOptionsPlist";

static NSString * const XCODEBUILD_COMMAND_EXPORTPATH = @"-exportPath";

static NSString * const XCODEBUILD_COMMAND_ARCHIVEPATH = @"-archivePath";

static NSString * const XCODEBUILD_COMMAND_WORKSPACE = @"-workspace";

static NSString * const XCODEBUILD_COMMAND_PROJECT = @"-project";

static NSString * const XCODEBUILD_COMMAND_SCHEME = @"-scheme";

static NSString * const XCODEBUILD_COMMAND_LIST = @"-list";

static NSString * const kTARGET  = @"Target";

static NSString * const kARCHIVE = @"archive";

static NSString * const kSCHEMES = @"Schemes:";

@interface QPTask ()

@property (nonatomic, strong) NSTask *nsTask;
@end

@implementation QPTask

- (instancetype)initWithCurrentDirectPath:(NSString *)aPath {
    self = [super init];
    
    if (self) {
        _nsTask = [[NSTask alloc] init];
        
        _nsTask.launchPath = XCODEBUILD_PATH;
        
        _nsTask.currentDirectoryPath = aPath;
        
        return self;
    }
    
    return nil;
}

- (void)executeWithArguments:(NSArray *)arguments {
    [_nsTask setArguments:arguments];
    
    [_nsTask launch];
    
    [_nsTask waitUntilExit];
}

@end

@implementation QPArchiver

- (void)archiveToPath:(NSString *)aPath
        withWorkspace:(NSString *)aWorkspace
              project:(NSString *)aProject
               scheme:(NSString *)aScheme {
    NSArray *arguments = nil;
    
    if (aWorkspace) {
        arguments =  @[XCODEBUILD_COMMAND_WORKSPACE, aWorkspace,
                       XCODEBUILD_COMMAND_SCHEME, aScheme,
                       kARCHIVE,
                       XCODEBUILD_COMMAND_ARCHIVEPATH, aPath];
        
    } else if (aProject) {
        arguments =  @[XCODEBUILD_COMMAND_PROJECT, aProject,
                       XCODEBUILD_COMMAND_SCHEME, aScheme,
                       kARCHIVE,
                       XCODEBUILD_COMMAND_ARCHIVEPATH, aPath];
        
    }
    
    [self executeWithArguments:arguments];
}

@end

@implementation QPExporter

- (void)exportAtPath:(NSString *)aPath withOptionsFile:(NSString *)aFilePath {
    NSArray *arguments = @[XCODEBUILD_COMMAND_EXPORTARCHIVE,
                           XCODEBUILD_COMMAND_ARCHIVEPATH, aPath,
                           XCODEBUILD_COMMAND_EXPORTOPTIONLIST, aFilePath,
                           XCODEBUILD_COMMAND_EXPORTPATH, kTARGET];
    
    [self executeWithArguments:arguments];
}

@end

@implementation QPSchemeParser

- (NSArray *)parseSchemes {    
    NSPipe *pipe = [NSPipe pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [self.nsTask setStandardOutput: pipe];
    
    [self executeWithArguments:@[XCODEBUILD_COMMAND_LIST]];
    
    return [self parseSchemesWithData:[file readDataToEndOfFile]];

}

- (NSArray *)parseSchemesWithData:(NSData *)aData {
    NSString *string = [[NSString alloc] initWithData: aData
                                             encoding: NSUTF8StringEncoding];
    
    NSRange range = [string rangeOfString:kSCHEMES];
    
    string = [string substringFromIndex:range.location+range.length];
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    NSMutableArray *result = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [result addObject:obj];
    }];
    
    return result;
}
@end
