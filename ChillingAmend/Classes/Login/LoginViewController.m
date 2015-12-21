//
//  LoginViewController.m
//  LANSING
//
//  Created by nsstring on 15/5/27.
//  Copyright (c) 2015年 DengLu. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisteredViewController.h"
#import "ShouRegisterdViewController.h"
#import "AmendPassViewController.h"
#import "InstructionsViewController.h"
#import "LoginPublicObject.h"
#import "PromptView.h"
#import "PrizeViewController.h"
#import "PRJ_DayDaytreasureViewController.h"
#import "PersonalCenterViewController.h"
#import "APService.h"
#import "BYC_EmailLoginViewController.h"
#import "BSaveMessage.h"

@interface LoginViewController ()<UITextFieldDelegate,PromptViewDelegate>{
    PromptView *promptView;
}
/*用户名*/
@property (strong, nonatomic) IBOutlet UIView *userView;
@property (strong, nonatomic) IBOutlet UITextField *userTextField;

/*密码*/
@property (strong, nonatomic) IBOutlet UIView *passwordView;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextield;

/*登陆*/
@property (strong, nonatomic) IBOutlet UIButton *landingButton;

/*注册*/
@property (strong, nonatomic) IBOutlet UIButton *registeredButton;
@property (strong, nonatomic) IBOutlet UIButton *onRegisteredButton;

/*了解通行证*/
@property (strong, nonatomic) IBOutlet UILabel *passLabel;

/*忘记密码*/
@property (strong, nonatomic) IBOutlet UILabel *forgetLabel;

/*无密码快递登陆*/
@property (strong, nonatomic) IBOutlet UILabel *fastLabel;

//判断密文
@property (strong, nonatomic) NSString    *SignString;


@property (strong, nonatomic) LoginPublicObject *LPobject;

@property (weak, nonatomic) IBOutlet UIButton *button_EmailLoging;
@end

@implementation LoginViewController

@synthesize userView;
@synthesize passwordView;
@synthesize landingButton;
@synthesize registeredButton;
@synthesize userTextField;
@synthesize passwordTextield;
@synthesize onRegisteredButton;
@synthesize forgetLabel;
@synthesize fastLabel;
@synthesize passLabel;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
    
    keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
    [keyBoardController addToolbarToKeyboard];
    userTextField.delegate = self;
    passwordTextield.delegate = self;
    
    promptView = [PromptView Instance];
    promptView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
    promptView.delegate = self;
    promptView.logInToRegisterLabel.text = @"登录成功";
    promptView.InTheFormOfInt = 1;
    [promptView draw];
    promptView.hidden = YES;
    promptView.frame = self.view.bounds;
    [self.view addSubview:promptView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [keyBoardController removeKeyBoardNotification];
    keyBoardController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:@"登录"];
    [self.bar addSubview:onRegisteredButton];
    forgetLabel.userInteractionEnabled = YES;
    [forgetLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPassword)]];
    
    fastLabel.userInteractionEnabled = YES;
    [fastLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fastPassword)]];
    
    passLabel.userInteractionEnabled = YES;
    [passLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(understandTheCignaPass)]];

    /*阴影和倒角*/
    userView.layer.shadowRadius = 1;
    userView.layer.shadowOpacity = 0.4f;
    userView.layer.shadowOffset = CGSizeMake(0, 0);
    userView.layer.cornerRadius = 5;
    
    passwordView.layer.shadowRadius = 1;
    passwordView.layer.shadowOpacity = 0.4f;
    passwordView.layer.shadowOffset = CGSizeMake(0, 0);
    passwordView.layer.cornerRadius = 5;
    
    landingButton.layer.shadowRadius = 1;
    landingButton.layer.shadowOpacity = 0.2f;
    landingButton.layer.shadowOffset = CGSizeMake(0, 0);
    landingButton.layer.cornerRadius = 5;
    
    registeredButton.layer.shadowRadius = 1;
    registeredButton.layer.shadowOpacity = 0.4f;
    registeredButton.layer.shadowOffset = CGSizeMake(0, 0);
    registeredButton.layer.cornerRadius = 5;
    
