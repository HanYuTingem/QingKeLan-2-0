//
//  WebPreviewViewController.m
//  Saoyisao
//
//  Created by 宋鑫鑫 on 14-8-28.
//  Copyright (c) 2014年 pipixia. All rights reserved.
//

#import "WebPreviewViewController.h"
#import "WebInfoViewController.h"
#import "JPCommonMacros.h"
#import "YXSqliteHeader.h"
@interface WebPreviewViewController () < UMSocialUIDelegate >

//自定义navigationBar
{
    UIView *naviView;
}

/*
 *titleBgImageView                  标题背景
 *titleLabel                        标题
 *contentImageView                  内容背景
 *contentLabel                      显示内容
 *myCopyTextBtn                     复制按钮
 *shareBtn                          分享按钮
 *visitWebBtn                       访问网页按钮
 */
@property (strong, nonatomic) IBOutlet UIImageView *titleBgImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *contentImageView;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet UIButton *myCopyTextBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UIButton *visitWebBtn;

@end

@implementation WebPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = YES;
    
    if (naviView) {
        [naviView removeFromSuperview];
    }
    
    [self setNavigationBarWithState:1 andIsHideLeftBtn:NO andTitle:@"网址"];
//    [backImageView setImage:[UIImage imageNamed:@"videodetails_title_btn_back.png"]];
//    backImageView.frame = CGRectMake(10, 33, 10, 18);
    [self.leftButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [super viewWillAppear:YES];
}

//自定义navigationBar
-(void)setWebPreViewNavigationBar
{
    naviView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, IOS7_HEGHT)];
    [self.view addSubview:naviView];
    naviView.backgroundColor = [UIColor colorWithRed:(float)234/255 green:(float)96/255 blue:(float)96/255 alpha:1];
    naviView.userInteractionEnabled = YES;
    
//    UIImageView *naviImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bar_bac.png"]];
//    [naviView addSubview:naviImageView];
//    naviImageView.frame = CGRectMake(0, 20, SCREENWIDTH, IOS7_HEGHT-19);

    UIImageView *BtnimageView = [[UIImageView alloc]init];
    BtnimageView.frame = CGRectMake(0, 20, 45, 45);
    BtnimageView.image = [UIImage imageNamed:@"返回按钮-IOS.png"];
    
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, IOS7_HEGHT)];
    [naviView addSubview:backButton];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(dismissOverlayViewInWebPreView:) forControlEvents:UIControlEventTouchUpInside];
    [backButton addSubview:BtnimageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(115, IOS7_HEGHT_27, 100, 25)];
    titleLabel.center = CGPointMake(self.view.center.x, IOS7_HEGHT_27 + 10 + 5)  ;
    [naviView addSubview:titleLabel];
    titleLabel.text = @"网址";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:19.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //对扫描内容显示的设置
    self.titleBgImageView.frame = CGRectMake(5, 66, SCREENWIDTH - 10, 37);
    self.titleLabel.frame = CGRectMake(105, 73, 110, 25);
    self.titleLabel.center = CGPointMake(SCREENWIDTH / 2 , 85.5);
    
    CGSize size = [self.historyObject.content sizeWithFont:[UIFont systemFontOfSize:15]constrainedToSize:CGSizeMake(SCREENWIDTH - 20, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.text = self.historyObject.content;
    self.contentLabel.frame = CGRectMake(17, self.titleBgImageView.frame.origin.y + self.titleBgImageView.frame.size.height + 12, SCREENWIDTH - 20, size.height);
    
    self.contentImageView.frame = CGRectMake(5, self.titleBgImageView.frame.origin.y + self.titleBgImageView.frame.size.height, SCREENWIDTH - 10, self.contentLabel.frame.size.height + 24);
    UIImageView *lineImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line.png"]];
    lineImageView.frame = CGRectMake(5, self.titleBgImageView.frame.origin.y + self.titleBgImageView.frame.size.height, SCREENWIDTH - 10, 1);
    [self.view addSubview:lineImageView];
    
    self.visitWebBtn.frame = CGRectMake(5, self.contentImageView.frame.origin.y + self.contentImageView.frame.size.height + 20, SCREENWIDTH - 10, 44);
    self.myCopyTextBtn.frame = CGRectMake(5, self.visitWebBtn.frame.origin.y + self.visitWebBtn.frame.size.height + 10, SCREENWIDTH - 10, 44);
    self.shareBtn.frame = CGRectMake(5, self.myCopyTextBtn.frame.origin.y + self.myCopyTextBtn.frame.size.height + 10, SCREENWIDTH - 10, 44);
    //去除多个button同事点击的效果
    [self.visitWebBtn setExclusiveTouch:YES];
    [self.myCopyTextBtn setExclusiveTouch:YES];
    [self.shareBtn setExclusiveTouch:YES];
}

//访问网址点击事件
- (IBAction)visitWebBtbClick:(id)sender
{
    WebInfoViewController *webInfoVC = [[WebInfoViewController alloc]initWithNibName:@"WebInfoViewController" bundle:nil];
    webInfoVC.historyObject = self.historyObject;
    if (naviView) {
        [naviView removeFromSuperview];
    }
    [self.navigationController pushViewController:webInfoVC animated:YES];
}

//复制点击事件
- (IBAction)myCopyBtnClick:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.historyObject.content) {
        pasteboard.string = self.historyObject.content;
    } else {
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"没有可复制的内容" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [av show];
    }
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"网址已经复制到剪切板。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [av show];
}

- (IBAction)shareBtnClick:(id)sender
{
#pragma mark 分享

    self.shareContent = [NSString stringWithFormat:@"%@     (来自《青稞蓝APP》-扫一扫结果) http://qkl.sinosns.cn/",self.historyObject.content];
    [self callOutShareViewWithUseController:self andSharedUrl:@"http://qkl.sinosns.cn/"];
}

//返回上一页
- (void)dismissOverlayViewInWebPreView:(UIButton *)button
{
    if (naviView) {
        [naviView removeFromSuperview];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
