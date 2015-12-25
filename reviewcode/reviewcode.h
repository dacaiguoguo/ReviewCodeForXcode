//
//  reviewcode.h
//  reviewcode
//
//  Created by sunyanguo on 12/25/15.
//  Copyright © 2015 lvmama. All rights reserved.
//

#import <AppKit/AppKit.h>

@class reviewcode;

static reviewcode *sharedPlugin;

@interface reviewcode : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end