//    _button_EmailLoging.layer.shadowRadius = 1;
//    _button_EmailLoging.layer.shadowOpacity = 0.2f;
//    _button_EmailLoging.layer.shadowOffset = CGSizeMake(0, 0);
    _button_EmailLoging.layer.cornerRadius = 5;
    _button_EmailLoging.layer.borderWidth = 1;
    _button_EmailLoging.layer.borderColor = [UIColor colorWithRed:205/255.0 green:205/255.0 blue:205/255.0 alpha:1].CGColor;
    
    /*回收键盘*/
    UITapGestureRecognizer* tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toolbarButtonTap)];
    [self.view addGestureRecognizer:tap1];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark -
#pragma mark - TextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([GCUtil isMobileNumber:userTextField.text] != 0&&passwordTextield.text.length >= 6&&passwordTextield.text.length <= 20) {
        [landingButton setBackgroundColor:[UIColor colorWithRed:254.0 / 255 green:187.0 / 255 blue:38.0 / 255 alpha:1]];
    }else{
        [landingButton setBackgroundColor:RGBACOLOR(195, 195, 195, 1)];
    }
    
    _SignString = @"";
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{


    _SignString = @"";
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]){
        [textField resignFirstResponder];
        return NO;
    }
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    NSString *passwordText = textField == passwordTextield?toBeString:passwordTextield.text;
    
    if (userTextField == textField) {
        if (toBeString.length > 11) {
            //            [self showMsg:@"手机号码不能超过11位!"];
            return NO;
        }
    }
    
    if ([textField isEqual:passwordTextield]) {
        
        
        _SignString = [_SignString stringByAppendingString:string];;
        
        NSLog(@"_SignString ==  %@",_SignString);
    }
    
    if ([GCUtil isMobileNumber:textField == userTextField?toBeString:userTextField.text] != 0&&passwordText.length >= 6&&passwordText.length <= 20 && _SignString.length >= 6 ) {
        [landingButton setBackgroundColor:[UIColor colorWithRed:254.0 / 255 green:187.0 / 255 blue:38.0 / 255 alpha:1.00f]];
        landingButton.userInteractionEnabled = YES;
    }else{
        [landingButton setBackgroundColor:RGBACOLOR(195, 195, 195, 1)];
        landingButton.userInteractionEnabled = NO;
    }
    //    NSLog(@"-------:%@",toBeString);
    return YES;
}

/*了解通行证*/
-(void)understandTheCignaPass{
    //    账号说明
    InstructionsViewController *instructions = [[InstructionsViewController alloc]init];
    instructions.viewControllerIndex = self.viewControllerIndex;
    instructions.entranceInt = 1;
    instructions.typeInt = 2;
    [self.navigationController pushViewController:instructions animated:YES];
}

/*键盘回收*/
-(void)toolbarButtonTap{
    [userTextField resignFirstResponder];
    [passwordTextield resignFirstResponder];
}

/*注册*/
- (IBAction)UserRegistration:(id)sender {
    ShouRegisterdViewController *registered = [[ShouRegisterdViewController alloc]init];
    registered.interfaceInt = 1;
    [self.navigationController pushViewController:registered animated:YES];
}

/*忘记密码*/
-(void)forgotPassword{
    ShouRegisterdViewController *registered = [[ShouRegisterdViewController alloc]init];
    registered.interfaceInt = 3;
    [self.navigationController pushViewController:registered animated:YES];
}

/*登陆*/
- (IBAction)landingBut:(id)sender {
    [userTextField resignFirstResponder];
    [passwordTextield resignFirstResponder];
    if ([GCUtil isMobileNumber:userTextField.text] == 0) {
        [self showMsg:@"请输入正确的电话号码"];
        return;
    }else if ([GCUtil convertToInt:passwordTextield.text] < 6||[GCUtil convertToInt:passwordTextield.text] > 20){
        [self showMsg:@"请输入6-20位数字，英文字母或符号组合"];
        return;
    }else{
        [self showMsg:nil];
        mainRequest.tag = 100;
        [mainRequest requestHttpWithPost:[NSString stringWithFormat:@"%@login/",ADDRESS] withDict:[LogInAPP loginUserName:userTextField.text andpwd:passwordTextield.text]];
    }
}

/*无密码快速登陆*/
-(void)fastPassword{
    ShouRegisterdViewController *registered = [[ShouRegisterdViewController alloc]init];
    registered.interfaceInt = 2;
    registered.viewControllerIndex = self.viewControllerIndex;
    [self.navigationController pushViewController:registered animated:YES];
}

