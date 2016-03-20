//
//  SettingViewController.m
//  Daily
//
//  Created by 王冠宇 on 16/3/12.
//  Copyright © 2016年 王冠宇. All rights reserved.
//

#import "SettingViewController.h"
#import "AppDelegate.h"

@interface SettingViewController ()

@property (nonatomic, strong) AppDelegate *delegate;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateViewColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)nightModeSwitchAction:(UISwitch *)sender {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (sender.isOn) {
        self.delegate.nightMode = YES;
    } else {
        self.delegate.nightMode = NO;
    }
    [self updateViewColor];
}

-(void)updateViewColor {
    self.delegate = [[UIApplication sharedApplication] delegate];
    if (self.delegate.nightMode) {
        self.view.backgroundColor = [UIColor blackColor];
        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor blackColor]];

    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],UITextAttributeTextColor,nil]];
        [((UITabBarController *)self.parentViewController.parentViewController).tabBar setBarTintColor:[UIColor whiteColor]];

    }
}

@end
