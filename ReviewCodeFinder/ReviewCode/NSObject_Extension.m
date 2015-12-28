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
#import "Masonry.h"

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
    [pushButton setTitle:@"Review"];
    [pushButton setAction:@selector(buttonClick:)];
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    [superview addSubview:pushButton];
    NSButton *calBtn = [self ivarOfKey:@"_cancelButton"];
    NSEdgeInsets padding = NSEdgeInsetsMake(0, -100, 0, -100);
    [pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(calBtn.mas_top).with.offset(padding.top);
        make.left.equalTo(calBtn.mas_left).with.offset(padding.left);
        make.bottom.equalTo(calBtn.mas_bottom).with.offset(-padding.bottom);
        make.right.equalTo(calBtn.mas_right).with.offset(padding.right);
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