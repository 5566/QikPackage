//
//  QPBuilder.h
//  QikPackage
//
//  Created by Jack on 16/5/3.
//  Copyright © 2016年 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QPPreference;

@interface QPBuilder : NSObject

+ (void)runWithOptions:(QPPreference *)aOptions
            usingBlock:(void (^)(NSString *progrssingInfo, BOOL isFinished))aBlock;

+ (void)parseSchemesAtProjectPath:(NSString *)aPath
                  completionBlock:(void (^)(NSArray<NSString *> *result))aBlock;
@end
