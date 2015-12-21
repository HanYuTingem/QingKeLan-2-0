//
//  LSYGoodsInfoViewController.m
//  MarketManage
//
//  Created by liangsiyuan on 15/1/13.
//  Copyright (c) 2015年 Rice. All rights reserved.
//

#import "LSYGoodsInfoViewController.h"
#import "ASIHTTPRequest.h"
#import "MarketAPI.h"
#import "SBJSON.h"
#import "LSYGoodsIMGShowView.h"
#import "LSYEntityGoodsView.h"
#import "LSYEvaluationView.h"
#import "LSYBigImgShowView.h"
#import "LSYConfirmOrderViewController.h"
#import "ZXYCommentListViewController.h"
#import "ZXYPurchaseConsultViewController.h"
#import "LSYImageDetailsViewController.h"
#import "LSYImageDetails.h"
#import "ZXYRecommendView.h"
#import "GCRequest.h"

#import "shoppingCarViewController.h"//现在的购物车 2015.7
#import "CJAttributeModle.h"//属性规格模型
#import "CJAttributeSpecModel.h"//具体模型 名称
#import "CJAttributeSelectController.h"//选择属性界面
#import "CJAttributeBtnView.h" //商品属性功能模块
#import "CJShoppingButtonView.h" //购物车按钮
#import "CrazyShoppingCartViewController.h"//原来的购物车

#import "LSYHomePageViewController.h"

#import "JSBadgeView.h"

@interface LSYGoodsInfoViewController ()<UIScrollViewDelegate,LSYGoodsIMGShowViewDelegate,LSYEvaluationViewDelegate,LSYImageDetailsDelegate,LSYEntityGoodsViewDelegate,ASIHTTPRequestDelegate,GCRequestDelegate,UIGestureRecognizerDelegate>

{
    /** 添加选项属性功能的View */
    CJAttributeBtnView *_btnView;
    /** 导航栏右侧 购物车 */
    CJShoppingButtonView *_shopBtnView;
    /** 商品属性详情页传过来的模型 */
    CJAttributeModle *_attributeModel;
    /** 商品属性详情页传过来的商品购买数量 */
    NSString *_attributeGoodsNums;
    /** 试图蒙板 */
    UIView *_maskView;
}

/** 大的scrollView */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)GCRequest * lsyMainRequest;
/** 下面三个按钮的父试图View */
@property (weak, nonatomic) IBOutlet UIView *menuToolsView;
/** 去逛逛按钮 */
@property (weak, nonatomic) IBOutlet UIButton *quGuangGuang;
/** 没有商品的页面View */
@property (weak, nonatomic) IBOutlet UIView *noGoodsInfo;
/** 没有商品的页面中的图片距离顶部的高度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noGoodsImageH;

/** 下面收藏按钮的文字 */
@property (weak, nonatomic) IBOutlet UILabel *collectLebel;


@property(nonatomic,strong)LSYEvaluationView * evaluation;
@property (nonatomic,strong)LSYImageDetails* imageDetails;

@property (nonatomic,copy) JSBadgeView * badgeView;

/** 轮播图 */
@property (nonatomic,strong)  LSYGoodsIMGShowView * goodsBanner;
/** 实体商品 */
@property (nonatomic,strong)  LSYEntityGoodsView * entity;
/** 是否是包邮的商品 */
@property (nonatomic,assign)  BOOL isBaoYouGoods;
/** 判断是否请求成功 */
@property (nonatomic,assign)BOOL alreadySubmit;
/** 商品介绍 */
@property (nonatomic,strong)NSDictionary * goodsInfoDic;
/** 厂家介绍 */
@property (nonatomic,strong)NSDictionary * changShangInfoDic;
/** 咨询内容 */
@property (nonatomic,strong)NSDictionary * evaluationDic;
/** 评论内容 */
@property (nonatomic,strong)NSDictionary * ziXunDic;
/** 咨询内容 */
@property (nonatomic,assign)int  evaCount;
/** 评论内容 */
@property (nonatomic,assign)int  ziXunCount;
/** 商品 模型 */
@property (strong,nonatomic) LSYGoodsInfo * goods;
@property (nonatomic,copy)NSString * ms_sign;
/** 成功收藏 */
@property (nonatomic,assign)BOOL isAlreadyCollection;
/** 购买限制 */
@property (nonatomic,copy)NSString *  bugWarring;
/** 点击（更多）的右边的按钮 */
@property (weak, nonatomic) IBOutlet UIView   *goodsinfoRightMoreView;
/** 商品详情里面的（更多） 收藏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *goodsinfoCollectionBtn;
/** 商品详情里面的（更多） 收藏按钮的高 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goodsInfoContastBtnH;
/** 商品详情里面的（更多） 收藏按钮下面的横线 */
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

/** 商品详情里面的（更多） 联系客服按钮 */
@property (weak, nonatomic) IBOutlet UIButton *goodsinfoContastBtn;
/** 商品详情里面的（更多） 返回首页的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *goodsinfoHomePageBtn;
/** 点击对应的导航右上角的（更多） 点击事件方法 */
- (IBAction)goodsinfoMoreBtnCliked:(id)sender;

@end

@implementation LSYGoodsInfoViewController

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GoodsInfoViewControllerReloadData" object:nil];
    
}
#pragma mark - life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    NSInteger width = ScreenWidth / 5.0f;
//    _buttonwidth.constant = width;
//    _equalwidth.constant = 2 * width;
    
    self.noGoodsImageH.constant = 112 *SP_HEIGHT;
    
    self.mallTitleLabel.text = @"商品详情";
    [self.rightButton setImage:[UIImage imageNamed:@"lyq_mallifo_rightTitle_image.png"] forState:UIControlStateNormal];
    self.collectLebel.textColor = [UIColor colorWithRed:0.55f green:0.55f blue:0.55f alpha:1.00f];
    