#pragma mark -
#pragma mark - 登陆成功提示返回
-(void)chooseSkip:(int)skipInt{
    
//    [self dismissViewControllerAnimated:YES completion:nil];
    // 保存登录数据
    // 设置单利 保存数据 模型 NSUserDefaults
    [self jumpToHomeView];
}

-(void)chooseToUnderstand:(int)understandInt{
    //    账号说明
    InstructionsViewController *instructions = [[InstructionsViewController alloc]init];
    instructions.viewControllerIndex = self.viewControllerIndex;
    instructions.isFromChooseToUnderstand = YES;
    instructions.entranceInt = 2;
    instructions.typeInt = 2;
    [self.navigationController pushViewController:instructions animated:YES];
}

-(void)GCRequest:(GCRequest*)aRequest Finished:(NSString*)aString
{
    aString = [aString stringByReplacingOccurrencesOfString:@"null"withString:@"\"\""];
    NSMutableDictionary *dict=[aString JSONValue];
    NSLog(@"22==%@",dict);
    if (dict) {
        if ([[dict objectForKey:@"code"] intValue] == 1) {
            NSDictionary *resultDic01 = (NSDictionary *)[dict objectForKey:@"result"];
            if (aRequest.tag == 100) {
                NSDictionary *resultDic = (NSDictionary *)[dict objectForKey:@"result"];
//                [SaveMessage saveUserMessageJava:resultDic];
//                [BSaveMessage saveUserMessage:resultDic];
//                [[BSaveMessage Share] resetInfo:resultDic];
//                [SaveMessage saveUserMessage:resultDic];
//                lolinPublic.logInDic = resultDic;
                if (APPLICATION == 1) {
                    //                    [self showMsg:@"登陆成功"];
                    //                    lolinPublic.logInPHPDic = dict;
                   // promptView.InTheFormOfInt = 1;
                    //promptView.hidden = NO;
                }else{
                    mainRequest.tag = 101;
                    [mainRequest requestHttpWithPost:[NSString stringWithFormat:@"%@",ADDRESSPHP]
                                            withDict:[LogInAPP accessToLoginInformationUserId:[resultDic objectForKey:@"id"]
                                                                                     userName:[resultDic objectForKey:@"userName"]
                                                                                          sex:[resultDic objectForKey:@"sex"]
                                                                                     nickName:[resultDic objectForKey:@"nickname"]
                                                                                          src:[resultDic objectForKey:@"src"]
                                                                                        jifen:@"0"
                                                                                       status:[resultDic objectForKey:@"status"]
                                                                                          lat:IfNullToString(_LPobject.stringLat)
                                                                                          ing:IfNullToString(_LPobject.stringIng)
                                                                                        token:IfNullToString(_LPobject.stringToken)]];
                }
            }else if (aRequest.tag == 101){
                
                [SaveMessage saveUserMessagePHP:dict];
                MySetObjectForKey([dict objectForKey:@"userid"],UserIDKey);//保存登陆用户的id
                MySetObjectForKey([dict objectForKey:@"user_name"], LoginPhoneKey);//保存手机号
                NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:UserIDKey]);
                [SaveMessage publicLoadDataWithNoLoginGetMoney];
                [kkUserInfo resetInfo:[[NSUserDefaults standardUserDefaults]objectForKey:usernameMessagePHP]];
                [BSaveMessage saveUserMessage:[[NSUserDefaults standardUserDefaults]objectForKey:usernameMessagePHP]];
                [BSaveMessage saveUserMessage:dict];
                [[BSaveMessage Share] resetInfo:dict];
                [GCUtil saveLajiaobijifenWithJifen:[[[NSUserDefaults standardUserDefaults]objectForKey:usernameMessagePHP] objectForKey:@"jifen"]];

//                promptView.InTheFormOfInt = 1;
//                promptView.hidden = NO;
                
                // 极光推送设置帐号别名
                [APService setAlias:[NSString stringWithFormat:@"QingKeLan%@", kkUserId] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
                [self loadDataWithNoLoginGetMoney];
            }
        }else{
            switch ([[dict objectForKey:@"code"] intValue]) {
                case 100:{
                    [self showMsg:@"用户名不存在!"];
                    break;
                }
                case 102:{
                    [self showMsg:@"密码错误!"];
                    break;
                }
                case 103:{
                    [self showMsg:@"没有登录平台权限!"];
                    break;
                }
                case 203:{
                    [self showMsg:@"系统异常!"];
                    break;
                }
                case 2:{
                    [self showMsg:@"用户锁定!"];
                    break;
                }
                
                default:{
                    [self showMsg:[dict objectForKey:@"message"]];
                    break;
                }
            }
        }
    }else{
        [self showMsg:@"服务器去月球了!"];
    }
    
}

