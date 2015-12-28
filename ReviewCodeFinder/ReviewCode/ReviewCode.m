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

void swizzleDVTTextStorage();


@interface ReviewCode()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation ReviewCode

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;
        swizzleDVTTextStorage();
    }
    return self;
}

@end


void swizzleDVTTextStorage() {
    Class IDESourceControlCommitWindowController = NSClassFromString(@"IDESourceControlCommitWindowController");
    Method fixAttributesInRange = class_getInstanceMethod(IDESourceControlCommitWindowController, @selector(windowDidLoad));
    Method swizzledFixAttributesInRange = class_getInstanceMethod(IDESourceControlCommitWindowController, @selector(mc_windowDidLoad));
    
    BOOL didAddMethod = class_addMethod(IDESourceControlCommitWindowController, @selector(windowDidLoad), method_getImplementation(swizzledFixAttributesInRange), method_getTypeEncoding(swizzledFixAttributesInRange));
    if (didAddMethod) {
        class_replaceMethod(IDESourceControlCommitWindowController, @selector(mc_windowDidLoad), method_getImplementation(fixAttributesInRange), method_getTypeEncoding(swizzledFixAttributesInRange));
    } else {
        method_exchangeImplementations(fixAttributesInRange, swizzledFixAttributesInRange);
    }
}
