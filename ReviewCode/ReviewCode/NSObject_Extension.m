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

- (id)mc_sourcePath {
    id art = [self mc_sourcePath];
    NSLog(@"art:%@", art);
    return art;
}

@end

@implementation NSWindowController(mc)

- (void)mc_windowDidLoad {
    [self mc_windowDidLoad];
    NSButton *reviewButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    [reviewButton setBezelStyle:NSRoundedBezelStyle];
    [reviewButton setTarget:self];
    [reviewButton setTitle:@"Review"];
    [reviewButton setAction:@selector(buttonClick:)];
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    [superview addSubview:reviewButton];
    
    NSButton *switchButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    [switchButton setButtonType:NSSwitchButton];
    [switchButton setBezelStyle:NSRoundedBezelStyle];
    [switchButton setTarget:self];
    switchButton.tag = 88;
    [switchButton setTitle:@"only .h .m"];
    [switchButton setAction:@selector(switchClick:)];
    [superview addSubview:switchButton];
    
    
    NSButton *calBtn = [self ivarOfKey:@"_cancelButton"];
    [reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(calBtn.mas_top).with.offset(0);
        make.right.equalTo(calBtn.mas_left).with.offset(-20);
        make.width.equalTo(calBtn.mas_width);
        make.height.equalTo(calBtn.mas_height);
    }];
    
    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reviewButton.mas_top).with.offset(0);
        make.right.equalTo(reviewButton.mas_left).with.offset(-300);
        make.width.equalTo(reviewButton.mas_width);
        make.height.equalTo(reviewButton.mas_height);
    }];
    
    NSTextField *peopleTextField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [superview addSubview:peopleTextField];
    peopleTextField.tag = 22;
    peopleTextField.accessibilityIdentifier = [self workSpacePath];
    [peopleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reviewButton.mas_top).with.offset(0);
        make.right.equalTo(reviewButton.mas_left).with.offset(-10);
        make.width.equalTo(reviewButton.mas_width).with.offset(100);
        make.height.equalTo(reviewButton.mas_height);
    }];
}

