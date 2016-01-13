//
//  ReviewCode.m
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
//

#import "ReviewCode.h"
#import <objc/runtime.h>
#import "NSObject_Extension.h"

void swizzleXMethod(NSString *className, NSString *selectorOrgString,NSString *selectorToString);

@interface ReviewCode()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation ReviewCode

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if ([currentApplicationName hasPrefix:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;
        swizzleXMethod(@"IDESourceControlCommitWindowController", @"windowDidLoad", @"mc_windowDidLoad");
        swizzleXMethod(@"DVTDevicesWindowController", @"windowDidLoad", @"mc_devicesWindowDidLoad");
//        swizzleXMethod(@"NSViewController", @"viewDidLoad", @"mc_viewDidLoad");
    }
    return self;
}

@end

void swizzleXMethod(NSString *className, NSString *selectorOrgString,NSString *selectorToString) {
    Class toSwizzleClass = NSClassFromString(className);
    SEL orgSel = NSSelectorFromString(selectorOrgString);
    SEL toSel = NSSelectorFromString(selectorToString);

    Method orgMethod = class_getInstanceMethod(toSwizzleClass, orgSel);
    Method toMethod = class_getInstanceMethod(toSwizzleClass, toSel);
    
    BOOL didAddMethod = class_addMethod(toSwizzleClass, orgSel, method_getImplementation(toMethod), method_getTypeEncoding(toMethod));
    if (didAddMethod) {
        class_replaceMethod(toSwizzleClass, toSel, method_getImplementation(orgMethod), method_getTypeEncoding(toMethod));
    } else {
        method_exchangeImplementations(orgMethod, toMethod);
    }
}
