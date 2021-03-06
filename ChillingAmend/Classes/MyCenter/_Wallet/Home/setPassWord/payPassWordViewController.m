//
//  payPassWordViewController.m
//  Wallet
//
//  Created by GDH on 15/10/21.
//  Copyright (c) 2015年 Sinoglobal. All rights reserved.
//

#import "payPassWordViewController.h"
#import "WalletHome.h"
#import "GDHPasswordBox.h"
#import "GDHPassWordModel.h"
#import "mineWalletViewController.h"
#import "SecurityUtil.h"
#import "CJCashViewController.h"

//#import "BaoJiaoZiViewController.h"

@interface payPassWordViewController ()
{
    GDHPasswordBox *passWord;
    GDHPasswordBox *confirmPayPassWord;
    UILabel *title;
    /** 请输入密码 */
    NSString *passWordString;
    /** 确认支付密码 */
    NSString *confirmPayPassWordString;
    
    /** 秘钥 */
    NSString *TheSecretKey;
    
    NSString *theID;
}
@end

@implementation payPassWordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNav];
    [self GDHPasswordBoxView];
    /**  防止秘钥请求不到字符串为nil */
    TheSecretKey= @"";
    theID = @"";
    if (self.changePassWord.length > 0) {
        [self.confirmButtonDown setTitle:@"确认修改" forState:UIControlStateNormal];
    }
    self.mallTitleLabel.text = @"支付密码";
    
    self.confirmButtonDown.layer.masksToBounds = YES;
    self.confirmButtonDown.layer.cornerRadius = walletHomeButtonLayer;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SINOAFNetWorking cancelAllRequest];
}

/** 导航 */
-(void)makeNav{
    //    self.backView.backgroundColor = WalletHomeNAVGRD;
    //    self.mallTitleLabel.textColor = [UIColor whiteColor];
    //    self.mallTitleLabel.font = WalletHomeNAVTitleFont
    //    [self.leftBackButton setImage:[UIImage imageNamed:@"title_btn_back"] forState:UIControlStateNormal];
    mainView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
}
/** 输入支付 密码框 */
-(void)GDHPasswordBoxView{
    
    passWord = [[GDHPasswordBox alloc] initWithFrame:CGRectMake(0, 64+60, ScreenWidth, 94)];
    passWord.backgroundColor =[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    passWord.passWordBlock = ^(NSString *theNumString){
        passWordString = theNumString;
        
    };
    if (self.changePassWord.length > 0) {
        passWord.titleLabel.text = @"请输入新支付密码";
        
    }else{
        passWord.titleLabel.text = @"请设置6位数字支付密码";
    }
    
    [self.view addSubview:passWord];
    
    
    confirmPayPassWord = [[GDHPasswordBox alloc] initWithFrame:CGRectMake(0, 220, ScreenWidth, 94)];
    confirmPayPassWord.backgroundColor =[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    confirmPayPassWord.passWordBlock =^(NSString *theNumString){
        confirmPayPassWordString = theNumString;
    };
    if (self.changePassWord.length >0) {
        confirmPayPassWord.titleLabel.text = @"确认新支付密码";
    }else {
        confirmPayPassWord.titleLabel.text = @"确认支付密码";
    }
    [self.view addSubview:confirmPayPassWord];
    
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(80*WalletSP_Width, 350, 160, 40)];
    title.font = [UIFont systemFontOfSize:16];
    title.hidden = YES;
    title.text = @"支付密码设置成功！";
    title.textAlignment = NSTextAlignmentRight;
    title.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:title];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
/** 确认按钮 */
- (IBAction)confirmButtonAction:(id)sender {
    
    
    if (passWordString.length <6 &&confirmPayPassWordString.length < 6) {
        [self showMsg:@"请输入密码"];
        NSLog(@"请输入密码");
    }else{
        if ([passWordString isEqualToString:confirmPayPassWordString]) {
            NSLog(@" 密码正确");
            
            [self  setNewPassWord];// 得到秘钥
            
        }else{
            NSLog(@"两次密码不同");
            [self showMsg:@"两次输入密码不同"];
        }
    }
}


/**  设置密码  */
-(void)setNewPassWord{
    
    [WalletRequsetHttp getKeyVC:self andKey:^(NSString *key, NSString *theIDP) {//  获得秘钥
        
        NSLog(@"%@%@",key,theIDP);
        NSDictionary *dict = [WalletRequsetHttp WalletPersonSettingPayPassWord1003SetPassword:confirmPayPassWordString];
        
        NSString *json = [NSString stringWithFormat:@"%@",[dict JSONFragment]];
        
        NSString *enconding = [SecurityUtil URLencryptAESData:json andPublicPassWord:key];
        
        NSString *Url = [NSString stringWithFormat:@"%@%@&tradeId=%@",WalletHttp_setPassword1003,enconding,theIDP];
        
        [SINOAFNetWorking postWithBaseURL:Url controller:self success:^(id json) {
            [self chrysanthemumClosed];
            NSDictionary *dic = json;
            
            
            NSLog(@"dic   : %@",dic);
            if ([dic[@"code"] isEqualToString:@"100"]) {
                if ([dic[@"rs"] isEqualToString:@"OK"]) {
                    [self setPassWordBox];
                    [self savePassWord];
                    NSUserDefaults *userD =[NSUserDefaults standardUserDefaults];
                    [userD setObject:@"Y" forKey:HasPassWord];
                    [userD synchronize];
                    
                    
                    if (self.fromVcToSetPassWord.length > 0) {
                        if ([self.fromVcToSetPassWord isEqualToString:@"找回密码,设置了密码后返回提现界面"]) {//找回密码
                            //                            [self NSNotifitionCJCashViewController];
                            [self poptoWalletHomeControllet:[CJCashViewController class] andNotificationName:@"wallet_deleteItem" andPrompt:@"找回密码成功!"];
                            
                        }else if ([self.fromVcToSetPassWord isEqualToString:@"未设置密码，提现，设置了密码后返回提现界面"]){//设置密码
                            
                            [self NSNotifitionCJCashViewController];
                            [self poptoWalletHomeControllet:[CJCashViewController class] andNotificationName:@"wallet_deleteItem" andPrompt:@"设置密码成功!"];
                        }
                        
                    }else{
                        
                        
                        if ([self.LYLpayPushtoSetpassWord isEqualToString:@"捞一捞页面push过来设置密码"]) {
                          
#warning  对接包饺子 勿删
                            
//                            [self poptoWalletHomeControllet:[BaoJiaoZiViewController class] andNotificationName:@"BaojiaoziVc" andPrompt:@"设置密码成功!"];
                            
                            return ;
                        }else if ([self.LYLpayPushtoSetpassWord isEqualToString:@"捞一捞页面push过来找回密码"]){
//                            [self poptoWalletHomeControllet:[BaoJiaoZiViewController class] andNotificationName:@"BaojiaoziVc" andPrompt:@"找回密码成功!"];
                        }
                        
                        if (self.changePassWord.length > 0) {
                            
                            [self NSNotifitionhWalletHomeViewController:@"支付密码修改成功！" andClass:[mineWalletViewController class]];
                            
                        }else{
                            
                            [self NSNotifitionhWalletHomeViewController:@"支付密码设置成功！" andClass:[mineWalletViewController class]];
                        }
                    }
                }
            }else if ([dic[@"code"] isEqualToString:@"102"]){
                [self showMsg:dic[@"msg"]];
            }
        } failure:^(NSError *error) {
            
            [self showMsg:ShowMessage];
            [self chrysanthemumClosed];
        } noNet:^{
            [self chrysanthemumClosed];
        }];
    }];
    
}

/** 密码框提示 */
-(void)setPassWordBox{
    title.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        title.hidden = YES;
    });
}
/** 存储支付密码
 */
