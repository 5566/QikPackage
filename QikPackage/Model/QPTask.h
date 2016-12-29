//
//  QPTask.h
//  QikPackage
//
//  Created by Jack on 2016/12/28.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QPTask : NSObject

- (instancetype)initWithCurrentDirectPath:(NSString *)aPath;

@end

@interface QPArchiver : QPTask

- (void)archiveToPath:(NSString *)aPath
        withWorkspace:(NSString *)aWorkspace
              project:(NSString *)aProject
               scheme:(NSString *)aScheme;
@end

@interface QPExporter : QPTask

- (void)exportAtPath:(NSString *)aPath withOptionsFile:(NSString *)aPath;

@end

@interface QPSchemeParser : QPTask

- (NSArray *)parseSchemes;

@end
