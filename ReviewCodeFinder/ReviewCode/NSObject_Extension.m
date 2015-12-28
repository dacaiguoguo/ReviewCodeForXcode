//
//  NSObject_Extension.m
//  ReviewCode
//
//  Created by sunyanguo on 12/26/15.
//  Copyright © 2015 sunyanguo. All rights reserved.
//


#import "NSObject_Extension.h"
#import "ReviewCode.h"
#import <objc/runtime.h>
#import "Taskit.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[ReviewCode alloc] initWithBundle:plugin];
        });
    }
}
@end

@implementation NSView (Dumping)

-(void)dumpWithIndent:(NSString *)indent {
    NSString *clazz = NSStringFromClass([self class]);
    NSString *info = @"";
    if ([self respondsToSelector:@selector(title)]) {
        NSString *title = [self performSelector:@selector(title)];
        if (title != nil && [title length] > 0)
            info = [info stringByAppendingFormat:@" title=%@", title];
    }
    if ([self respondsToSelector:@selector(stringValue)]) {
        NSString *string = [self performSelector:@selector(stringValue)];
        if (string != nil && [string length] > 0)
            info = [info stringByAppendingFormat:@" stringValue=%@", string];
    }
    NSString *tooltip = [self toolTip];
    if (tooltip != nil && [tooltip length] > 0)
        info = [info stringByAppendingFormat:@" tooltip=%@", tooltip];
    
    NSLog(@"%@%@%@", indent, clazz, info);
    
    if ([[self subviews] count] > 0) {
        NSString *subIndent = [NSString stringWithFormat:@"%@%@", indent, ([indent length]/2)%2==0 ? @"| " : @": "];
        for (NSView *subview in [self subviews])
            [subview dumpWithIndent:subIndent];
    }
}

@end

@implementation MCLog

-(void)dumpWithView:(NSView *)view {
    [view dumpWithIndent:@""];
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