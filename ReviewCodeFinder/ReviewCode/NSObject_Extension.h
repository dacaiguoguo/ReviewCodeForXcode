//
//  NSObject_Extension.h
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;

@interface NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin;


@end

@interface NSView (Dumping)
-(void)dumpWithIndent:(NSString *)indent;
@end

@interface MCLog : NSObject

@end
