//
//  GDHSetPassWordViewController.m
//  Wallet
//
//  Created by GDH on 15/10/21.
//  Copyright (c) 2015年 Sinoglobal. All rights reserved.
//

#import "GDHSetPassWordViewController.h"
#import "payPassWordViewController.h"
#import "WalletHome.h"

@interface GDHSetPassWordViewController ()
{
    int theTime ;
}
/** 验证码  */
@property (nonatomic,copy) NSString *passWord ;
@property(nonatomic,strong)NSTimer *time;
@end
@implementation GDHSetPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNav];
    self.confirmButton.layer.masksToBounds = YES;
    self.confirmButton.layer.cornerRadius = 4;

    self.sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *str = kkUserName;
    NSRange range = NSMakeRange(3, 4);
    NSString *starStr = [str stringByReplacingCharactersInRange:range withString:@"****"];
    self.VerificationCode.text = [NSString stringWithFormat:@"验证码将发送到注册账户时的手机号%@,请注意查收。如果有问题请拨打400-832-1933",starStr];
    if (self.findPassWord.length > 0) {
        self.mallTitleLabel.text = @"找回支付密码";
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.time  invalidate];
    self.time = nil;
    [SINOAFNetWorking cancelAllRequest];
}

/** 导航 */
-(void)makeNav{
//    self.backView.backgroundColor = WalletHomeNAVGRD
    self.mallTitleLabel.text = @"支付密码";
//    self.mallTitleLabel.textColor = [UIColor whiteColor];
//    [self.leftBackButton setImage:[UIImage imageNamed:@"title_btn_back"] forState:UIControlStateNormal];
//    self.mallTitleLabel.font = WalletHomeNAVTitleFont
    mainView.backgroundColor = [UIColor whiteColor];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/** 发送按钮事件 */
- (IBAction)thnSendButtonDown:(id)sender {
    self.sendButton.enabled = NO;

    [self chrysanthemumOpen];
    
    NSDictionary *dict = [WalletRequsetHttp WalletPersonUsergetCodet1113];
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletHttp_getCode,[dict JSONFragment]];
    [SINOAFNetWorking postWithBaseURL:url controller:self success:^(id json) {
        [self chrysanthemumClosed];
        
        NSDictionary *dic = json;
        NSLog(@"%@",dic[@"msg"]);
        if ([dic[@"code"] isEqualToString:@"100"]) {
            
            theTime = 60;
            self.time =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(theTimeIsCountdown) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop]addTimer:self.time forMode:NSDefaultRunLoopMode];
            NSString *passWordRS = dic[@"rs"];
            self.passWord = [NSString stringWithFormat:@"%@",passWordRS];
        }else {
            NSString *message = dic[@"msg"];
            if (message.length) {
                [self showMsg:message];
            } else {
                [self showMsg:ShowMessage];
            }
            self.sendButton.enabled = YES;
        }
        
        NSLog(@"%@",json);
    } failure:^(NSError *error) {
        self.sendButton.enabled = YES;

        [self showMsg:ShowMessage];
        [self chrysanthemumClosed];
        NSLog(@"%@",error);
    } noNet:^{
        self.sendButton.enabled = YES;

        [self chrysanthemumClosed];
    }];
}

/**  时间倒计时 */
-(void)theTimeIsCountdown{
    if (theTime > 0) {
        
        NSLog(@"%d",theTime);
        /**  7.1.1版本 set 赋值有问题 */
//        [self.sendButton setTitle:[NSString stringWithFormat:@"%d",--theTime] forState:UIControlStateNormal];
        self.sendButton.titleLabel.text = [NSString stringWithFormat:@"%ds",--theTime];
        
    }else{
        self.sendButton.enabled = YES;
        [self.time  invalidate];
        self.time = nil;
        [self.sendButton setTitle:@"重新获取" forState:UIControlStateNormal];
    }
}

/** 确定按钮事件 */
- (IBAction)theconfirmButtonDown:(id)sender {
//支付密码设置  不删除方便测试，，，
    
    if (self.InputTheTextFiled.text.length==0){
     
        [self showMsg:@"请输入验证码！"];
        return;
    }
    
    if (![self.InputTheTextFiled.text isEqualToString: self.passWord]) {
        [self showMsg:@"验证码错误！"];
        return;
    }
    payPassWordViewController *payPassWord = [[payPassWordViewController alloc] init];
    payPassWord.fromVcToSetPassWord = self.fromVcToSetPassWord;
    
    payPassWord.LYLpayPushtoSetpassWord = self.LYLPushtoSetpassWord;
//    payPassWord.findPassWord = self.findPassWord;
    [self.navigationController pushViewController:payPassWord animated:YES];
}

- (void)dealloc
{
    [self chrysanthemumClosed];
}

@end
