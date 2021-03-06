//
//  GetSuccessViewController.m
//  LaoYiLao
//
//  Created by sunsu on 15/11/6.
//  Copyright © 2015年 sunsu. All rights reserved.
//

#import "GetSuccessViewController.h"
#import "LaoYiLaoViewController.h"
#import "mineWalletViewController.h"
#import "DumplingInforModel.h"

#import "GetShareInfoModel.h"
#import "ShareInfoManage.h"
#import "MyDumplingViewController.h"

@interface GetSuccessViewController ()<GetSuccessViewDelegate>
{
    GetSuccessView * _getSuccessView;
}
@end

@implementation GetSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeBarTitleWithString:@"领取成功"];
    self.view.backgroundColor = RGBACOLOR(242, 242, 242, 1);
//    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;

    self.customNavigation.shareButton.hidden = YES;
    self.customNavigation.rightButton.hidden = YES;
    
    [self addGetSuccessView];
}

//- (void)leftButtonClicked:(UIButton *)button{
- (void)backBtnClicked{
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[LaoYiLaoViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
//    [self.navigationController  popViewControllerAnimated:YES];

}
-(void)addGetSuccessView{
    _getSuccessView = [[GetSuccessView alloc]initWithFrame:CGRectMake(0, NavgationBarHeight, kkViewWidth, CustomViewHeight)];
    _getSuccessView.delegate = self;
    [self.view addSubview:_getSuccessView];
}


#pragma mark GetSuccessViewDelegate
-(void)shareRightNow:(UIButton *)btn{
    ZHLog(@"马上分享");
//    MySetObjectForKey(ShareTypeWithBounce, ShareTypeKey);
//    [ShareInfoManage shareJiaoziInfoWithButton:btn andController:self];
    [ShareInfoManage shareWithType:ShareTypeWithMainBounce andContentStr:@"" andViewController:self];
}

-(void)jixuLao{
    ZHLog(@"继续捞");
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[LaoYiLaoViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}


-(void)lookMyDumpling{
    ZHLog(@"我得饺子");

    MyDumplingViewController * myWalletVC = [[MyDumplingViewController alloc]init];
//    myWalletVC.backBlock = ^void(){};
    [self.navigationController pushViewController:myWalletVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
