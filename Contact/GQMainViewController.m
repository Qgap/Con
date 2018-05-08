//
//  MainViewController.m
//  Contact
//
//  Created by gap on 2018/5/8.
//  Copyright © 2018年 gq. All rights reserved.
//

#import "GQMainViewController.h"
#import "GQContactViewController.h"
#import "GQSettingViewController.h"

@interface GQMainViewController ()

@end

@implementation GQMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UINavigationController *contactVC = [[UINavigationController alloc] initWithRootViewController:[[GQContactViewController alloc] init]];
    contactVC.tabBarItem.title = @"通讯录";
//    contactVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"limit_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    contactVC.tabBarItem.image = [[UIImage imageNamed:@"limit_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//
    
    UINavigationController *settingVC = [[UINavigationController alloc] initWithRootViewController:[[GQSettingViewController alloc] init]];
    settingVC.tabBarItem.title = @"设置";
    self.viewControllers = @[contactVC,settingVC];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
