//
//  NSObject_Extension.h
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppKit;
@import CoreData;

@interface NSObject (Xcode_Plugin_Template_Extension)
+ (void)pluginDidLoad:(NSBundle *)plugin;
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
@interface NSManagedObject(xxxx)

- (id)mc_provisioningProfiles;

@end

@interface NSWindowController(mc)
- (void)mc_windowDidLoad;
- (void)mc_devicesWindowDidLoad;
- (void)mc_showPreferencesPanel:(id)arg1;
@end
