//
//  reviewcode.m
//  reviewcode
//
//  Created by sunyanguo on 12/25/15.
//  Copyright © 2015 lvmama. All rights reserved.
//

#import "reviewcode.h"
#import <objc/runtime.h>

void swizzleDVTTextStorage()
{
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

@interface reviewcode()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation reviewcode

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationLog:) name:nil object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
        swizzleDVTTextStorage();
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Hello, World"];
    [alert runModal];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationLog:(NSNotification *)notify
{
    if ([@"IDEIndexWillIndexWorkspaceNotification" isEqualToString:notify.name]) {
        NSLog(@"%@",notify.object);
    }
//    NSLog(@"%@",notify);

}

@end

@implementation NSWindowController(mc)

- (void)mc_windowDidLoad{
    [self mc_windowDidLoad];
    NSButton *pushButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    pushButton.bezelStyle = NSRoundedBezelStyle;
    [pushButton  setTarget:self];
    [pushButton setAction:@selector(buttonClick:)];
    NSView *vvvv = [[self.window.contentView subviews] objectAtIndex:0];
    [vvvv addSubview:pushButton];
    [[vvvv subviews] enumerateObjectsUsingBlock:^(__kindof NSView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSButton class]] && idx == 1 ) {
            pushButton.frame = NSMakeRect(obj.frame.origin.x-obj.frame.size.width*2-20, obj.frame.origin.y, obj.frame.size.width, obj.frame.size.height);
            pushButton.layer.borderWidth = 1;
            pushButton.layer.borderColor = [NSColor colorWithDeviceHue:0.02 saturation:0.97 brightness:0.9 alpha:1].CGColor;
        }
    }];
    
}

- (void)buttonClick:(id)sender {
    NSLog(@"dacaiguoguo:\n%s\n%@",__func__,sender);
}
@end