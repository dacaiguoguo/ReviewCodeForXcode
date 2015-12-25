//
//  NSObject_Extension.h
//  reviewcode
//
//  Created by sunyanguo on 12/25/15.
//  Copyright © 2015 lvmama. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;
#import "MCXcodeHeaders.h"


@interface NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin;


@end

@interface NSView (Dumping)

@end

@interface MCLog : NSObject 

@end


