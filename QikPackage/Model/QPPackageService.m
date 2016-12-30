//
//  QPPackageService.m
//  QikPackage
//
//  Created by Jack on 2016/12/27.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import "QPPackageService.h"
#import "QPPreference.h"
#import "QPBuilder.h"

@interface QPPackageService ()

@property (nonatomic, strong) QPPreference *preference;

@property (nonatomic, strong) NSMutableArray *projectSchemes;

@end

@implementation QPPackageService

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _projectSchemes = [NSMutableArray array];
        
        _preference = [[QPPreference alloc] init];
        
        return self;
    }
    
    return nil;
}

+ (QPPackageService *)serviceWithDelegate:(id<QPPackageServiceDelegate>)aDelegate {
    QPPackageService *service = [[QPPackageService alloc] init];
    service.delegate = aDelegate;
    
    if (service.preference.projectDirectory) {
        [service parseSchemesOfProject:service.preference.projectDirectory];
    }
    
    return service;
}

- (void)run {
    if ([_delegate respondsToSelector:@selector(serviceWillStartPackage)]) {
        [_delegate serviceWillStartPackage];
    }
    
    [_preference save];
    
    [QPBuilder runWithOptions:_preference usingBlock:^(NSString *progrssingInfo, BOOL isFinished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(service:updateProgressInfo:)]) {
                [_delegate service:self updateProgressInfo:progrssingInfo];
            }
            
            if (isFinished && [_delegate respondsToSelector:@selector(service:packageDidFinished:)]) {
                [_delegate service:self packageDidFinished:self.targetPath];
            }
        });
    }];
}

- (NSString *)projectPath {
    return _preference.projectDirectory;
}

- (NSString *)targetPath {
    return _preference.targetDirectory;
}

- (void)setupProjectPath:(NSString *)aPath {
    _preference.projectDirectory = aPath;
    
    [_preference removeAllSchemes];
    
    [self parseSchemesOfProject:aPath];
}

- (void)setupTargetPath:(NSString *)aPath {
    _preference.targetDirectory = aPath;
}

- (void)parseSchemesOfProject:(NSString *)aPath {
    if ([_delegate respondsToSelector:@selector(serviceWillParseProjectSchemes)]) {
        [_delegate serviceWillParseProjectSchemes];
    }
    
    if ([_delegate respondsToSelector:@selector(service:updateProgressInfo:)]) {
        [_delegate service:self updateProgressInfo:@"正在获取Scheme信息..."];
    }
    
    [QPBuilder parseSchemesAtProjectPath:aPath completionBlock:^(NSArray<NSString *> *result) {
        _projectSchemes = [NSMutableArray arrayWithArray:result];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_delegate respondsToSelector:@selector(parseProjectSchemesDidFinished)]) {
                [_delegate parseProjectSchemesDidFinished];
            }
            
            if ([_delegate respondsToSelector:@selector(service:updateProgressInfo:)]) {
                [_delegate service:self updateProgressInfo:@"获取Scheme信息完成"];
            }
        });
        
    }];
}

- (void)addBuidingScheme:(NSString *)aScheme {
    [_preference addScheme:aScheme];
}

- (void)removeBuildingScheme:(NSString *)aScheme {
    [_preference removeScheme:aScheme];
}

- (BOOL)containtBuildingScheme:(NSString *)aScheme {
    return [_preference containtScheme:aScheme];
}

- (NSInteger)numberOfProjectSchemes {
    return _projectSchemes.count;
}

- (NSString *)titleOfSchemeAtIndex:(NSInteger)aIndex {
    if (_projectSchemes.count == 0) {
        return nil;
    }
    
    return _projectSchemes[aIndex];
}

@end
