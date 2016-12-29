//
//  QPPreference.m
//  QikPackage
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "QPPreference.h"

static NSString * const kPreference       = @"Preference";

static NSString * const kProjectDirectory = @"ProjectPath";

static NSString * const kTargetDirectory  = @"TargetPath";

static NSString * const kSchemes          = @"Schemes";

static NSString * const EXTENSION_WORKSPACE = @"xcworkspace";

static NSString * const EXTENSION_PROJECT = @"xcodeproj";

static NSString * const ExportOptions_File = @"ExportOptions.plist";


@interface QPPreference ()

@property (nonatomic, strong) NSMutableArray *schemeList;

@end

@implementation QPPreference

- (instancetype)init {
    self = [super init];
    
    if (self) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:kPreference];
        
        self.projectDirectory = [dic objectForKey:kProjectDirectory];
        
        self.targetDirectory = [dic objectForKey:kTargetDirectory];

        self.schemeList = [[NSMutableArray alloc] init];

        NSArray *list = [dic objectForKey:kSchemes];
        if (list.count) {
            [self.schemeList addObjectsFromArray:list];
        }

        return self;
    }
    
    return nil;
}

- (NSString *)filePathOfOptionList {
    return [[NSBundle mainBundle] pathForResource:ExportOptions_File ofType:nil];
}

- (void)parseProjectFileName {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_projectDirectory
                                                                            error:nil];
    
    __block NSString *projectName = nil;
    __block NSString *workspaceName = nil;
    
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[obj pathExtension] isEqualToString:EXTENSION_WORKSPACE]) {
            workspaceName = obj;
        } else if ([[obj pathExtension] isEqualToString:EXTENSION_PROJECT]) {
            projectName = obj;
        }
    }];
    
    _workSpaceName = workspaceName;
    
    _projectName = projectName;
}

- (void)setProjectDirectory:(NSString *)aDirectory {
    _projectDirectory = aDirectory;
    
    if (_projectDirectory) {
        [self parseProjectFileName];
    }
}

- (NSArray *)schemes {
    return [NSArray arrayWithArray:_schemeList];
}

- (void)addScheme:(NSString *)aScheme {
    if ([_schemeList containsObject:aScheme]) {
        return;
    }
    
    [_schemeList addObject:aScheme];
}

- (void)removeScheme:(NSString *)aScheme {
    if (![_schemeList containsObject:aScheme]) {
        return;
    }
    
    [_schemeList removeObject:aScheme];
}

- (BOOL)containtScheme:(NSString *)aScheme {
    return [_schemeList containsObject:aScheme];
}

- (void)save {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (_projectDirectory)
       [dic setObject:_projectDirectory forKey:kProjectDirectory];
    
    if (_targetDirectory)
       [dic setObject:_targetDirectory forKey:kTargetDirectory];

    if (_schemeList.count)
        [dic setObject:_schemeList forKey:kSchemes];

    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kPreference];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
