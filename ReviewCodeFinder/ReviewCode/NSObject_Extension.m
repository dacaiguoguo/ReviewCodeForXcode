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

- (id)mc_sourcePath {
    id art = [self mc_sourcePath];
    NSLog(@"art:%@", art);
    return art;
}

@end

@implementation NSManagedObject(xxxx)

- (id)mc_provisioningProfiles {
    id art = [self mc_provisioningProfiles];
    NSLog(@"mc_provisioningProfiles:%@", art);
    return art;
}

@end

@implementation NSWindowController(mc)

- (void)mc_windowDidLoad{
    [self mc_windowDidLoad];
    NSButton *reviewButton = [[NSButton alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    [reviewButton setBezelStyle:NSRoundedBezelStyle];
    [reviewButton setTarget:self];
    [reviewButton setTitle:@"Review"];
    [reviewButton setAction:@selector(buttonClick:)];
    NSView *superview = [[self.window.contentView subviews] objectAtIndex:0];
    [superview addSubview:reviewButton];
    NSButton *calBtn = [self ivarOfKey:@"_cancelButton"];
    [reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(calBtn.mas_top).with.offset(0);
        make.right.equalTo(calBtn.mas_left).with.offset(-10);
        make.width.equalTo(calBtn.mas_width);
        make.height.equalTo(calBtn.mas_height);
    }];
    
    NSTextField *peopleTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(100, 100, 100, 100)];
    [superview addSubview:peopleTextField];
    peopleTextField.tag = 22;
    [peopleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(reviewButton.mas_top).with.offset(0);
        make.right.equalTo(reviewButton.mas_left).with.offset(-10);
        make.width.equalTo(reviewButton.mas_width).with.offset(100);
        make.height.equalTo(reviewButton.mas_height);
    }];
}

- (NSString *)workSpacePath {
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") ivarOfKey:@"workspaceWindowControllers"];
    id workSpace;
    for (id controller in workspaceWindowControllers) {
        workSpace = [controller ivarOfKey:@"_workspace"];
    }
    NSString *workspacePath = [[workSpace ivarOfKey:@"representingFilePath"] ivarOfKey:@"_pathString"];
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
    NSArray *peoples = [people componentsSeparatedByString:@","];
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
    NSLog(@"%@",mutPathsArray);
    NSString *workpath = [self workSpacePath];
    NSLog(@"%@",workpath);
    [self createReviewboardrcAtPath:workpath];
    [self postWithPathArray:mutPathsArray peopleArray:peoples summary:commitMessageTemp atWorkPath:workpath];
    [self close];
}

- (void)createReviewboardrcAtPath:(NSString *)workpath {
    Taskit *task = [Taskit task];
    task.launchPath = @"/bin/sh";
    task.workingDirectory = workpath;
    [task.arguments  addObjectsFromArray:@[@"-c",
                                           @"ls -a| grep .reviewboardrc"]];
    task.workingDirectory = workpath;
    __block BOOL isHadReviewrc = NO;
    task.receivedOutputString = ^void(NSString *output) {
        NSLog(@"output:%@", output);
        isHadReviewrc = ([output rangeOfString:@".reviewboardrc"].location != NSNotFound);
    };
    task.receivedErrorString = ^void(NSString *output) {
        NSLog(@"outputError:%@", output);
    };
    [task launch];
    [task waitUntilExitWithTimeout:.5];
    if (!isHadReviewrc) {
        Taskit *task = [Taskit task];
        task.launchPath = @"/bin/sh";
        task.workingDirectory = workpath;
        [task.arguments  addObjectsFromArray:@[@"-c",
                                               @"Yes |rbt setup-repo --server http://192.168.0.23"]];
        task.workingDirectory = workpath;
        task.receivedOutputString = ^void(NSString *output) {
            NSLog(@"output:%@", output);
        };
        [task launch];
        [task waitUntilExitWithTimeout:.5];
    }
}

- (void)postWithPathArray:(NSArray *)mutPathsArray peopleArray:(NSArray *)peopleArray summary:(NSString *)summary atWorkPath:(NSString *)workpath {
    NSString *people = peopleArray[0];
    NSMutableArray *mutParamArray = [NSMutableArray new];
    [mutParamArray addObjectsFromArray:@[
                                         @"post",
                                         @"--svn-username",
                                         @"sunyanguo",
                                         @"--svn-password",
                                         @"password",
                                         @"--username",
                                         @"sunyanguo",
                                         @"--password",
                                         @"password",
                                         //@"-p",//是否发布
                                         @"--open",
                                         @"--stamp",
                                         @"--target-people",
                                         people,
                                         @"--summary",
                                         summary]];
    for (int i=0; i< mutPathsArray.count; i++) {
        [mutParamArray addObject:@"-I"];
        NSString *absPath = mutPathsArray[i];
        NSString *rrrPath = [absPath substringFromIndex:workpath.length+1];
        [mutParamArray addObject:rrrPath];
    }
    NSLog(@"%@",mutParamArray);
    Taskit *task = [Taskit task];
    task.launchPath = @"/usr/local/bin/rbt";
    task.workingDirectory = workpath;
    [task.arguments addObjectsFromArray:mutParamArray];
    task.receivedOutputString = ^void(NSString *output) {
        NSLog(@"output11:%@", output);
    };
    task.receivedErrorString = ^void(NSString *output) {
        NSLog(@"outputError22:%@", output);
    };
    [task launch];
    [task waitUntilExit];
}

- (NSViewController *)mc_contentViewController {
    NSViewController *ccc = [self mc_contentViewController];
    NSLog(@"mc_contentViewController:%@",ccc);
    return ccc;
}

- (void)mc_devicesWindowDidLoad {
    [self mc_devicesWindowDidLoad];
    NSView *vvvv = [self ivarOfKey:@"_consoleHeaderTabChooserView"];
    CALayer *viewLayer = [CALayer layer];
    [viewLayer setBackgroundColor:CGColorCreateGenericRGB(209./255, 209./255, 209./255, 1)];
    [vvvv setWantsLayer:YES];
    [vvvv setLayer:viewLayer];
    NSLog(@"mc_devicesWindowDidLoad:%@",NSStringFromRect(vvvv.frame));
    
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
/*
/usr/local/bin/rbt post --svn-username sunyanguo --svn-password password --username sunyanguo --password password --target-people zhouyi --summary "reserved.sss  5555555" -I /Users/sunyanguo/Dropbox/CodePace/lvmama_iphone741/Lvmm/AppDelegate.m
 
 */