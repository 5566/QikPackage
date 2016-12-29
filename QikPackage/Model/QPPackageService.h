//
//  QPPackageService.h
//  QikPackage
//
//  Created by Jack on 2016/12/27.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QPPackageService;

@protocol QPPackageServiceDelegate <NSObject>

- (void)service:(QPPackageService *)aService packageDidFinished:(NSString *)aTarget;

- (void)service:(QPPackageService *)aService updateProgressInfo:(NSString *)aInfo;

- (void)parseProjectSchemesDidFinished;

- (void)serviceWillParseProjectSchemes;

- (void)serviceWillStartPackage;

@end

@interface QPPackageService : NSObject

@property (nonatomic, weak) id <QPPackageServiceDelegate> delegate;

@property (nonatomic, readonly) NSString *projectPath;

@property (nonatomic, readonly) NSString *targetPath;

+ (QPPackageService *)serviceWithDelegate:(id<QPPackageServiceDelegate>)aDelegate;

- (void)run;

- (void)setupProjectPath:(NSString *)aPath;

- (void)setupTargetPath:(NSString *)aPath;

- (void)addBuidingScheme:(NSString *)aScheme;

- (void)removeBuildingScheme:(NSString *)aScheme;

- (BOOL)containtBuildingScheme:(NSString *)aScheme;

- (NSInteger)numberOfProjectSchemes;

- (NSString *)titleOfSchemeAtIndex:(NSInteger)aIndex;

@end
