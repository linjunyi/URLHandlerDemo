//
//  SettingViewController.m
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/18.
//

#import "SettingViewController.h"

URL_EXPORT(SettingPageURL) {
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    [navi pushViewController:settingVC animated:YES];
}

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.title = @"设置页";
}

@end
