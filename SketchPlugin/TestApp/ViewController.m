//
//  ViewController.m
//  TestApp
//
//  Created by 崔明辉 on 2016/12/7.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "ViewController.h"
#import "COMComponentWindowController.h"
#import "COMPublishWindowController.h"
#import "COMPropsViewController.h"

static COMComponentWindowController *modalWindowController;
static COMPublishWindowController *publishWindowController;

@interface ViewController ()

@property (nonatomic, strong) COMComponentWindowController *obj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    static COMPropsViewController *viewController;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        viewController = [[COMPropsViewController alloc] init];
//        NSString *nibPath = [[[NSBundle bundleForClass:[self class]] bundlePath]
//                             stringByAppendingString:@"/Contents/Resources/COMPropsViewController.nib"];
//        [[[NSNib alloc] initWithNibData:[NSData dataWithContentsOfFile:nibPath] bundle:nil] instantiateWithOwner:viewController
//                                                                                                 topLevelObjects:nil];
//    });
//    viewController.view.frame = NSMakeRect(0, 0, 100, 100);
//    [self.view addSubview:viewController.view];
}

@end