- (NSString *)workSpacePath {
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        if ([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]) {
            workSpace = [controller valueForKey:@"_workspace"];
        }
    }
    NSString *retPath = [[[workSpace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"] stringByDeletingLastPathComponent];
    if ([[retPath lastPathComponent] isEqualToString:@"Example"]) {
        retPath = [retPath stringByDeletingLastPathComponent];
    }
    return retPath;
}

- (void)switchClick:(NSButton *)sender {
    NSLog(@"%ld",(long)sender.state);
}

- (void)buttonClick:(id)sender {
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    NSTextField *test = [superview viewWithTag:22];
    NSString *people = [test stringValue];
    if (people.length < 3) {
        return;
    }
    NSArray *peoples;
    NSString *updateId;
    NSArray *toParams = [people componentsSeparatedByString:@"|"];
    if (toParams.count > 0) {
        peoples = [[toParams objectAtIndex:0] componentsSeparatedByString:@","];
    } else {
        return;
    }
    if (toParams.count > 1) {
        updateId = [[toParams objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    NSString *commitMessageTemp = [self ivarOfKey:@"_commitMessage"];
    if (commitMessageTemp.length < 3) {
        return;
    }
    NSArray *checkedFilePathsTemp = [[[self ivarOfKey:@"_checkedFilePathsToken2"]
                                            ivarOfKey:@"_observedObject"]
                                            ivarOfKey:@"_checkedFilePaths"];
    NSMutableArray *mutPathsArray = [NSMutableArray new];
    [checkedFilePathsTemp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *path = [obj ivarOfKey:@"_pathString"];
        if (path) {
            [mutPathsArray addObject:path];
        }
    }];
    if (mutPathsArray.count == 0) {
        return;
    }
    NSString *workpath = test.accessibilityIdentifier;
    if (workpath.length == 0) {
        return;
    }
    NSLog(@"accessibilityIdentifier:%@",workpath);
    [self postWithPathArray:mutPathsArray peopleArray:peoples summary:commitMessageTemp atWorkPath:workpath updateId:updateId];
}

- (void)postWithPathArray:(NSArray *)mutPathsArray peopleArray:(NSArray *)peopleArray summary:(NSString *)summary atWorkPath:(NSString *)workpath updateId:(NSString *)updateId {
    if (peopleArray.count == 0||mutPathsArray.count == 0|| summary.length < 3) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"error"];
        [alert setInformativeText:@"请填写Review者名字"];
        [alert runModal];
        return;
    }
    if (mutPathsArray.count == 0|| summary.length < 3) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"error"];
        [alert setInformativeText:@"请选择要review的文件"];
        [alert runModal];
        return;
    }
    if (summary.length < 3) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"error"];
        [alert setInformativeText:@"请填写Review概述"];
        [alert runModal];
        return;
    }
    NSString *peoples = [peopleArray componentsJoinedByString:@","];
    //--review-request-id ID
    NSMutableArray *mutParamArray = [NSMutableArray new];
    

    NSDictionary *configDic = [NSDictionary dictionaryWithContentsOfFile:[[ReviewCode sharedPlugin].bundle pathForResource:@"ReviewCodeConfig" ofType:@"plist"]];
    NSString *svnUserName = configDic[@"svnusername"];
    NSString *svnPassword = configDic[@"svnpassword"];
    NSString *reviewboardUsername = configDic[@"reviewboardusername"];
    NSString *reviewboardPassword = configDic[@"reviewboardpassword"];
    if (!svnUserName||!svnPassword || !reviewboardUsername || !reviewboardPassword) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"error"];
        [alert setInformativeText:@"账号配置不完整"];
        [alert runModal];
        return;
    }
    [mutParamArray addObjectsFromArray:@[@"post",
                                         @"--svn-username",
                                         svnUserName,
                                         @"--svn-password",
                                         svnPassword,// password 首字母为 - 时会找不到password
                                         @"--username",
                                         reviewboardUsername,
                                         @"--password",
                                         reviewboardPassword,
                                         @"-p",
                                         @"--open",
                                         @"--target-people",
                                         peoples,
                                         @"--summary",
                                         [summary stringByReplacingOccurrencesOfString:@"\n" withString:@" "],
                                         @"--description",
                                         summary
                                         ]];
    if (updateId.length > 0) {
        [mutParamArray addObjectsFromArray:@[@"--review-request-id",updateId]];
    }
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    NSButton *testSwitch = [superview viewWithTag:88];
    for (int i=0; i< mutPathsArray.count; i++) {
        NSString *absPath = mutPathsArray[i];
        if (testSwitch.state == 1  && (![[absPath pathExtension] isEqualToString:@".h"]) && (![[absPath pathExtension] isEqualToString:@".m"])) {
            continue;
        }
        [mutParamArray addObject:@"-I"];
        NSString *rrrPath = [absPath substringFromIndex:workpath.length+1];
        [mutParamArray addObject:rrrPath];
    }
    NSLog(@"mutParamArray:%@",mutParamArray);
    Taskit *task = [Taskit task];
    task.launchPath = @"/usr/local/bin/rbt";
    task.workingDirectory = workpath;
    [task.arguments addObjectsFromArray:mutParamArray];
    task.receivedOutputString = ^void(NSString *output) {
        NSLog(@"output2:%@", output);
    };
    task.receivedErrorString = ^void(NSString *output) {
        NSLog(@"outputError2:%@", output);
        if ([output hasSuffix:@""]) {
            return;
        }
        if (output.length > 0) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"error"];
            [alert setInformativeText:output];
            [alert runModal];
        }
    };
    [task launch];
    BOOL hitTimeout = [task waitUntilExitWithTimeout:300];
    if (hitTimeout) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"error"];
        [alert setInformativeText:@"hitTimeout"];
        [alert runModal];
    }
    _Pragma("clang diagnostic push")
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
    [self performSelector:NSSelectorFromString(@"cancel:") withObject:nil];
    _Pragma("clang diagnostic pop")
}

