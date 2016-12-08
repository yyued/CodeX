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

static COMModalWindowController *modalWindowController;
static COMPropsWindowController *propsWindowController;
static COMPublishWindowController *publishWindowController;

@interface ViewController ()

@property (nonatomic, strong) COMModalWindowController *obj;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        modalWindowController = [COMModalWindowController new];
//        modalWindowController.modalSession = [[NSApplication sharedApplication] beginModalSessionForWindow:modalWindowController.window];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        propsWindowController = [COMPropsWindowController new];
//        propsWindowController.modalSession = [[NSApplication sharedApplication] beginModalSessionForWindow:propsWindowController.window];
//    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        publishWindowController = [COMPublishWindowController new];
        publishWindowController.modalSession = [[NSApplication sharedApplication] beginModalSessionForWindow:publishWindowController.window];
    });
}

@end