#pragma mark 2015年7月21日 新加右侧购物车导航按钮
    CJShoppingButtonView *shopBtnView = [[CJShoppingButtonView alloc] initWithFrame:CGRectMake(ScreenWidth - 54 - 44, 20, 64, 64)];
    [shopBtnView.ShoppingButton addTarget:self action:@selector(shoppingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shopBtnView];
    _shopBtnView = shopBtnView;
   
    self.goodsinfoRightMoreView.hidden = YES;
    
    [self.view addSubview:self.goodsinfoRightMoreView];

    self.goodsInfoDic=[NSDictionary dictionary];
    self.changShangInfoDic=[NSDictionary dictionary];
    
    //添加手势
    [self addAGesutreRecognizerForYourView];
       
    self.goods =[[LSYGoodsInfo alloc]init];
    //判断是否是秒杀商品
    [self isSeckillingGoodsInfo];
    
    //原下面购物车按钮上面的提示数字  现已去掉
//    _badgeView = [[JSBadgeView alloc] initWithParentView:_shoppingImageView alignment:JSBadgeViewAlignmentTopRight];
    
    if(_entity){
        _entity.goods = self.goods;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(relaoteGoodsData) name:@"GoodsInfoViewControllerReloadData" object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.scrollView.delegate=self;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //刷新导航右边的购物车数量
    [_shopBtnView getCardNumData];
    //添加导航右边的弹出框 隐藏
    self.goodsinfoRightMoreView.frame = CGRectMake(self.view.frame.size.width-127, 50, 122, 140 - 44);
    self.goodsInfoContastBtnH.constant = 0;
    self.goodsinfoCollectionBtn.hidden = YES;
    
    self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
    
//    if (self.isInvalid ) {
//        [self initializeNoGoodsInfo];
//    }
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.goodsinfoRightMoreView.hidden = YES;
    self.scrollView.delegate=nil;
    self.lsyMainRequest.delegate=nil;
    [self.lsyMainRequest cancelRequest];
}

/** 添加点击事件 （手势） */
- (void)addAGesutreRecognizerForYourView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesturedDetected:)]; // 手势类型随你喜欢。
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}
//方法
- (void) tapGesturedDetected:(UITapGestureRecognizer *)recognizer

{
    self.goodsinfoRightMoreView.hidden = YES;
    [[[[UIApplication sharedApplication]delegate]window] endEditing:YES];
    // do something
}

/** 判断是否是秒杀商品 */
- (void)isSeckillingGoodsInfo
{
    if (self.isSeckilling) {
        //秒伤详情 秒杀商品不能够加入购物车
        [self getMiaoShaInfo];
        self.addShoppingCartBtn.hidden = YES;
//        self.shoppingCartBtn.hidden = YES;
////        self.shoppingImageView.hidden = YES;
//        self.shoppingLabel.hidden = YES;
    }else{
        [self getServeicesData];
    }
}
/** 设置商品详情请求数据的条件 */
- (void)setGoodsStatus
{
    //获取评论和购买咨询
    [self getEvaluation:1];
    [self initializeUI:self.goods];

    if (self.goods.isSeckilling) {
        self.addShoppingCartBtn.hidden = YES;
//        self.shoppingCartBtn.hidden = YES;
////        self.shoppingImageView.hidden = YES;
//        self.shoppingLabel.hidden = YES;
    }
}
/** 刷新表格 */
- (void)relaoteGoodsData
{
    [self isSeckillingGoodsInfo];
}

