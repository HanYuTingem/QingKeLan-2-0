//
//  GDHOriginalChangeController.m
//  Wallet
//
//  Created by GDH on 15/10/23.
//  Copyright (c) 2015年 Sinoglobal. All rights reserved.
//

#import "GDHOriginalChangeController.h"
#import "GDHPasswordBox.h"
#import "payPassWordViewController.h"
#import "SecurityUtil.h"
@interface GDHOriginalChangeController ()<UITextFieldDelegate>
{
    GDHPasswordBox *passWord;// 输入框
    NSString *passTheWord;//
    
    /** 秘钥 */
    NSString *TheSecretKey;
    
    NSString *theID;
}
@end

@implementation GDHOriginalChangeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mallTitleLabel.text = @"支付密码";
    [self makeNav];
    TheSecretKey= @"";
    theID = @"";
    self.confirmButton.layer.masksToBounds = YES;
    self.confirmButton.layer.cornerRadius = 5;
    [self makePasswordBox];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SINOAFNetWorking cancelAllRequest];

//    [self.view endEditing:YES];
    [passWord.numTextfiledSix resignFirstResponder];
}

/** 设置导航 */
-(void)makeNav{
//    self.backView.backgroundColor = WalletHomeNAVGRD
//    self.mallTitleLabel.textColor = [UIColor whiteColor];
//    self.mallTitleLabel.font = WalletHomeNAVTitleFont
//    [self.leftBackButton setImage:[UIImage imageNamed:@"title_btn_back"] forState:UIControlStateNormal];
    mainView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    
}
/**  密码框  */
-(void)makePasswordBox{

    passWord = [[GDHPasswordBox alloc] initWithFrame:CGRectMake(0, 64+60, ScreenWidth, 94)];
    passWord.backgroundColor =[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];

    [passWord.numTextfiledOne becomeFirstResponder];
    if (self.changeTheTitle.length > 0) {
        passWord.titleLabel.text = @"请输入原支付密码";

    }else{
        passWord.titleLabel.text = @"请输入支付密码";
    }
    __weak GDHOriginalChangeController *temp = self;
    passWord.passWordBlock = ^(NSString *thePassWord){
        
        passTheWord = thePassWord;
        if (![temp iftheSixTextfiledNONULL]) {
            [temp showMsg:@"请输入6位密码"];
            return;
        }
        // 网络请求 验证支付密码
        [temp request1004];
    };
    [self.view addSubview:passWord];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
/** 下一步 */
- (IBAction)confirmbuttonDown:(id)sender {
    if (passTheWord.length == 0) {
        [self showMsg:@"请输入原密码"];
        return;
    }
    // 网络请求 验证支付密码
    [self request1004];
}

/**  1004 接口。 */
-(void)request1004{
    [passWord.numTextfiledSix resignFirstResponder];
    passWord.userInteractionEnabled = NO;
    self.confirmButton.userInteractionEnabled = NO;
    [WalletRequsetHttp getKeyVC:self andKey:^(NSString *key, NSString *theIDp) {// 获得秘钥、
        
        NSDictionary *dict = [WalletRequsetHttp WalletPersonVerificationPayPassWord1004VerifyPassword:passTheWord];
            NSString *json = [NSString stringWithFormat:@"%@",[dict JSONFragment]];
        NSString *enconding = [SecurityUtil URLencryptAESData:json andPublicPassWord:key];
        NSString *url = [NSString stringWithFormat:@"%@%@&tradeId=%@",WalletHttp_checkPassword1004,enconding,theIDp];

        [SINOAFNetWorking postWithBaseURL:url controller:self success:^(id json) {
            /**  关闭转圈 */
            [self chrysanthemumClosed];
            self.confirmButton.userInteractionEnabled = YES;
            passWord.userInteractionEnabled = YES;
            NSDictionary *dicJson = json;
            if ([dicJson[@"code"] isEqualToString:@"100"]) {
                payPassWordViewController *pay = [[payPassWordViewController alloc] init];
                pay.changePassWord = @"修改密码";
                [self.navigationController pushViewController:pay animated:YES];
            }else{
                [self showMsg:dicJson[@"msg"]];
            }
            NSLog(@"%@",json);
        } failure:^(NSError *error) {
            passWord.userInteractionEnabled = YES;
            self.confirmButton.userInteractionEnabled = YES;
            [self showMsg:ShowMessage];
            // 关闭转圈
            [self chrysanthemumClosed];
        } noNet:^{
            passWord.userInteractionEnabled = YES;
            self.confirmButton.userInteractionEnabled = YES;
            [self chrysanthemumClosed];
        }];
     }];
}
/** 判断6个uitextfiled 是否为空 */
-(BOOL)iftheSixTextfiledNONULL{
    if (passWord.numTextfiledOne.text.length == 0
        | passWord.numTextfiledTwo.text.length== 0
        | passWord.numTextfiledThree.text.length== 0
        | passWord.numTextfiledFour.text.length== 0
        | passWord.numTextfiledFive.text.length== 0
        | passWord.numTextfiledSix.text.length== 0) {
        return NO;
    }
    else{
        return YES;
    }
}

- (void)dealloc
{
    [self chrysanthemumClosed];
}


@end
