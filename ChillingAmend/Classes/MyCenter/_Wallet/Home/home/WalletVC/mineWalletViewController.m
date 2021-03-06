   //
//  mineWalletViewController.m
//  Wallet
//
//  Created by GDH on 15/10/21.
//  Copyright (c) 2015年 Sinoglobal. All rights reserved.
//

#import "mineWalletViewController.h"
#import "BalanceTableViewCell.h"
#import "RechargeTableViewCell.h"
#import "WalletHome.h"
#import "CJTopUpViewController.h"
#import "CJCashViewController.h"       //提现页面
#import "GDHSetPassWordViewController.h"//发送验证码页面
#import "GDHAccountBalanceViewController.h"
#import "GDHBankCardViewController.h"
#import "GDHChangePassController.h"
#import "SBJSON.h"
#import "GDHPassWordModel.h"
#import "GDHSetPassWordButton.h"
#import "GDHPassWordModel.h"
#import "GDHCardCoupons.h"
#import "GDHMyWalletModel.h"
#import "LaoYiLaoViewController.h"
#import "GDHCouponViewController.h"
static NSString *iden = @"iden";

static int  section = 2;
@interface mineWalletViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView ;
    RechargeTableViewCell *recharge;
    UILabel *_label;
}
/**  数据源  */
@property(nonatomic,strong)NSMutableArray *dataArrary;
/** 账户余额 */
@property (nonatomic, copy) NSString *myBalance;


@end

@implementation mineWalletViewController

-(void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    recharge.leftButton.selected = NO;
    recharge.rightButton.selected = NO;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self request1001AccountBalance];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNav];
    [self makeTableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(thePassWordSetSuccess:) name:@"PASSWORLD" object:nil];
    
}

/** 设置密码成功 */
-(void)thePassWordSetSuccess:(NSNotification *)user
{
    
    NSDictionary *dict = [user userInfo];
    NSString *titleStr = dict[@"Prompt"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showMsg:titleStr];
    });
}

