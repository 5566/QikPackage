//
//  QPPreference.h
//  QikPackage
//
//  Created by Jack on 16/4/28.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPPreference : NSObject

@property (nonatomic, strong) NSString *projectDirectory;

@property (nonatomic, strong) NSString *targetDirectory;

@property (nonatomic, readonly, strong) NSString *workSpaceName;

@property (nonatomic, readonly, strong) NSString *projectName;

@property (nonatomic, readonly) NSString *filePathOfOptionList;

@property (nonatomic, readonly, strong) NSArray *schemes;

- (void)save;

- (void)addScheme:(NSString *)aScheme;

- (void)removeScheme:(NSString *)aScheme;

- (BOOL)containtScheme:(NSString *)aScheme;

@end