#pragma mark - 导航栏上的点击事件
/** 导航左边按钮 */
- (void)leftBackCliked:(UIButton*)sender
{
    self.lsyMainRequest.delegate=nil;
    [self.lsyMainRequest cancelRequest];
    if (self.needsPoPtoRoot) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }

}
/** 导航栏右侧 购物车 的点击事件 */
- (void)shoppingButtonClick
{
    
    if ([kkUserId isEqual:@""] || !kkUserId) {
        //去登陆
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.viewControllerIndex = 4;
        [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
        [self.navigationController pushViewController:login animated:YES];
    }
    
//    if (kkNickDicPHP == nil || [UserId isEqualToString:@""]) {
//        [MarketAPI jumLoginControllerWithNavPush:self.navigationController];
//    }
    else {
        shoppingCarViewController *shopBuyCar = [[shoppingCarViewController alloc] init];
        [self.navigationController pushViewController:shopBuyCar animated:YES];
    }
    
    
//    CrazyShoppingCartViewController *shoppingCartVC = [[CrazyShoppingCartViewController alloc] init];
//    [self.navigationController pushViewController:shoppingCartVC animated:YES];
}

/** 导航右边的更多按钮 */
- (void)rightBackCliked:(UIButton*)sender{
    
    self.goodsinfoRightMoreView.hidden = !self.goodsinfoRightMoreView.hidden;
}

/** 商品详情的右边弹出框的（更多） 点击事件 */
- (IBAction)goodsinfoMoreBtnCliked:(id)sender {
    
    self.goodsinfoRightMoreView.hidden = !self.goodsinfoRightMoreView.hidden;
    UIButton * btn = (UIButton*)sender;
    switch (btn.tag) {
        case 0:{//收藏
            
            if (kkUserCenterId && ![kkUserCenterId isEqual:@""]) {
                if (self.isAlreadyCollection) {
                    [self setCancleCollectionToSeverices];
                }else{
                    [self setCollectionToSeverices];
                }
            }else{
                //调转登陆页面
                [MarketAPI jumLoginControllerWithNavPush:self.navigationController];
            }

        }
            break;
        case 1://联系客服
        {
            
            NSRange range = [_goods.shop_tel rangeOfString:@","];
            NSMutableString * str;
            if (range.location !=NSNotFound) {
                NSArray * tmpArray=   [_goods.shop_tel componentsSeparatedByString:@","];
                str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",tmpArray[0]];
            }else{
                str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",_goods.shop_tel];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

        }
            break;
        case 2://首页
        {
            
//            [self.navigationController popToRootViewControllerAnimated:YES];
//            [self.navigationController popToViewController:home animated:YES];
//            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
//            [[NSNotificationCenter defaultCenter] postNotificationName:PUSH_LSYHomePageViewController object:nil userInfo:nil];
            
            
//            for ( int i = 0;i < [self rootNavController].viewControllers.count;i++) {
//                if ([[self rootNavController].viewControllers[i] isKindOfClass:[LSYHomePageViewController class]]) {
//                    LSYHomePageViewController * viewController = [self rootNavController].viewControllers[i];
//                    [[self rootNavController] popToViewController:viewController animated:YES];
////            viewController.scrollView.contentOffset = CGPointMake(0, 0);
//                    return;
//                }
//            }
//            LSYHomePageViewController * viewController = [[LSYHomePageViewController alloc]init];
//            [[self rootNavController] pushViewController:viewController animated:YES];
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[LSYHomePageViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                }
            }
            
            GAHomeTabBarController *tabbar = [GAHomeTabBarController sharedHomeTabBarController];
            [tabbar selectTabBarAtIndex:2];
            [tabbar.homeTabBar selectTabBarAtIndex:2];
            
//            LSYHomePageViewController * viewController = [[LSYHomePageViewController alloc]init];
//            [self.navigationController pushViewController:viewController animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
           
            
            
            break;
            
        default:
            break;
    }
}

-(UINavigationController *)rootNavController
{
    return (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
}

-(void)initializeNoGoodsInfo
{
    self.rightButton.hidden = YES;
    self.menuToolsView.hidden=YES;
    self.noGoodsInfo.hidden=NO;
    self.scrollView.hidden = YES;
    _shopBtnView.hidden = YES;
//    [self.noGoodsInfo bringSubviewToFront:self.view];
    [MarketAPI setRedButton:self.quGuangGuang];
    [_goodsBanner removeFromSuperview];
    [_entity removeFromSuperview];
    [_activityPromotionView removeFromSuperview];
    [self.evaluation removeFromSuperview];
    [self.imageDetails removeFromSuperview];
    self.scrollView.contentSize=CGSizeMake(self.view.bounds.size.width,508);


}

-(void)initializeUI:(LSYGoodsInfo*)goods
{
    
    //Scorllview初始化
    self.scrollView.maximumZoomScale=2.0;
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.delegate=self;
    self.scrollView.delaysContentTouches=YES;
    
    if (self.isAlreadyCollection) {
        [self.goodsinfoCollectionBtn setTitle:@"已收藏" forState:UIControlStateNormal];
        self.collectLebel.text = @"已收藏";
        self.shoppingImageView.selected = YES;
    }else{
        [self.goodsinfoCollectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
        self.collectLebel.text = @"收藏";
        self.shoppingImageView.selected = NO;
    }
    
    //计算高度
    float height=0;
    
    
    if(!_goodsBanner){
        _goodsBanner=[[LSYGoodsIMGShowView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, ScreenWidth)];
        _goodsBanner.delegate=self;
        _goodsBanner.goods=goods;
        [self.scrollView addSubview:_goodsBanner];
    }
   
    height+=ScreenWidth;
    
        //实体商品
        if(!_entity){
            _entity=[[LSYEntityGoodsView alloc]initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, 158)];
            _entity.delegate=self;
            _entity.goods=goods;
            
            //去掉库存显示
            _entity.repertoryHeight = 0;
            _entity.goods_Kucun.hidden = YES;
            CGRect frame = _entity.frame;
            frame.size.height = 133;
            _entity.frame = frame;
            
            [self.scrollView addSubview:_entity];
            
            if(!self.isBaoYouGoods )
            {
                
                _activityPromotionView.frame = CGRectMake(0, height+ _entity.frame.size.height,self.view.bounds.size.width, 44);
                self.serviceView.frame = CGRectMake(0, 2, self.serviceView.frame.size.width, self.serviceView.frame.size.height);
                self.salesViewHeight = 0;
                self.SalesView.hidden = YES;
                NSLog(@"--------------------%f----------%f-------%f-----%f",_entity.frame.size.height,height,self.serviceView.frame.size.width,self.serviceView.frame.size.height);
                
            }else{
                self.salesViewHeight.constant = 44;
                _activityPromotionView.frame = CGRectMake(0, height+ _entity.frame.size.height,self.view.bounds.size.width, 88);
                NSLog(@"--------------------%f----------%f-------%f-----%f",_entity.frame.size.height,height,self.serviceView.frame.size.width,self.serviceView.frame.size.height);
            }
            [self.scrollView addSubview:_activityPromotionView];
            
            
        }
//        height+=_entity.frame.size.height + _activityPromotionView.frame.size.height + 10 *SP_HEIGHT;
    
#pragma mark - 2015.07 增加 选择属性 功能
    //判断是否是包邮商品 改变间距
//    if (!self.isBaoYouGoods) {
//        height = CGRectGetMaxY(_activityPromotionView.frame) + 14 *SP_HEIGHT;
//    } else {
//        height = CGRectGetMaxY(_activityPromotionView.frame) + 14 *SP_HEIGHT;
//    }
    height = CGRectGetMaxY(_activityPromotionView.frame) + 14 *SP_HEIGHT;
    
    //判断请求下来的的商品属性是否有值 有值创建
    if (self.goods.attr_spec.count) {
        //添加选项属性功能的View
        _btnView = [[CJAttributeBtnView alloc] initWithFrame:CGRectMake(0, height, ScreenW, 44 *SP_HEIGHT)];
        //添加点击事件
        [_btnView.btn addTarget:self action:@selector(btnViewClick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (_attributeModel.spec_idArray.count) {
            NSMutableString *str = [NSMutableString string];
            for (CJAttributeSpecModel *specModel in _attributeModel.spec_idArray) {
                [str appendFormat:@"%@ ",specModel.value];
            }
            _btnView.attributeLabel.text = str;
            _btnView.selectLabel.text = @"已选";
        }
        [self.scrollView addSubview:_btnView];
        
        height = CGRectGetMaxY(_btnView.frame) + 14 *SP_HEIGHT;
    }
    
    
    //评论&咨询
//    if (self.goods.type == 2) {
        self.evaluation=[[LSYEvaluationView alloc]initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, 230)];
//    }else{
//        self.evaluation=[[LSYEvaluationView alloc]initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, 230)];
//    }
    self.evaluation.evaCount=self.evaCount;
    self.evaluation.zixunCount=self.ziXunCount;
    self.evaluation.ziXunDic=self.ziXunDic;
    self.evaluation.evaluationDic=self.evaluationDic;
    self.evaluation.delegate=self;
    [self.scrollView addSubview:self.evaluation];
    if (self.goods.type == 2) {
        height+=230;
    }else{
        height+=244;
    }
    self.scrollView.contentSize=CGSizeMake(self.view.bounds.size.width,height+10);
    
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, ScreenHeight - 64)];
    _maskView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _maskView.hidden = YES;
    [self.view addSubview:_maskView];
    
    //9.24
    self.imageDetails=[[LSYImageDetails alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT , SCREENWIDTH, SCREENHEIGHT - 64 )];
    self.imageDetails.delegate=self;
    [self.view addSubview:self.imageDetails];
    [self.view bringSubviewToFront:self.menuToolsView];
    
}


/**
 * 新增加的选择属性按钮的点击事件
 */
- (void)btnViewClick:(UIButton *)sender
{
    self.goodsinfoRightMoreView.hidden = YES;
    //提前给商品详情页负值
    CJAttributeSelectController *SVC = [self makeAttributeController];
    
    SVC.restriction = self.goods.restriction;
    SVC.isSeckilling = self.goods.isSeckilling;
    SVC.getAttributeModel = _attributeModel;
    SVC.getAttributeGoodsNums = _attributeGoodsNums;
    SVC.isupdate = self.isupdate;
    //判断是否是秒杀商品 秒杀页直接跳转立即购买
    if (self.goods.isSeckilling) {
        SVC.attributeSelect = AttributeSelectBuyNow;
    }
    
    __weak LSYGoodsInfoViewController *weakSelf = self;
    SVC.blockAttribute = ^(CJAttributeModle *attributeModel,NSString *numLabelText){
        
        _attributeModel = attributeModel;
        _attributeGoodsNums = numLabelText;
        // 选择属性按钮的回调负值
        [weakSelf makeNewDataWith:attributeModel goodsNums:numLabelText];
        
    };
    
    [self.navigationController pushViewController:SVC animated:YES];
}
/** 选择属性按钮的回调负值 */
- (void)makeNewDataWith:(CJAttributeModle *)attributeModel goodsNums:(NSString *)numLabelText
{
    //刷新右侧购物车数量
    [_shopBtnView getCardNumData];
    NSMutableString *str = [NSMutableString string];
    for (CJAttributeSpecModel *specModel in attributeModel.spec_idArray) {
        [str appendFormat:@"%@ ",specModel.value];
    }
    _btnView.attributeLabel.text = str;
    _btnView.selectLabel.text = @"已选";
    [self setAttributeModel:attributeModel goodsNums:numLabelText];
    
    self.entity.goods_Price.text = [MarketAPI judgeCostTypeWithCash:[NSString stringWithFormat:@"%@",attributeModel.cash] andIntegral:[NSString stringWithFormat:@"%.0f",self.goods.price] withfreight:@"0" withWrap:NO];
}


/**
 * 负值给全局变量的CJAttributeModle模型
 */
- (void)setAttributeModel:(CJAttributeModle *)attributeModel goodsNums:(NSString *)goodsNums
{
    _attributeModel = attributeModel;
    _attributeGoodsNums = goodsNums;
}

/**
 * 添加商品属性详情页
 */
- (CJAttributeSelectController *)makeAttributeController
{
    CJAttributeSelectController *SVC = [[CJAttributeSelectController alloc] init];
    //确定是什么样的界面 下面按钮是添加还是立即购买
    //    SVC.attributeSelect = AttributeSelectBuyNow;
    SVC.restriction = self.goods.restriction;
    SVC.goods = self.goods;
    SVC.hd_id = self.hd_id;
    SVC.bugWarring = self.bugWarring;
    SVC.isSeckilling = self.isSeckilling;
    SVC.alreadySubmit = self.alreadySubmit;
    SVC.isupdate = self.isupdate;
    return SVC;
}


/**
 * 实物需要刷新
 */
-(void)entityNeedReload
{
    [self getServeicesData];
}
#pragma mark - ScrollView_Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y+scrollView.frame.size.height>=scrollView.contentSize.height+70) {
        [self changeToCollectionView];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.goodsinfoRightMoreView.hidden = YES;
}

/** 代理方法 */
-(void)backToTopView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 32);
        self.imageDetails.center=CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height*2);
        self.rightButton.hidden = NO;
        _shopBtnView.hidden = NO;
        self.mallTitleLabel.text = @"商品详情";

    }];
    _maskView.hidden = YES;
    self.scrollView.hidden = NO;
}

