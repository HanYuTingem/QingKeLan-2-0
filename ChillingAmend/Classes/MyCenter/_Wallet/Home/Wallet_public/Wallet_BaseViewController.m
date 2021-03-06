//
//  Wallet_BaseViewController.m
//  dreamWorks
//
//  Created by dreamRen on 13-6-23.
//  Copyright (c) 2013年 dreamRen. All rights reserved.
//

#import "Wallet_BaseViewController.h"
#import "JPCommonMacros.h"
#import "SVProgressHUD.h"
#import "UIImageScale.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
#import "UIImageView+WebCache.h"
#import "SINOAFNetWorking.h"
#import "MBProgressHUD+Add.h"
#import "ZXYWarmingView.h"
#import "AFNetworking.h"
#import "mineWalletViewController.h"
#import "UMSocialSinaHandler.h"

//提示框的文字的大小
#define TooltipFontSize 16
@interface Wallet_BaseViewController ()
{
    ZXYWarmingView *WarmingView;
    /** 提示框label */
    UILabel *_tooltipLabel;
}

@end

@implementation Wallet_BaseViewController
@synthesize backView;
#pragma mark -
#pragma mark - 初始化


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    return self;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [SVProgressHUD dismiss];
//    AFHTTPRequestOperationManager* manager=[AFHTTPRequestOperationManager manager];
//    [manager.operationQueue cancelAllOperations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self makeTooltipSelf];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkStateChange:) name:@"netStateChange" object:nil];
}

#pragma mark --  监听网络状态的通知
- (void)netWorkStateChange:(NSNotification *)notInfor{
    NSString *str = (NSString *)notInfor.object;
    if([str isEqualToString:@"1"]){
        ZHLog(@"LaoYiLaoViewController = 有网");
    }else if([str isEqualToString:@"0"]){
        ZHLog(@"LaoYiLaoViewController = 没网");
        [self showMsg:NotReachable];
    }
}

/** 添加提示框 */
- (void)makeTooltipSelf
{
    UILabel *label = [[UILabel alloc] init];
    label.bounds = CGRectMake(0, 0, 120, 40);
    label.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:TooltipFontSize];
    label.numberOfLines = 0;
    label.hidden = YES;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 3;
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    [self.view addSubview:label];
    [label bringSubviewToFront:[[UIApplication sharedApplication] keyWindow]];
    _tooltipLabel = label;
}
/** 提示框 */
-(void)showMsg:(NSString *)msg
{
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:TooltipFontSize],};
    CGSize textSize = [msg boundingRectWithSize:CGSizeMake(ScreenWidth - 100, 150) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    [_tooltipLabel setBounds:CGRectMake(0, 0, textSize.width + 40, textSize.height + 20)];
    _tooltipLabel.text = msg;
    _tooltipLabel.hidden = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _tooltipLabel.hidden = YES;
    });

 
#if 0
    WarmingView.msgViewH = 35;
    [WarmingView showMsg:msg];
#endif
}

//绘制navigationController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    WarmingView = [ZXYWarmingView shareInstance];
    
// 初始化共有类
    self.navigationItem.hidesBackButton=YES;
    self.navigationController.navigationBarHidden = YES;
//  标题栏颜色
//    NSDate *stringDate = [ZHColorConversionObject dateString:@"16:00:00"];
    
    
//  标题栏ImageView
    backView = [[UIView alloc]init];
    backView.frame = CGRectMake(0, 0, ScreenWidth, 65);
    backView.backgroundColor = c7;
    [self.view addSubview:backView];
    
//  返回按钮
    self.leftBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftBackButton.frame=CGRectMake(-5, 20, 44, 44);
