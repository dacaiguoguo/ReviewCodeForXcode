//
//  NSObject_Extension.m
//  reviewcode
//
//  Created by sunyanguo on 12/25/15.
//  Copyright © 2015 lvmama. All rights reserved.
//


#import "NSObject_Extension.h"
#import "reviewcode.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[reviewcode alloc] initWithBundle:plugin];
        });
    }
}
@end
