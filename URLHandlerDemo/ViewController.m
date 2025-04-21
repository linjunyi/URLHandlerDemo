//
//  ViewController.m
//  URLHandleDemo
//
//  Created by 林君毅 on 2025/4/18.
//

#import "ViewController.h"
#import "ParamURLHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGFloat buttonWidth = 150;
    CGFloat buttonX = self.view.frame.size.width/2 - buttonWidth/2;
    
    [self addButton:@"设置页" selector:@selector(settingClicked)].frame = CGRectMake(buttonX, 100, buttonWidth, 50);
    [self addButton:@"参数页" selector:@selector(paramClicked)].frame = CGRectMake(buttonX, 200, buttonWidth, 50);
    [self addButton:@"动态构建参数页" selector:@selector(dynamicParamClicked)].frame = CGRectMake(buttonX, 300, buttonWidth, 50);
}

- (UIButton *)addButton:(NSString *)title selector:(SEL)selector {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    button.titleLabel.font   = [UIFont systemFontOfSize:15];
    button.backgroundColor   = UIColor.whiteColor;
    button.clipsToBounds     = YES;
    button.layer.cornerRadius= 6;
    button.layer.borderColor = UIColor.grayColor.CGColor;
    button.layer.borderWidth = 1;
    [button addTarget:self action:NSSelectorFromString(NSStringFromSelector(selector)) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    return button;
}

- (void)settingClicked {
    [[FBURLRouter sharedInstance] handleURL:@"/setting" navigation:self.navigationController];
}

- (void)paramClicked {
    [[FBURLRouter sharedInstance] handleURL:@"/1/paramPage?param1=参数1&param2=参数2" navigation:self.navigationController];
}

- (void)dynamicParamClicked {
    NSString *url = MakeParamPageURL(@"2", @"动态参数1", @"动态参数2");
    [[FBURLRouter sharedInstance] handleURL:url navigation:self.navigationController];
}

@end
