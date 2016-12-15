//
//  ViewController.m
//  TestApp
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "ViewController.h"
#import "COMModalWindowController.h"
#import "COMPropsWindowController.h"
#import "COMPublishWindowController.h"
#import "COMSidebarViewController.h"

static COMModalWindowController *modalWindowController;
static COMPropsWindowController *propsWindowController;
static COMPublishWindowController *publishWindowController;

@interface ViewController ()

@property (nonatomic, strong) COMModalWindowController *obj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    static COMSidebarViewController *viewController;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        viewController = [[COMSidebarViewController alloc] init];
//        NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
//                             stringByAppendingString:@"/Contents/Resources/COMSidebarViewController.nib"];
//        [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:viewController
//                                                                                                 topLevelObjects:nil];
//    });
//    viewController.view.frame = NSMakeRect(0, 0, 100, 100);
//    [self.view addSubview:viewController.view];
}

@end