//    [self.leftBackButton setImage:[UIImage imageNamed:@"ico_back_s@2x.png"] forState:UIControlStateHighlighted];
//    [self.leftBackButton setImage:[UIImage imageNamed:@"ico_back_n@2x.png.png"] forState:UIControlStateNormal];
    [self.leftBackButton setImage:[UIImage imageNamed:@"Wallettitle_btn_back"] forState:UIControlStateHighlighted];
    [self.leftBackButton setImage:[UIImage imageNamed:@"Wallettitle_btn_back"] forState:UIControlStateNormal];
    self.leftBackButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    [self.leftBackButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    self.leftBackButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.leftBackButton];
    
//  界面背景View
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    mainView.backgroundColor = RGBACOLOR(226, 225, 232, 1);
    [self.view addSubview:mainView];
    [self.view sendSubviewToBack:mainView];
    
    //右边的按钮
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_rightButton setFrame:CGRectMake(ScreenWidth-54, 20, 44, 44)];
    _rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [backView addSubview:_rightButton];
      _rightButton.backgroundColor= [UIColor clearColor];
    [_rightButton addTarget:self action:@selector(rightBackCliked) forControlEvents:UIControlEventTouchUpInside];
    
    
    //标题
    _mallTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(54, 20,ScreenWidth-54*2, 44)];
    _mallTitleLabel.textAlignment = NSTextAlignmentCenter;
    _mallTitleLabel.backgroundColor = [UIColor clearColor];
    _mallTitleLabel.font = H11;
    _mallTitleLabel.textColor =[UIColor whiteColor];
    [backView addSubview:_mallTitleLabel];
    
    
    
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 63.5, kkViewWidth, 0.5)];
    self.lineImageView.backgroundColor = [UIColor colorWithRed:0.83f green:0.83f blue:0.83f alpha:1.00f];
    [backView addSubview:self.lineImageView];
    
    
    // 没有网络时  10.15 添加
//    [GCUtil connectedToNetwork:^(NSString *connectedToNet) {
//        if ([connectedToNet isEqualToString:NotReachable]) {
//            [MBProgressHUD showConnectNetWork:connectedToNet toView:self.view];
//            return ;
//        }
//    }];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
    }
}

#pragma mark - 菊花
/** 开启 */
-(void)chrysanthemumOpen{
    [SVProgressHUD show];
}

/** 关闭 */
-(void)chrysanthemumClosed{
    [SVProgressHUD dismiss];
}

#pragma mark - 按钮方法

//返回按钮
-(void)backButtonClick{
//    for (UIView *view in self.view.subviews) {
//         //view = nil;
////        [view removeFromSuperview];
//    }
    [self.view endEditing:YES];
    [self chrysanthemumClosed];
    [self.navigationController popViewControllerAnimated:YES];
}
// 右侧按钮
-(void)rightBackCliked{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** 返回首页 */
-(void)poptoWalletHomeControllet{
    NSArray  * viewControls= self.navigationController.viewControllers;
    for (UIViewController * viewControl  in viewControls){
        if([viewControl isKindOfClass:[mineWalletViewController class]]){
            [self.navigationController popToViewController:viewControl animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:nil];
            return;
        }
    }
    
}


//跳转登陆
- (void)showLoginLabel:(NSString *)msg withViewController:(UIViewController *)viewController
{
    viewController.view.userInteractionEnabled = NO;
    if (!_loginShowLabel) {
        _loginShowLabel = [[UILabel alloc]init];
        _loginShowLabel.frame = CGRectMake(120, 220, 80, 40);
        _loginShowLabel.font = [UIFont systemFontOfSize:17];
        _loginShowLabel.backgroundColor = [UIColor blackColor];
        _loginShowLabel.textColor = [UIColor whiteColor];
        _loginShowLabel.textAlignment = NSTextAlignmentCenter;
        _loginShowLabel.numberOfLines = 0;
        _loginShowLabel.layer.masksToBounds = YES;
        _loginShowLabel.layer.cornerRadius = 6;
    }
    CGSize size = [msg sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    _loginShowLabel.frame = CGRectMake((ScreenWidth-size.width-20)/2, 200, size.width+20, size.height+20);
    _loginShowLabel.text = msg;
    
    _tempController = viewController;
    [_tempController.view addSubview:_loginShowLabel];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loginViewAction) userInfo:nil repeats:NO];
}