-(void)changeToCollectionView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.scrollView.center=CGPointMake(self.view.frame.size.width/2, -self.view.frame.size.height/2 );
        CGRect frame = self.imageDetails.frame;
        frame.origin.y = 64;
        self.imageDetails.frame = frame;
        self.goodsinfoRightMoreView.hidden = YES;
        self.rightButton.hidden = YES;
        _shopBtnView.hidden = YES;
        self.mallTitleLabel.text = @"图文详情";

    }];
//    _maskView.hidden = NO;
    self.scrollView.hidden = YES;
}

#pragma mark - 网络请求
/**  厂商介绍 不是1 是商店的id 1时是商品的id 15.8 3是商品属性 */
-(void)getChangShangInfo:(NSString *)type
{
    self.lsyMainRequest = [MarketAPI requestChangshangInfoPost103Controller:self good_shopId:_goods.shop_id goods_id:_goods_id type:type];
}
/**  商品详情*/
-(void)getServeicesData
{
    [self startActivity];
    self.lsyMainRequest = [MarketAPI requestGoodsInfoPost102WithController:self goodsId:_goods_id];
}
/** 秒杀信息 */
-(void)getMiaoShaInfo
{
    [self startActivity];
    self.lsyMainRequest = [MarketAPI requestMiaoShaPost603WithController:self good_id:_goods_id hd_ID:_hd_id];
}
/** 收藏商品*/
-(void)setCollectionToSeverices
{
    self.lsyMainRequest = [MarketAPI requestCollection505WithController:self good_id:_goods_id];
}
/** 取消收藏 */
-(void)setCancleCollectionToSeverices
{
    self.lsyMainRequest = [MarketAPI requestCancelCollection507WithController:self good_id:_goods_id];
}
/** 获取评论/购买咨询 1=售后评论，2=售前咨询 */
-(void)getEvaluation:(int)type
{
    self.lsyMainRequest = [MarketAPI requestEvlautionAndZiXun104WithController:self good_id:_goods_id type:type];
}
/** 立即购买 */
-(void)seckillingBuy
{
    self.showWaiting.hidden=NO;
    self.lsyMainRequest = [MarketAPI requestSeckillingBuy604WithController:self good_id:_goods_id];
}


