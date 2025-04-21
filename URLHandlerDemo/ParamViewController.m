//
//  ParamViewController.m
//  URLHandlerDemo
//
//  Created by 林君毅 on 2025/4/21.
//

#import "ParamViewController.h"

URL_EXPORT(ParamPageURL) {
    NSString *courseId = parameters[@"courseId"];
    NSString *param1 = parameters[@"param1"];
    NSString *param2 = parameters[@"param2"];
    ParamViewController *vc = [[ParamViewController alloc] initWithCourseId:courseId param1:param1 param2:param2];
    vc.hidesBottomBarWhenPushed = YES;
    [navi pushViewController:vc animated:YES];
}

@interface ParamViewController ()

@property (nonatomic, strong) NSString *courseId;
@property (nonatomic, strong) NSString *param1;
@property (nonatomic, strong) NSString *param2;

@end

@implementation ParamViewController

- (id)initWithCourseId:(NSString *)courseId param1:(NSString *)param1 param2:(NSString *)param2 {
    if (self = [super init]) {
        _courseId = courseId;
        _param1 = param1;
        _param2 = param2;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.font = [UIFont boldSystemFontOfSize:15];
    lbl.textColor = UIColor.blackColor;
    lbl.text = [NSString stringWithFormat:@"courseId %@, param1 %@, param2 %@", _courseId, _param1, _param2];
    [self.view addSubview:lbl];
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
