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
//        swizzleXMethod(@"IDESourceControlCommitWindowController", @"windowDidLoad", @"mc_windowDidLoad");
//        swizzleXMethod(@"IDEWorkspaceTabController", @"refreshConnectionsData:", @"mc_refreshConnectionsData:");
//        swizzleXMethod(@"IDEAssistantWindowController", @"windowDidLoad:", @"mc_windowDidLoad:");
        swizzleXMethod(@"IDEWorkspaceTabController", @"viewDidAppear", @"mc_viewDidAppear");
        swizzleXMethod(@"NSViewController", @"viewDidAppear", @"mc_viewDidAppear");
        swizzleXMethod(@"IDENavigatorOutlineView", @"mouseDown:", @"mc_mouseDown:");
        swizzleXMethod(@"IDENavigatorOutlineView", @"updateBoundSelectedObjects", @"mc_updateBoundSelectedObjects");
        swizzleXMethod(@"IDEStructureNavigator", @"_setSelectedItemsFromNameTree:", @"mc_setSelectedItemsFromNameTree:");
        swizzleXMethod(@"IDEOutlineBasedNavigator", @"contextMenuSelection", @"mc_contextMenuSelection");



        swizzleXMethod(@"NSWindowController", @"close", @"mc_close");
        swizzleXMethod(@"NSWindowController", @"windowDidLoad", @"mss_windowDidLoad");





//        swizzleXMethod(@"NSViewController", @"capsuleListView:didExpandRow:", @"mc_capsuleListView:didExpandRow:");

//        swizzleXMethod(@"DVTSourceTextView", @"foldAllMethods:", @"mc_foldAllMethods:");

        
//        swizzleXMethod(@"NSViewController", @"viewDidLoad", @"mc_viewDidLoad");
    }
    return self;
}

@end

void swizzleXMethod(NSString *className, NSString *selectorOrgString,NSString *selectorToString) {
    Class toSwizzleClass = NSClassFromString(className);
//    id obj = [toSwizzleClass new];
//    NSLog(@"%@", obj);
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
