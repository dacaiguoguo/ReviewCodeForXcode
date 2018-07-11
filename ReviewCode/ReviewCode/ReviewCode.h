//
//  ReviewCode.h
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
// 

#import <AppKit/AppKit.h>
extern void swizzleXMethod(NSString *className, NSString *selectorOrgString,NSString *selectorToString);
@class ReviewCode;

static ReviewCode *sharedPlugin;

@interface ReviewCode : NSObject
@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@end