-(void)savePassWord{
    GDHPassWordModel *model = [[GDHPassWordModel alloc] init];
    model.payPassword = confirmPayPassWordString;
    [GDHPassWordModel save:model];
}

-(void)poptoWalletHomeControllet:(Class )vc andNotificationName:(NSString *)name andPrompt:(NSString *)Prompt{
    NSArray  * viewControls= self.navigationController.viewControllers;
    for (UIViewController * viewControl  in viewControls){
        if([viewControl isKindOfClass:vc]){
            NSDictionary *dict = @{@"Prompt":Prompt};
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:dict];
            [self.navigationController popToViewController:viewControl animated:YES];
            
            return;
        }
    }
}

/**  通知到提现页面 */
-(void)NSNotifitionCJCashViewController{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CJCashViewController" object:nil];
}

/**  通知钱包首页 支付密码修改成功 */
-(void)NSNotifitionhWalletHomeViewController:(NSString *)Prompt andClass:(Class)vc{
    
    NSArray  * viewControls= self.navigationController.viewControllers;
    for (UIViewController * viewControl  in viewControls){
        if([viewControl isKindOfClass:vc]){
            [self.navigationController popToViewController:viewControl animated:YES];
            NSDictionary *dict = @{@"Prompt":Prompt};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PASSWORLD" object:nil userInfo:dict];
            return;
        }
    }
    
}

-(void)LYLPushtoBaojiaoziVc{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BaojiaoziVc" object:nil];
    
}


//-(void)NSNotifitionCJCashController{
//    NSArray  * viewControls= self.navigationController.viewControllers;
//    for (UIViewController * viewControl  in viewControls){
//        if([viewControl isKindOfClass:[CJCashViewController class]]){
//            [self.navigationController popToViewController:viewControl animated:YES];
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"TiXian" object:nil];
//            return;
//        }
//    }
//}

- (void)dealloc
{
    [self chrysanthemumClosed];
}

@end