- (NSViewController *)mc_contentViewController {
    NSViewController *ccc = [self mc_contentViewController];
    NSLog(@"mc_contentViewController:%@",ccc);
    return ccc;
}

- (void)mc_devicesWindowDidLoad {
    [self mc_devicesWindowDidLoad];
    NSView *consoleHeaderView = [self ivarOfKey:@"_consoleHeaderTabChooserView"];
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(209./255, 209./255, 209./255, 1)];
    [consoleHeaderView setWantsLayer:YES];
    [consoleHeaderView setLayer:viewLayer];
}

- (void)mc_showPreferencesPanel:(id)arg1 {
    NSLog(@"mc_contentViewController:%@",arg1);
    [self mc_showPreferencesPanel:arg1];
} 

- (void)mc_preferWindowDidLoad {
    [self mc_preferWindowDidLoad];
    NSLog(@"mc_contentViewController:%@",self);
}

@end

@implementation NSViewController (mc)

- (void)mc_viewDidLoad {
    [self mc_viewDidLoad];
    NSView *____view = [self ivarOfKey:@"_view"];
    [____view dumpWithIndent:@""];
    NSLog(@"mc_viewDidLoad:%@",self);
    if ([self isKindOfClass:NSClassFromString(@"IDETemplateOptionsAssistant")]) {
        
        u_int               count;
        Method*    methods= class_copyMethodList([self class], &count);
        for (int i = 0; i < count ; i++)
        {
            SEL name = method_getName(methods[i]);
            NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
            NSLog(@"%@",strName);
        }
    }
}

- (void)mc_viewDidAppear {
    [self mc_viewDidAppear];
    NSLog(@"mc_viewDidAppear:%@",self);
    if ([self.description rangeOfString:@"Xcode3CompileSourcesBuildPhaseViewController"].location != NSNotFound) {
        double delayInSeconds = 2.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            id groupte= [self valueForKey:@"_group"];
            NSArray *childNodes = [groupte valueForKey:@"_childNodes"];
            NSMutableArray *mutArray = [NSMutableArray new];
            [childNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
//                NSString *foless =  [[[obj2 valueForKey:@"_buildFile"] valueForKey:@"_buildInfo"] valueForKey:@"_entityIdent"];
                NSString * aadf = [obj2 description];
                id toadd = [[aadf componentsSeparatedByString:@":"] lastObject];
                if (toadd) {
                    [mutArray addObject:toadd];
                } else {
                    NSLog(@"folessfoless:%@",obj2);
                }
            }];
            [mutArray writeToFile:@"/Users/sunyanguo/Desktop/groupCom/commm.plist" atomically:YES];
        });
    }

    if ([self.description rangeOfString:@"Xcode3ResourcesBuildPhaseViewController"].location != NSNotFound) {
        double delayInSeconds = 3.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            id groupte= [self valueForKey:@"_group"];
            NSArray *childNodes = [groupte valueForKey:@"_childNodes"];
            NSMutableArray *mutArray = [NSMutableArray new];
            [childNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                //                NSString *foless =  [[[obj2 valueForKey:@"_buildFile"] valueForKey:@"_buildInfo"] valueForKey:@"_entityIdent"];
                NSString * aadf = [obj2 description];
                id toadd = [[aadf componentsSeparatedByString:@":"] lastObject];
                if (toadd) {
                    [mutArray addObject:toadd];
                } else {
                    NSLog(@"folessfolessRs:%@",obj2);
                }
            }];
            [mutArray writeToFile:@"/Users/sunyanguo/Desktop/groupCom/commm.plist" atomically:YES];
            
        });
    }
}

- (void)mc_capsuleListView:(id)arg1 didExpandRow:(long long)arg2 {
    [self mc_capsuleListView:arg1 didExpandRow:arg2];
    NSLog(@"mc_capsuleListView:%@--%lld",arg1,arg2);
}

@end

@implementation NSTextView(mc)

- (void)mc_foldAllMethods:(id)arg1 {
    NSLog(@"mc_foldAllMethods:%@",arg1);
    [self mc_foldAllMethods:arg1];
}

@end