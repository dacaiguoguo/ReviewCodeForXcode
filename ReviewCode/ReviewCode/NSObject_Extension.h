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
@end

@interface NSView (Dumping)
-(void)dumpWithIndent:(NSString *)indent;
@end

@interface MCLog : NSObject
@end

@interface NSObject (fromatDescription)
- (NSDictionary *)fromatDescription;
- (id)ivarOfKey:(NSString *)key;
- (id)mc_sourcePath;
@end

@interface NSWindowController(mc)
- (void)mc_close;
- (void)mss_windowDidLoad;
- (void)mc_windowDidLoad;
- (void)mc_devicesWindowDidLoad;
- (void)mc_showPreferencesPanel:(id)arg1;
@end

@interface NSViewController(mc)
- (void)mc_viewDidLoad;
- (void)mc_viewDidAppear;
//swizzleXMethod(@"Xcode3CopyFilesBuildPhaseViewController", @"viewDidAppear", @"mc_viewDidAppear");

@end

@interface NSTextView(mc)
- (void)mc_foldAllMethods:(id)arg1;
@end

