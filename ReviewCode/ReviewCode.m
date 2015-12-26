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


id ivarOfObject(id obj, NSString* key) {
    id value;
    @try {
        value = [obj valueForKey:key];
    }@catch (NSException *exception) {}@finally {}
    return value;
}


@interface ReviewCode()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation ReviewCode

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
    [pushButton setTitle:@"review"];
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
    id checkedFilePathsTokenTemp = [self ivarOfKey:@"_checkedFilePathsToken2"];
    id observedObjectTemp = [checkedFilePathsTokenTemp ivarOfKey:@"_observedObject"];
    NSArray *checkedFilePathsTemp = [observedObjectTemp ivarOfKey:@"_checkedFilePaths"];
    [checkedFilePathsTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = [obj ivarOfKey:@"_pathString"];
        NSLog(@"%@",path);
    }];
}

@end

@implementation NSObject (fromatDescription)

- (NSDictionary *)fromatDescription {
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    Class cls = [self class];
    unsigned int ivarsCnt = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        id value;
        @try {
            value = [self valueForKey:key];
        }@catch (NSException *exception) {}@finally {}
        if (value) {
            [dictionaryFormat setObject:value forKey:key];
        }
    }
    return dictionaryFormat;
}

- (id)ivarOfKey:(NSString *)key {
    id value;
    @try {
        value = [self valueForKey:key];
    }@catch (NSException *exception) {}@finally {}
    return value;
}

@end