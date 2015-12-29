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
    NSString *workpath = [self workSpacePath];
    Taskit *task = [Taskit task];
    task.launchPath = @"/bin/sh";
    [task.arguments  addObjectsFromArray:@[@"-c",
                                           @"svn info | grep URL"]];
    task.workingDirectory = workpath;
    __block BOOL isOurSvnProject = NO;
    task.receivedOutputString = ^void(NSString *output) {
        NSLog(@"output:%@", output);
        isOurSvnProject = ([output rangeOfString:@"192.168.0.7/svn/client/"].location != NSNotFound);
    };
    [task launch];
    [task waitUntilExit];
    if (!isOurSvnProject) {
        return;
    }
    
    NSButton *pushButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    [pushButton setBezelStyle:NSRoundedBezelStyle];
    [pushButton setTarget:self];
    [pushButton setTitle:@"Review"];
    [pushButton setAction:@selector(buttonClick:)];
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    [superview addSubview:pushButton];
    NSButton *calBtn = [self ivarOfKey:@"_cancelButton"];
    [pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(calBtn.mas_top).with.offset(0);
        make.right.equalTo(calBtn.mas_left).with.offset(-10);
        make.width.equalTo(calBtn.mas_width);
        make.height.equalTo(calBtn.mas_height);
    }];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    [superview addSubview:textField];
    textField.tag = 22;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pushButton.mas_top).with.offset(0);
        make.right.equalTo(pushButton.mas_left).with.offset(-10);
        make.width.equalTo(pushButton.mas_width);
        make.height.equalTo(pushButton.mas_height);
    }];
//    _Pragma("clang diagnostic push")
//    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
//    id ret = [self performSelector:NSSelectorFromString(@"defaultCheckedFilePaths") withObject:nil];
//    _Pragma("clang diagnostic pop")
}

- (NSString *)workSpacePath {
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        workSpace = [controller valueForKey:@"_workspace"];
    }
    
    NSString *workspacePath = [[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    workspacePath = [workspacePath stringByDeletingLastPathComponent];
    return workspacePath;
}

- (void)buttonClick:(id)sender {
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    NSTextField *test = [superview viewWithTag:22];
    NSString *people = [test stringValue];
    if (people.length < 3) {
        return;
    }
    NSString *commitMessageTemp = [self ivarOfKey:@"_commitMessage"];
    if (commitMessageTemp.length < 3) {
        return;
    }
    NSArray *checkedFilePathsTemp = [[[self ivarOfKey:@"_checkedFilePathsToken2"] ivarOfKey:@"_observedObject"] ivarOfKey:@"_checkedFilePaths"];
    NSMutableArray *mutPathsArray = [NSMutableArray new];
    [checkedFilePathsTemp enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *path = [obj ivarOfKey:@"_pathString"];
        if (path) {
            [mutPathsArray addObject:path];
        }
    }];
    if (mutPathsArray.count == 0) {
        return;
    }
    NSLog(@"%@",mutPathsArray);
    NSString *workpath = [self workSpacePath];
    Taskit *task = [Taskit task];
    task.launchPath = @"/usr/local/bin/rbt";
    task.workingDirectory = workpath;
    [task.arguments addObjectsFromArray:@[
                                          @"post",
                                          @"--svn-username",
                                          @"sunyanguo",
                                          @"--svn-password",
                                          @"password",
                                          @"--username",
                                          @"sunyanguo",
                                          @"--password",
                                          @"password",
                                          @"-p",
                                          @"--target-people",
                                          people,
                                          @"--summary",
                                          commitMessageTemp]];
    [task launch];
    [task waitUntilExit];
    [self close];
}

@end