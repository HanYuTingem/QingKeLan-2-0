//  关于我们
//  AboutUsViewController.m
//  ChillingAmend
//
//  Created by 许文波 on 14/12/22.
//  Copyright (c) 2014年 SinoGlobal. All rights reserved.
//

#import "AboutUsViewController.h"
#import "UIImageView+WebCache.h"
#import "RTLabel.h"
#import "GTMBase64.h"

@interface AboutUsViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *aboutUsWebView; // 内容加载webview
@property (weak, nonatomic) IBOutlet UIScrollView *aboutUsScrollView; // 内容scrollview
@property (weak, nonatomic) IBOutlet UIView *aboutUsView; // 二维码 + 分享 view
@property (weak, nonatomic) IBOutlet UIImageView *aboutUsImageView; // 二维码imageView
@property (weak, nonatomic) IBOutlet UIButton *shareBtn; // 分享
@property (weak, nonatomic) IBOutlet UIButton *encourageBtn; // 鼓励我们
@property (weak, nonatomic) IBOutlet UILabel *currentVersionLabel; // 当前版本号
- (IBAction)shareImageAction:(id)sender;
- (IBAction)encourageUsAction:(id)sender;
@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _aboutUsWebView.opaque = NO;
    _aboutUsWebView.backgroundColor  = kkDColor;
    _aboutUsWebView.delegate = self;
    // 多个button同时点击
    _shareBtn.exclusiveTouch = YES;
    _encourageBtn.exclusiveTouch = YES;
    // 导航栏
    [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:@"关于我们"];
    [self requestData];
    // 当前 版本号
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *versionKey = [infoDict objectForKey:@"CFBundleShortVersionString"];
    _currentVersionLabel.text = [NSString stringWithFormat:@"v%@", versionKey];
}

#pragma mark 请求
- (void)requestData
{
    if ([GCUtil connectedToNetwork]) {
        [mainRequest requestHttpWithPost:CHONG_url withDict:[BXAPI aboutUs]];
        [self showMsg:nil];
    } else [self showStringMsg:@"网络连接失败" andYOffset:0];
}

#pragma mark 请求分享内容
- (void) shareContentRequest
{
    if (![GCUtil connectedToNetwork]) {
        [self shareDefalutMessage];
    } else {
        [mainRequest requestHttpWithPost:CHONG_url withDict:[BXAPI shareContentType:@"4"]];
        mainRequest.tag = 103;
        [self showMsg:nil];
    }
}

#pragma mark 分享内容请求返回的数据处理
- (void) setShareContentData:(NSDictionary*)dict
{
    if ([[dict objectForKey:@"code"] intValue] == 1) { // 有分享内容
        self.shareContent = [NSString stringWithFormat:@"%@%@", dict[@"share_content"], dict[@"share_url"]];
        [self callOutShareViewWithUseController:self andSharedUrl:dict[@"share_url"]];
    } else {
        [self shareDefalutMessage];
    }
}

// 分享默认内容
- (void) shareDefalutMessage
{
    self.shareContent = @"想找天上掉馅饼好事？快来青稞蓝app里看看吧，互动游戏奖品送不停~http://qkl.sinosns.cn/";
    self.shareImageName = _aboutUsImageView.image;
    [self callOutShareViewWithUseController:self andSharedUrl:@"http://qkl.sinosns.cn/"];
}

#pragma mark GCRequestDelegate
- (void)GCRequest:(GCRequest *)aRequest Finished:(NSString *)aString
{
    
    [self hide];
    NSMutableDictionary *dict = [aString JSONValue];
    NSLog(@"about us = %@", aString);
    if ( !dict ) {
        if (aRequest.tag == 103) {
            [self shareDefalutMessage];
        } else {
            [self showStringMsg:@"网络连接失败" andYOffset:0];
        }
        return;
    }
    if (aRequest.tag == 103) {
        [self setShareContentData:dict];
    } else {
        if ([[dict objectForKey:@"code"]isEqual:@"0"]) {
            // 图片
            [_aboutUsImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", img_url, [dict objectForKey:@"img"]]] placeholderImage:[UIImage imageNamed:@"defaultimg_list_img1.png"]];
            // 文字
            NSString *aboutUsString = [[NSString alloc] initWithData:[GTMBase64 decodeString:[dict objectForKey:@"about"]] encoding:NSUTF8StringEncoding];
            [_aboutUsWebView loadHTMLString:aboutUsString baseURL:[NSURL URLWithString:@"http://www.baidu.com"]];
        } else {
            [self showStringMsg:[dict valueForKey:@"message"] andYOffset:0];
        }
    }
    
}

- (void)GCRequest:(GCRequest *)aRequest Error:(NSString *)aError
{
    [self hide];
    NSLog(@"%@", aError);
    if (aRequest.tag == 103) {
        [self shareDefalutMessage];
    } else {
        [self showStringMsg:@"网络连接失败！" andYOffset:0];
    }
}

#pragma mark webviewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect rect = webView.frame;
    rect.size.height = webView.scrollView.contentSize.height;
    webView.frame = rect;
    
    _aboutUsView.frame = CGRectMake(ORIGIN_X(_aboutUsView), CGRectGetMaxY(webView.frame) + 20, CGRectGetWidth(_aboutUsView.frame), CGRectGetHeight(_aboutUsView.frame));
    
    [_aboutUsScrollView setContentSize:CGSizeMake(SCREENWIDTH, CGRectGetMaxY(_aboutUsView.frame) - 50)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark 分享二维码
- (IBAction)shareImageAction:(id)sender {
    [self shareContentRequest];
}

#pragma mark 鼓励我们
- (IBAction)encourageUsAction:(id)sender {
    NSString *str = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/la-jiao-quan/id715491678?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}
@end