-(void)GCRequest:(GCRequest*)aRequest Error:(NSString*)aError
{
    [self showMsg:@"网络原因!"];
}

#pragma mark 重写返回键方法
- (void)backButtonClick:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    switch (_viewControllerIndex) {
        case 0:
            [self.appDelegate.homeTabBarController.homeTabBar onHomePageButtonClicked:nil];
            break;
        case 1:
            [self.appDelegate.homeTabBarController.homeTabBar onMyGrapeAgencyButtonClicked:nil];
            break;
        case 2:
            [self.appDelegate.homeTabBarController.homeTabBar onRecommandButtonClicked:nil];
            break;
        case 3:
            [self.appDelegate.homeTabBarController.homeTabBar onKnowledgeButtonClicked:nil];
            break;
        default:
            break;
    }
}

#pragma mark 当登录成功跳转到我的页面
- (void)jumpToHomeView
{
    switch (self.viewControllerIndex) {
            
        case 0: // 哪来回哪去
            [self.appDelegate.homeTabBarController.homeTabBar onHomePageButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 1: // 哪来回哪去
            [self.appDelegate.homeTabBarController.homeTabBar onMyGrapeAgencyButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 2: // 哪来回哪去
            [self.appDelegate.homeTabBarController.homeTabBar onRecommandButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 3: // 哪来回哪去
            [self.appDelegate.homeTabBarController.homeTabBar onKnowledgeButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case 4: // 哪来回哪去
//            [self.appDelegate.homeTabBarController.homeTabBar onKnowledgeButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;

            
        case 5: // 修改密码之后登录跳转
            for (UIViewController *ViewContrller in self.navigationController.viewControllers) {
                if ([ViewContrller isKindOfClass:[PersonalCenterViewController class]]) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            break;
        case 6:  // 推送未登录跳转
        {
            [self removeFromParentViewController];
            [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
            [self.appDelegate.homeTabBarController.homeTabBar onSetButtonClicked:nil];
            UINavigationController *nav = (UINavigationController*)self.appDelegate.homeTabBarController.selectedViewController;
            PrizeViewController *prize = [[PrizeViewController alloc] init];
            [nav pushViewController:prize animated:YES];
        }
            break;
        case 8: // 天天宝箱未登录跳转
        {
            [self.appDelegate.homeTabBarController.homeTabBar onHomePageButtonClicked:nil];
            UINavigationController *nav = (UINavigationController*)self.appDelegate.homeTabBarController.selectedViewController;
            PRJ_DayDaytreasureViewController *baoXiang = [[PRJ_DayDaytreasureViewController alloc] init];
            [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
            [nav pushViewController:baoXiang animated:YES];
            [self removeFromParentViewController];
        }
            break;
        default:
            [self removeFromParentViewController];
            [self.appDelegate.homeTabBarController.homeTabBar onSetButtonClicked:nil];
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}

- (IBAction)button_EmailLogingAction:(UIButton *)sender {
    
    BYC_EmailLoginViewController *emailLoginVC = [[BYC_EmailLoginViewController alloc] init];
    
    [self.navigationController pushViewController:emailLoginVC animated:YES];
}

#pragma mark 极光推送设置帐号别名
- (void)tagsAliasCallback:(int)iResCode
                     tags:(NSSet*)tags
                    alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

/**
 {“code”:  101 系统错误
 “message”:”There’s an error.” //错误说明
 }
 展示捞奖次数不足，领取失败，提示可以换个手机号领取
 {“code”:  102 //展示捞奖次数不足
 “message”:” 领取失败，提示可以换个手机号领取.” //失败说明
 }
 
 {“code”:  103 登陆失败
 “message”:”” // 验证码错误 注册失败
 }
 {“code”:  104 //饺子已过期
 “message”:” 饺子已过期” //失败说明
 }
 {““code”:  105 //饺子已被领取
 “message”:” 饺子已被领取.” //失败说明
 }
 {“code”:  106//参数不正确
 “message”:” 参数不正确” //失败说明
 }
 {“code”:  107//饺子配置规则缓存无数据
 “message”:” 饺子配置规则缓存无数据” //失败说明
 }
 {“code”:  108 //用户饺子配置规则缓存无数据
 “message”:” 用户饺子配置规则缓存无数据” //失败说明
 }
 {“code”:  109 //饺子缓存为空
 “message”:” 饺子缓存为空” //失败说明
 }
 */
#pragma mark -- 调用领取接口
-(void)loadDataWithNoLoginGetMoney{
    
    //未登录饺子存储的饺子
    NSMutableArray *dumplingInforNoLogingArray = [NSMutableArray arrayWithContentsOfFile:DumplingInforNoLogingPath];
    NSMutableArray *dumplingIdArray = [NSMutableArray array];//未登录没有领取的饺子
    for (NSDictionary *subDic in dumplingInforNoLogingArray) {
        DumplingInforModel *model = [DumplingInforModel dumplingInforModelWithDic:subDic];
        [dumplingIdArray addObject:model.resultListModel.dumplingModel.prizeId];
    }
    if (dumplingIdArray.count > 0) {
        NSString *dumplingStr =  [dumplingIdArray componentsJoinedByString:@","];
        
        
        //        [self showHudInView:self.view hint:@"正在领取。。。"];
        [LYLAFNetWorking getWithBaseURL:[LYLHttpTool noLogingGetMoneyWithProductCode:ProductCode sysType:SysType sessionValue:SessionValue phone:kkUserName  prizeidList:dumplingStr andUserId:kkUserCenterId] success:^(id json) {
            ZHLog(@"%@",json);
            //            [self hideHud];
            
            switch ([[json objectForKey:@"code"] intValue]) {
                case 100://领取成功
                {
                    //                    [self showHint:@"领取成功"];
                    NSMutableArray *logingArray = [NSMutableArray arrayWithContentsOfFile:DumplingInforLogingPath];
                    if(!logingArray){
                        logingArray = [NSMutableArray array];
                    }
                    [logingArray addObjectsFromArray:dumplingInforNoLogingArray];
                    [logingArray writeToFile:DumplingInforLogingPath atomically:YES];//将未登录的饺子存为已登陆的
                    
                    /**
                     *  更给储存未登陆的饺子信息
                     */
                    [dumplingInforNoLogingArray removeAllObjects];
                    [dumplingInforNoLogingArray writeToFile:DumplingInforNoLogingPath atomically:YES];
                    //promptView.InTheFormOfInt = 1;
                    //promptView.hidden = NO;
                }
                    break;
                case 101:
                {
                    //                    [Tools showInfoAlert:@"系统错误"];
                }
                    break;
                case 102:
                {
                    //                    [Tools showInfoAlert:@"领取失败，可以换个手机号领取"];
                }
                    break;
                case 103:
                {
                    
                    //                    [Tools showInfoAlert:@"登陆失败"];
                }
                    break;
                case 104:
                {
                    [dumplingInforNoLogingArray removeAllObjects];
                    [dumplingInforNoLogingArray writeToFile:DumplingInforNoLogingPath atomically:YES];
                    //                    [Tools showInfoAlert:@"饺子已过期"];
                }
                    break;
                case 105:{
                    [dumplingInforNoLogingArray removeAllObjects];
                    [dumplingInforNoLogingArray writeToFile:DumplingInforNoLogingPath atomically:YES];
                    //                    [Tools showInfoAlert:@"饺子已被领取"];
                }
                    break;
                    
                case 106:
                {
                    //                [Tools showInfoAlert:@"参数不正确"];
                }
                    break;
                case 107:
                case 108:
                case 109:{
                    [dumplingInforNoLogingArray removeAllObjects];
                    [dumplingInforNoLogingArray writeToFile:DumplingInforNoLogingPath atomically:YES];
                    //                    [Tools showInfoAlert:@"饺子信息无效"];
                }
                    break;
                default:
                    break;
            }
            promptView.InTheFormOfInt = 1;
            promptView.hidden = NO;
            [[NoGetMoneyView shareGetMoneyView] refreshShareGetMoneyView];//刷新捞一捞界面未领取金额的数据
            
        } failure:^(NSError *error) {
            ZHLog(@"%@",error);
            //            [self hideHud];
            promptView.InTheFormOfInt = 1;
            promptView.hidden = NO;
        }];
    }
    else {
        promptView.InTheFormOfInt = 1;
        promptView.hidden = NO;
    }
    
}

@end