//时间跳转的登录事件
- (void)loginViewAction
{
    _tempController.view.userInteractionEnabled = YES;
    [_loginShowLabel removeFromSuperview];
   // LoginViewController *loginCon = [[LoginViewController alloc]init];
    
    //[_tempController.navigationController pushViewController:loginCon animated:YES];
}

#pragma mark -
#pragma mark -分享
- (void)shareTitle:(NSString *)title withUrl:(NSString *)idStr withContent:(NSString *)content withImageName:(NSString *)imagePath withShareType:(int)shareContentType ImgStr:(NSString *)AimgStr domainName:(NSString *)AdomainName
{
    _shareContentType = shareContentType;
    if (_shareContentType != 0) {
        // 分享标题
    }
    [UMSocialData defaultData].extConfig.qzoneData.title=AdomainName;//qq空间
    [UMSocialData defaultData].extConfig.qqData.title=AdomainName;
    [UMSocialData defaultData].extConfig.wechatSessionData.title=AdomainName;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = AdomainName;
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeDefault url:nil];
    if(imagePath.length > 0) {
        //        imagePath = [NSString stringWithFormat:@"%@%@",IMG_URL,imagePath];
        NSLog(@"shareSDK.image=%@",[NSString stringWithFormat:@"%@",imagePath]);
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imagePath];
    }else {
        
    }
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:WX_APPID appSecret:URL_LYL_SHARE url:idStr];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQ_APPID appKey:QQ_APPKEY url:idStr];
    [UMSocialSinaHandler openSSOWithRedirectURL:OpenSSOWithRedirectURL];
    
    NSString *contentTitle = @"";
    if ([content isEqualToString:@""]) {
        contentTitle = @"云旅伴是一款全新的电视互动平台，让广大电视朋友在这里不但可以看到精彩的电视节目，还可以参加多种多样的互动活动，实现和观众的直接互动体验，当然还有众多的缤纷大奖等待你的到来！";
    }else{
        //设置分享内容
        contentTitle = [NSString stringWithFormat:@"%@ %@ %@",title,content,idStr];
    }
    UIImage *shareImage;
    if ([AimgStr isEqualToString:@""]) {
        shareImage = [UIImage imageNamed:@"Wallet_youhuijuan-morentuShare"];
    }else{
        NSURL * imageURL = [NSURL URLWithString:AimgStr];
        NSData * data = [NSData dataWithContentsOfURL:imageURL];
        shareImage = [UIImage imageWithData:data];
    }
    
    //设置分享
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:LYL_UM_KEY
                                      shareText:contentTitle
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil]
                                       delegate:self];
    
}


-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    _isShareLoading = NO;
    [UMSocialConfig setFinishToastIsHidden:YES position:UMSocialiToastPositionCenter];
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [self showMsg:@"分享成功"];
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        NSLog(@"分享成功");
        
        // 需要展示分享数量的界面在这里发送通知~~~~~~~
        //shareContentType 投票首页1 投票详情2  报名详情3 节目首页4 节目详情5  爆料首页6 爆料详情7 活动详情8 资讯详情9 评论分享10  个人足迹分享11  获奖详情分享12 邀请分享13 关于界面的分享14  扫一扫分享15 魔幻拼图分享16
        if (_shareContentType == 6) {//爆料首页
            [self.turnDelegate discloseIndexTurnCount];
        }else if (_shareContentType == 7) {//爆料详情
            [self.turnDelegate discloseDetailTurnCount];
        }
    }else {
        if (response.responseCode == UMSResponseCodeShareRepeated) {
            [self showMsg:@"这条信息您已分享过了"];
        }else if (response.responseCode == UMSResponseCodeCancel) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self showMsg:@"您已取消此次分享"];
            });
        }else{
            [self showMsg:@"分享失败"];
        }
    }
}
@end