- (void)backButtonClick{
    NSLog(@"");
    [[NSNotificationCenter defaultCenter]postNotificationName:@"popLYLVC" object:@"-1"];
    
    if([_type isEqualToString:@"1"]){
        for (UIViewController *subVc in self.navigationController.viewControllers) {
            if([subVc isKindOfClass:[LaoYiLaoViewController class]]){
                [self.navigationController popToViewController:subVc animated:YES];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma  mark - 初始化
-(NSMutableArray *)dataArrary{
    if (!_dataArrary) {
        
        _dataArrary = [NSMutableArray array];
    }
    return _dataArrary;
}
/** 设置导航 */
-(void)makeNav{
    //    self.backView.backgroundColor = WalletHomeNAVGRD
    self.mallTitleLabel.text  = @"我的钱包";
    //    self.mallTitleLabel.textColor = [UIColor whiteColor];
    //    self.mallTitleLabel.font = WalletHomeNAVTitleFont
    //    [self.leftBackButton setImage:[UIImage imageNamed:@"title_btn_back"] forState:UIControlStateNormal];
    mainView.backgroundColor = [UIColor whiteColor];
    
}
/** 钱包个人中心账户余额1001 接口 */
-(void)request1001AccountBalance{
    [self chrysanthemumOpen];
    NSDictionary *dict  = [WalletRequsetHttp WalletPersonAccountBalance1001];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",WalletHttp_Balance,[dict JSONFragment]];
    [SINOAFNetWorking postWithBaseURL:url controller:self success:^(id json) {
        NSDictionary *dict = json;
        if ([dict[@"code"] isEqualToString:@"100"]) {
            
            [self.dataArrary removeAllObjects];
            GDHMyWalletModel *walletModel = [[GDHMyWalletModel alloc] initWithDic:dict[@"rs"]];
            NSUserDefaults *userD =[NSUserDefaults standardUserDefaults];
            [userD setObject:walletModel.isHasPass forKey:HasPassWord];
            [userD synchronize];
            
            [self.dataArrary addObject:walletModel];
            [_tableView reloadData];
            NSLog(@"请求成功---------");
        }else{
            NSLog(@"%@",dict[@"msg"]);
        }
        [self chrysanthemumClosed];
        
        NSLog(@"%@",self.view.subviews);
        
    } failure:^(NSError *error) {
        
        NSLog(@"%@",error);
        [self showMsg:ShowMessage];
        [self chrysanthemumClosed];
        
    } noNet:^{
        [self chrysanthemumClosed];
    }];
    //
}
/** tableview 创建 */
-(void)makeTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSelectionStyleDefault;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.view addSubview:_tableView];
}
#pragma mark - tableView 代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return section;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 4;
    }else{
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            BalanceTableViewCell *balanceCell = [[BalanceTableViewCell alloc] init];
            balanceCell.selectionStyle= UITableViewCellSelectionStyleNone;
            balanceCell.title.text = @"账户余额";
            if (self.dataArrary.count) {
                
                GDHMyWalletModel *model = self.dataArrary[0];
                [balanceCell makeRefreshUI:[NSString stringWithFormat:@"¥%@",model.balance]];
                self.myBalance = model.balance;
                if ([model.balanceChange isEqual:@"Y"]) {
                    balanceCell.redPoint.hidden = NO;
                }
            }
            return balanceCell;
        }else if(indexPath.row == 1){
            recharge = [[RechargeTableViewCell alloc] init];
            __weak mineWalletViewController *Temp = self;
            recharge.RechargeBlock = ^(UIButton *recharge){//跳转充值页面
                //显示提示框
                //                [Temp showMsg:@"功能在路上，敬请期待！"];
                
#if 1  //充值页面一期暂未开通
                CJTopUpViewController *topUp = [[CJTopUpViewController alloc] init];
                [Temp.navigationController pushViewController:topUp animated:YES];
#endif
            };
            recharge.WithdrawalsBlock = ^(UIButton *withdrwals){//跳转提现页面
                //  提现
                CJCashViewController *Withdrawals = [[CJCashViewController alloc] init];
                Withdrawals.balance = Temp.myBalance;
                [Temp.navigationController pushViewController:Withdrawals animated:YES];
            };
            
            recharge.selectionStyle= UITableViewCellSelectionStyleNone;
            return recharge;
        }else if(indexPath.row == 2){
            BalanceTableViewCell *balance = [[BalanceTableViewCell alloc] init];
            balance.title.text = @"我的银行卡";
            if (self.dataArrary.count) {
                balance.donwLine.hidden = YES;
                GDHMyWalletModel *model = self.dataArrary[0];
                if ([model.bankCardNum intValue] == 0) {
                    [balance makeRefreshUI:[NSString stringWithFormat:@"未添加"]];
                    
                }else{
                    [balance makeRefreshUI:[NSString stringWithFormat:@"%d张",[model.bankCardNum intValue]]];
                }
                
            }
            balance.selectionStyle= UITableViewCellSelectionStyleNone;
            return balance;
        }else{
            BalanceTableViewCell *balance = [[BalanceTableViewCell alloc] init];
            balance.title.text = @"支付密码";
            balance.selectionStyle= UITableViewCellSelectionStyleNone;
            return balance;
        }
    }else{
        BalanceTableViewCell *balance = [[BalanceTableViewCell alloc] init];
        balance.title.text = @"优惠券";
        balance.redPoint.hidden = YES;
        CGRect frame = balance.redPoint.frame;
        frame.origin.x -= 15;
        balance.redPoint.frame = frame;
        [balance makeRefreshUI:@""];
        balance.selectionStyle= UITableViewCellSelectionStyleNone;
        return balance;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 37;
    }
    return 43;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0 ) {
        GDHSetPassWordButton *titleButton = [GDHSetPassWordButton buttonWithType:UIButtonTypeRoundedRect];
        [titleButton addTarget:self action:@selector(setPassWordButtonDown) forControlEvents:UIControlEventTouchUpInside];
        titleButton.frame  = CGRectMake(0, 0, ScreenWidth, 30);
        return titleButton;
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
        GDHCardCoupons *label = [[GDHCardCoupons alloc] initWithFrame:CGRectMake(20, 5, 80, 20)];
        [view addSubview:label];
        return view;
    }
}
/** 设置密码 */
-(void)setPassWordButtonDown{
    GDHSetPassWordViewController *setPassWord = [[GDHSetPassWordViewController alloc] init];
    [self.navigationController pushViewController:setPassWord animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.dataArrary.count) {
        GDHMyWalletModel *model = self.dataArrary[0];
        if (section == 0 && [model.isHasPass isEqualToString:@"Y"]) {
            return 0;
        }
    }
    return 30;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BalanceTableViewCell *cell = (BalanceTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            cell.redPoint.hidden = YES;
            GDHAccountBalanceViewController *accountBalance = [[GDHAccountBalanceViewController alloc] init];
            [self.navigationController pushViewController:accountBalance animated:YES];
        }
        if (indexPath.row == 2) {
            
            GDHBankCardViewController *bankcard = [[GDHBankCardViewController alloc] init];
            [self.navigationController pushViewController:bankcard animated:YES];
        }
        if (indexPath.row == 3) {
            if (self.dataArrary.count) {
                GDHMyWalletModel *model = self.dataArrary[0];
                NSLog(@"支付密码");
                if ([model.isHasPass isEqualToString:@"Y"]) {
                    GDHChangePassController *setPassWord = [[GDHChangePassController alloc] init];
                    [self.navigationController pushViewController:setPassWord animated:YES];            } else {
                        GDHSetPassWordViewController *SPWVC = [[GDHSetPassWordViewController alloc] init];
                        [self.navigationController pushViewController:SPWVC animated:YES];
                    }
            }
        }
    }else{
        if (indexPath.row == 0) {
            //显示提示框
//            [self showMsg:@"功能在路上，敬请期待！"];
            GDHCouponViewController *vc  = [[GDHCouponViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self chrysanthemumClosed];
}



@end