/** 商品的信息处理 */
- (void)goodsInfoDict:(NSDictionary*)dict
{
    self.goods.host             =[dict objectForKey:@"host"];
    self.goods.images           =[dict objectForKey:@"images"];
    self.goods.name             =[dict objectForKey:@"name"];
    self.goods.shop_name        =[dict objectForKey:@"shop_name"];
    self.goods.introduce        =[dict objectForKey:@"introduce"];
    self.goods.price            =[[dict objectForKey:@"price"]floatValue];
    self.goods.restriction      =[[dict objectForKey:@"restriction"]intValue];
    self.goods.shop_tel         =[dict objectForKey:@"shop_tel"];
    self.goods.shop_introduce   =[dict objectForKey:@"shop_introduce"];
    self.goods.nums             =[[dict objectForKey:@"nums"]intValue];
    self.goods.shop_id          =[dict objectForKey:@"shop_id"];
    self.goods.p_id             =[dict objectForKey:@"p_id"];
    self.goods.available        =[[dict objectForKey:@"available"]intValue];
    self.goods.is_shipping      =[dict objectForKey:@"is_shipping"];
    self.goods.type             =[[dict objectForKey:@"type"]intValue];
    self.goods.goods_id         =self.goods_id;
    if (self.goods.type==2) {
    self.goods.use_start_time   =[dict objectForKey:@"use_start_time"];
    self.goods.use_end_time     =[dict objectForKey:@"use_end_time"];
    }
    self.goods.end_time         =[dict objectForKey:@"end_time"];
    self.goods.is_self          =[[dict objectForKey:@"is_self"]boolValue];
    self.goods.bum_convert      =[dict objectForKey:@"bum_convert"];
    self.goods._img_url         =[dict objectForKey:@"img_url"];
    self.goods.cash             =[[dict objectForKey:@"cash"]floatValue];
    self.goods.ys_type          =[dict objectForKey:@"ys_type"];
    self.goods.shop_addr        =[dict objectForKey:@"shop_addr"];
    self.goods.shopo_phone      =[dict objectForKey:@"shop_phone"];
    self.goods.ms_price         =[dict objectForKey:@"ms_price"];
    self.goods.isSeckilling     =[[dict objectForKey:@"is_ms"]boolValue];
    self.isAlreadyCollection    =[[dict objectForKey:@"is_collected"]boolValue];
    self.alreadySubmit          =YES;
    self.goods.freeShip         =[dict objectForKey:@"free_ship"];
    self.goods.act_id           = [dict objectForKey:@"act_id"];
    self.goods.goodCardNum      = IfNullToString([dict objectForKey:@"goodscart_nums"]);

    if([self.goods.goodCardNum integerValue] > 0){
        if([self.goods.goodCardNum integerValue]>99){
            _badgeView.badgeText =  @"99+";
        }else{
            _badgeView.badgeText =  self.goods.goodCardNum;
        }
    }else{
        _badgeView.badgeText =  @"";
    }
    
       self.isBaoYouGoods = NO;
    if([self.goods.is_shipping boolValue] || ([[dict objectForKey:@"activity_type"] boolValue]&&[self.goods.freeShip intValue]!=0)){
        self.isBaoYouGoods = YES;
    }
    if([[dict objectForKey:@"activity_type"] boolValue]&&[self.goods.freeShip intValue]==2){
        self.goodsPostage.text = [dict objectForKey:@"free_message"];
    }

    self.goodsShopName.text = [NSString stringWithFormat:@"该商品由%@提供并发货",self.goods.shop_name];
    
    
//    2015.07 添加商品属性功能
    self.goods.attr_spec = [NSMutableArray array];
    for (NSDictionary *dic in dict[@"attr_spec"]) {
        CJAttributeModle *attrModel = [CJAttributeModle ModelwithDict:dic];
        [self.goods.attr_spec addObject:attrModel];
    }
    
    NSLog(@"self.goods.attr_spec =---==== %lu",(unsigned long)self.goods.attr_spec.count);
    
}

