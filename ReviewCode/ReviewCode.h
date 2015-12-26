//
//  ReviewCode.h
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MCXcodeHeaders.h"

@class ReviewCode;

static ReviewCode *sharedPlugin;

@interface ReviewCode : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end

@interface NSWindowController(mc)
- (void)mc_windowDidLoad;
@end

@interface NSObject (fromatDescription)
- (NSDictionary *)fromatDescription;
- (id)ivarOfKey:(NSString *)key;
@end