-(void)GCRequest:(GCRequest *)aRequest Finished:(NSString *)aString
{
    
    [self stopActivity];
    NSDictionary * dict = [aString JSONValue];
    
    if (!dict){
        NSLog(@"接口错误");
        return;
    }
    switch (aRequest.tag) {
        case 99:
        {
            if ([dict[@"code"] integerValue] == 0 && dict[@"code"] != nil) {
                [self goodsInfoDict:dict];
            }
            [dict[@"code"]integerValue]==5 ? [self initializeNoGoodsInfo]:[self setGoodsStatus] ;
            
        }
            break;
        case 1:
        {
            self.evaCount=[[dict objectForKey:@"pageTotal"]intValue];
            self.evaluationDic=dict;
            [self initializeUI:self.goods];

            [self getEvaluation:2];
        }
            break;
        case 2:
        {
            self.ziXunCount=[[dict objectForKey:@"pageTotal"]intValue];
            self.ziXunDic=dict;
            [self initializeUI:self.goods];
            //获取图文详情地址
            [self getChangShangInfo:@"1"];
            
        }
            break;
        case 505:
        {
            if ([dict[@"code"]integerValue]==0) {
                [self showMsg:@"添加收藏成功"];
                self.collectLebel.text = @"已收藏";
                self.shoppingImageView.selected = YES;
                [self.goodsinfoCollectionBtn setTitle:@"已收藏" forState:UIControlStateNormal];
                self.isAlreadyCollection=YES;
            }else if([dict[@"code"]integerValue]==9){
                [self.goodsinfoCollectionBtn setTitle:@"已收藏" forState:UIControlStateNormal];
                self.collectLebel.text = @"已收藏";
                self.shoppingImageView.selected = YES;
                self.isAlreadyCollection=YES;
                [self showMsg:@"您已经收藏了该商品\n无需重复收藏"];
            }else{
                [self showMsg:@"添加收藏失败,请您稍后再试"];
            }
        }
            break;
        case 507:
        {
            if ([dict[@"code"]integerValue]==0) {
                [self showMsg:@"取消收藏成功"];
                self.collectLebel.text = @"收藏";
                self.shoppingImageView.selected = NO;
                [self.goodsinfoCollectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
                self.isAlreadyCollection=NO;
            }else{
                [self showMsg:@"取消收藏失败,请您稍后再试"];
            }
        }
            break;
//        case 1031:
//        {
//            self.goodsInfoDic=dict;
//            self.imageDetails.dict=dict;
//            [self getChangShangInfo:@"2"];
//        }
//            break;
            
//        case 1032:
//        {
//            self.changShangInfoDic=dict;
//            self.imageDetails.dictChangShang=dict;
//        }
//            break;
            
#pragma mark - 2015.8 添加的 商品详情页 商品属性页 网络请求
        case 1031:
        {
            NSLog(@"------dict1031 -- %@",dict);
            self.goodsInfoDic=dict;
            self.imageDetails.dict=dict;
            [self getChangShangInfo:@"3"];
        }
            break;
        case 1033:
        {
            NSLog(@"------dict -- %@",dict);
            self.changShangInfoDic=dict;
            self.imageDetails.dictChangShang=dict;
        }
            break;
        case 603:
        {
            if ([dict[@"code"] integerValue] == 0 && dict[@"code"] != nil) {
                
                [self goodsInfoDict:dict];
            }
            if ([dict[@"code"]integerValue]!=5 ||( dict[@"is_activity"] &&[dict[@"is_activity"]boolValue])) {
                //获取评论和购买咨询
                [self getEvaluation:1];
                [self initializeUI:self.goods];
            }else{
                [self initializeNoGoodsInfo];
            }
            
        }
            break;
        case 604:
        {
            if ([dict[@"code"]integerValue]==0) {
                //立即秒杀
                [self gotoSekillGoodsInfo:dict];
                
            }else if([dict[@"code"]integerValue]==103){
                [self showMsg:@"超出限购了\n你不能买这么多啊亲"];
                self.bugWarring=@"超出限购了\n你不能买这么多啊亲";
            }else if([dict[@"code"]integerValue]==100){
                [self showMsg:@"已抢光"];
                self.bugWarring=@"已抢光";
            }else if([dict[@"code"]integerValue]==96){
                [self showMsg:@"活动未开始"];
                self.bugWarring=@"活动未开始";
            }
        }
            break;
        default:
            break;
    }
    
    self.showWaiting.hidden=YES;
}
-(void)GCRequest:(GCRequest *)aRequest Error:(NSString *)aError
{
    self.showWaiting.hidden=YES;
    [self showMsg:@"请求失败，请检查网路设置"];
}
/** 分享  */
-(void)tapShare
{
    [self callOutShareGoodS:self.goods];
}

/** 查看评论列表 */
-(void)gotoCommentList
{
    ZXYCommentListViewController * comment=[[ZXYCommentListViewController alloc]init];
    comment.productId=self.goods_id;
    [self.navigationController pushViewController:comment animated:YES];
}
/** 查看更多咨询 */
-(void)gotoPurchaseConsult
{
    ZXYPurchaseConsultViewController * purchase=[[ZXYPurchaseConsultViewController alloc]init];
    purchase.productId=self.goods_id;
    [self.navigationController pushViewController:purchase animated:YES];
}
/** 进入商品详情 大图的左滑 */
-(void)didScrollToINC
{
    LSYImageDetailsViewController * inc=[[LSYImageDetailsViewController alloc]init];
    inc.mallTitleLabel.text = @"图文详情";
    inc.goodsInfoDic=self.goodsInfoDic;
    inc.changShangInfoDic=self.changShangInfoDic;
    [self.navigationController pushViewController:inc animated:YES];
}
/** 提交订单 秒杀商品 */
- (void)gotoSekillGoodsInfo:(NSDictionary*)dict
{
    self.ms_sign= [dict objectForKey:@"ms_sign"];
    NSString * pay_time=[dict objectForKey:@"pay_time"];
    NSString * my_sign=[dict objectForKey:@"my_sign"];
    [self showMsg:[NSString stringWithFormat:@"抢购成功，请在%@分钟内付款",pay_time]];
    LSYConfirmOrderViewController * con=[[LSYConfirmOrderViewController alloc]init];
    con.isSeckilling=YES;
    con.my_sign=my_sign;
    con.goods=self.goods;
    con.ms_sign=self.ms_sign;
    [self.navigationController pushViewController:con animated:YES];

}
/** 轮播图进入大图展示 */
-(void)didTapImg:(NSArray *)array andIndex:(int)index andHost:(NSString *)host
{
    LSYBigImgShowView * bigImg=[[LSYBigImgShowView alloc]initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
    bigImg.host=host;
    bigImg.images=array;
    [self.view.window addSubview:bigImg];
    [bigImg selectPageImageViewWithPage:index];

}

#pragma mark - 下面三个按钮的点击事件
/**
 * 立即购买的点击事件
 */
- (IBAction)buyNow:(id)sender
{
    if ([kkUserId isEqual:@""] || !kkUserId) {
        //去登陆
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.viewControllerIndex = 4;
        [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
        [self.navigationController pushViewController:login animated:YES];
    }
    
    else {
        if (self.goods.nums == 0) {
            [self showMsg:@"库存不足"];
            return;
        }
        if (self.goods.attr_spec.count == 0) {
            
            /** 去往提交订单页的判断 */
            [self gotoConfitmOrderViewController];
            
        } else {
            if (_attributeModel.spec_idArray.count != 0) {
                
                /** 去往提交订单页的判断 */
                [self gotoConfitmOrderViewController];
                
            } else {
                CJAttributeSelectController *SVCBuyNow = [self makeAttributeController];
                SVCBuyNow.restriction = self.goods.restriction;
                SVCBuyNow.attributeSelect = AttributeSelectBuyNow;
                SVCBuyNow.isSeckilling = self.goods.isSeckilling;
                [self.navigationController pushViewController:SVCBuyNow animated:YES];
            }
        }
    }
}
/**
 * 去往提交订单页的判断
 */
- (void)gotoConfitmOrderViewController
{
        if (kkUserCenterId && ![kkUserCenterId isEqual:@""]) {
            if (self.goods.isSeckilling) {
                if ([self.bugWarring isEqualToString:@""]||self.bugWarring==nil) {
                    [self seckillingBuy];
                }else{
                    [self showMsg:self.bugWarring];
                }
            }else if(self.goods.restriction >0 &&self.goods.available ==0){
                
                [self showMsg:[NSString stringWithFormat:@"宝贝限购%d件，您已购买%d件",self.goods.restriction,self.goods.restriction -self.goods.available]];
                
            }else{
                if (self.alreadySubmit) {//提交订单
                    LSYConfirmOrderViewController * confirm=[[LSYConfirmOrderViewController alloc]init];
                    confirm.goods=self.goods;
                    confirm.attributeModel = _attributeModel;
                    confirm.attributeGoodsNums = _attributeGoodsNums;
                    [self.navigationController pushViewController:confirm animated:YES];
                }
            }
        }else{
            
            //调转登陆页面
            [MarketAPI jumLoginControllerWithNavPush:self.navigationController];
            //劳燕子
            
        }
}

/**
 * 下面购物车按钮的点击事件 （15.7.22 已改为收藏按钮）
 */
- (IBAction)shoppingCartBtnCliked:(id)sender {
    
    self.goodsinfoRightMoreView.hidden = YES;
    
    
    if ([kkUserId isEqual:@""] || !kkUserId) {
        //去登陆
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.viewControllerIndex = 4;
        [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
        [self.navigationController pushViewController:login animated:YES];
    }
    else {
        if (kkUserCenterId && ![kkUserCenterId isEqual:@""]) {
            if (self.isAlreadyCollection) {
                [self setCancleCollectionToSeverices];
            }else{
                [self setCollectionToSeverices];
            }
        }
//        else{
//            //调转登陆页面
//            [MarketAPI jumLoginControllerWithNavPush:self.navigationController];
//        }
    }
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushInfoViewController" object:nil userInfo:@{@"type":@"3"}];
}
/*
 111接口更新了   code：5 => '商品已下架'
 26=> '购买数量超过限购数量'
 103=> '商品售罄'
 104=> ‘购物车已满’
 13=> '库存不足'
 */

/**
 * 加入购物车的逻辑跳转判断
 */
- (IBAction)addShoppingCartBtnCliked:(id)sender {
    self.goodsinfoRightMoreView.hidden = YES;
    
    if ([kkUserId isEqual:@""] || !kkUserId) {
        //去登陆
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        login.viewControllerIndex = 4;
        [self.appDelegate.homeTabBarController hideTabBarAnimated:YES];
        [self.navigationController pushViewController:login animated:YES];
    }
    else {
    
        /**  9.18  添加    */
        if (self.goods.nums == 0) {
            [self showMsg:@"库存不足"];
            return;
        }
        
        if (self.goods.attr_spec.count == 0) {//判断商品是否有属性
            /** 添加购物车(直接) */
            [self addGotoShoppingCarWithGoodsAttributeNums:@"1" andGoodsAttributeArray:@[] goodsAttributeId:@""];

        } else {
            
            if (_attributeModel.spec_idArray.count != 0) {
                
                //用来存储最后确定的商品的所有属性信息  需要上传
                NSMutableArray *lastArr = [NSMutableArray array];
                for (CJAttributeSpecModel *lastSpecModel in _attributeModel.spec_idArray) {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:lastSpecModel.key,@"key",lastSpecModel.value,@"value", nil];
                    [lastArr addObject:dic];
                }
                
                /** 添加购物车(直接) */
                [self addGotoShoppingCarWithGoodsAttributeNums:_attributeGoodsNums andGoodsAttributeArray:lastArr goodsAttributeId:_attributeModel.ModeleId];
                
            } else {
                CJAttributeSelectController *SVCAdd = [self makeAttributeController];
                SVCAdd.attributeSelect = AttributeSelectAdd;
                
                //商品属性页 加入购物车的回调方法
                SVCAdd.restriction = self.goods.restriction;
                
                __weak CJAttributeBtnView *weakBtnView = _btnView;
                __weak CJShoppingButtonView *blockShopBtn = _shopBtnView;
                __weak LSYGoodsInfoViewController *weakSelf = self;
                SVCAdd.blockAttribute = ^(CJAttributeModle *attributeModel,NSString *numLabelText){
                    
                    _attributeModel = attributeModel;
                    _attributeGoodsNums = numLabelText;
                    
                    //刷新右侧购物车数量
                    [blockShopBtn getCardNumData];
                    
                    NSMutableString *str = [NSMutableString string];
                    for (CJAttributeSpecModel *specModel in attributeModel.spec_idArray) {
                        [str appendFormat:@"%@ ",specModel.value];
                    }
                    weakBtnView.attributeLabel.text = str;
                    weakBtnView.selectLabel.text = @"已选";
                    [weakSelf setAttributeModel:attributeModel goodsNums:numLabelText];
                };
                
                [self.navigationController pushViewController:SVCAdd animated:YES];
            }
        }
    }
}
/**
 * 添加购物车(直接)
 */
- (void)addGotoShoppingCarWithGoodsAttributeNums:(NSString *)goodsNums andGoodsAttributeArray:(NSArray *)goodsAttributeArray goodsAttributeId:(NSString *)goodsAttributeId
{
    //添加购物车
    NSLog(@"%@",self.goods.goods_id);
    [CrazyShoppingAddorRemoveModel crazyShoppingAddorRemoveModelType:CrazyShoppingAddorRemoveModelTypeAdd loadController:nil goodsId:self.goods.goods_id goodsAttributeArray:goodsAttributeArray goodsAttributeId:goodsAttributeId goodsAttributeNums:goodsNums isupdate:self.isupdate  completeBlock:^(NSDictionary *infoDic) {
        NSLog(@"infoDic=%@",infoDic);
        
        if(!infoDic){
            [self showMsg:@"商品已失效"];
            return ;
        }
        if ([infoDic[@"code"] integerValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CrazyShoppingCartViewControllerReloadData" object:nil];
            [self showMsg:@"添加购物车成功"];
            //刷新右侧购物车数量
            [_shopBtnView getCardNumData];
            
            self.goods.goodCardNum    =[NSString stringWithFormat:@"%d",[self.goods.goodCardNum intValue] + 1];
            if([self.goods.goodCardNum integerValue] > 0){
                if([self.goods.goodCardNum integerValue]>99){
                    _badgeView.badgeText =  @"99+";
                }else{
                    _badgeView.badgeText =  self.goods.goodCardNum;
                }
            }
        }//5、商品已下架；13、库存不足
        else if ([infoDic[@"code"] integerValue] == 103 ||[infoDic[@"code"] integerValue] == 5) {
            [self showMsg:@"商品已失效"];
        }
        else if ([infoDic[@"code"] integerValue] == 26)
        {
            [self showMsg:@"超出限购啦亲"];
            
        }else if ([infoDic[@"code"] integerValue] == 104)
        {
            [self showMsg:@"购物车满了\n先去结算一些吧"];
        }else
        {
            [self showMsg:infoDic[@"message"]];
        }
        
    }];
}

/**
 * 去逛逛
 */
- (IBAction)quGuangGuang:(id)sender
{
    NSArray  * viewControls= self.navigationController.viewControllers;
    for (UIViewController * viewControl  in viewControls){
        if([viewControls isKindOfClass:[LSYHomePageViewController class]]){
            
            [self.navigationController popToViewController:viewControl animated:YES];
            return;
        }
    }
//    LSYHomePageViewController  * homeContrl = [[LSYHomePageViewController alloc]initWithNibName:@"LSYHomePageViewController" bundle:nil];
//    [self.navigationController pushViewController:homeContrl animated:YES];
    GAHomeTabBarController *tabbar = [GAHomeTabBarController sharedHomeTabBarController];
    [tabbar selectTabBarAtIndex:2];
    [tabbar.homeTabBar selectTabBarAtIndex:2];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



@end
