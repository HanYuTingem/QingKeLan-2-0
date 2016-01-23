//
//  CJTopUpRecordViewController.m
//  Wallet
//
//  Created by zhaochunjing on 15-10-22.
//  Copyright (c) 2015年 Sinoglobal. All rights reserved.
//

#import "CJTopUpRecordViewController.h"
#import "CJTopUpRecordTableViewCell.h"
#import "WalletHome.h"
#import "WalletRequsetHttp.h"
#import "MJRefresh.h"
#import "CJTopUpModel.h"
#import "CJTopUpDetailsViewController.h"
#import "CJCashDetailsViewController.h"

#define cellH 42
@interface CJTopUpRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //上提加载
    MJRefreshFooterView        *_footer;
    //上提加载
    MJRefreshHeaderView        *_header;
}
/** 全局的tableView */
@property (nonatomic, strong) UITableView *tableView;
/** 数据源数组 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/** cell的标识符 */
@property (nonatomic, copy) NSString *cellID;
/** 页数 */
@property (nonatomic, assign) int page;
/** 每页请求的数量 */
@property (nonatomic, assign) int count;
/** 总页数 */
@property (nonatomic, copy) NSString *totalCount;
/** 没有数据的文字 */
@property (nonatomic, strong) UILabel *noRecordLabel;
/** 没有数据的页面View */
@property (nonatomic, strong) UIView *noRecordView;

@end

@implementation CJTopUpRecordViewController

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.page = 1;
    self.count = 20;
    // 初始化界面
    [self makeInitView];
    [self makeTableVeiw];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setRequestData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self chrysanthemumClosed];
}

/** 得到网络请求数据 */
- (void)setRequestData
{
    [self chrysanthemumOpen];
    NSDictionary *dict = [WalletRequsetHttp WalletPersonRechargeGetCashRecordSuccessFailure1108WithType:self.recordType page:self.page count:self.count];
    
    NSString *urlStr;
    if ([self.recordType intValue] == 1) {
        urlStr = WalletHttp_Record1108;
    } else {
        urlStr = WalletHttp_Record1108getChargeLog;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",urlStr,[dict JSONFragment]];
    
    [SINOAFNetWorking postWithBaseURL:url controller:self success:^(id json) {
        self.noRecordView.hidden = YES;
        [self endRefresh];
        
        if (self.page == 1) {
            [self.dataArray removeAllObjects];
        }
        
        NSDictionary *dicData = json;
        if ([dicData[@"code"] intValue] == 101) {
            [self showMsg:ShowNoMessage];
            return ;
        }
        self.totalCount = dicData[@"num"];
        
        NSLog(@"json == %@",json);
        for (NSDictionary *dic in dicData[@"rs"]) {
            if (![[NSString stringWithFormat:@"%@",dic[@"amountType"]] isEqualToString:@"<null>"]) {
                //                if ([self.recordType intValue] == [dic[@"amountType"] intValue]) {
                if ([dic[@"status"] intValue] != 4) {//提现记录里面不显示手续费
                    CJTopUpModel *model = [[CJTopUpModel alloc] init];
                    [model setValuesForKeysWithDictionary:dic];
                    [self.dataArray addObject:model];
                }
            }
        }
        //        NSArray *array = dicData[@"rs"];
        if (!self.dataArray.count) {
            //            [self showMsg:ShowNoMessage];
            self.noRecordView.hidden = NO;
        }
        
        //        [self setTableFrame];
        [_tableView reloadData];
        [self chrysanthemumClosed];
        
    } failure:^(NSError *error) {
        [self showMsg:ShowMessage];
        [self endRefresh];
        [self chrysanthemumClosed];
        
    } noNet:^{
        [self endRefresh];
        self.noRecordView.hidden = NO;
        [self chrysanthemumClosed];
    }];
    
}
/** 结束刷新 */
- (void)endRefresh
{
    [_footer endRefreshing];
    [_header endRefreshing];
    //    [_tableView.header endRefreshing];
    //    [_tableView.footer endRefreshing];
}

/** 初始化界面 */
- (void)makeInitView
{
    CGFloat W = 89;
    CGFloat IW = 30;
    CGFloat LW = W + IW * 2;
    UIView *view = [[UIView alloc] init];
    view.bounds = CGRectMake(0, 0, LW, 119);
    view.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5 - W);
    view.hidden = YES;
    [self.view addSubview:view];
    self.noRecordView = view;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(IW, 0, W, W)];
    iv.image = [UIImage imageNamed:@"iconfont-tixian2"];
    [view addSubview:iv];
    
    
    UILabel *noRecordLabel = [[UILabel alloc] init];
    noRecordLabel.frame = CGRectMake(0, W, LW, IW);
    noRecordLabel.textAlignment = NSTextAlignmentCenter;
    noRecordLabel.textColor = [UIColor colorWithRed:0.49f green:0.49f blue:0.49f alpha:1.00f];
    noRecordLabel.font = [UIFont systemFontOfSize:14];
    //    noRecordLabel.hidden = YES;
    noRecordLabel.text = @"还没有充值记录哦~";
    [view addSubview:noRecordLabel];
    self.noRecordLabel = noRecordLabel;
    
    //    self.backView.backgroundColor = WalletHomeNAVGRD;
    self.mallTitleLabel.text = @"充值记录";
    if ([self.recordType isEqualToString:@"1"]) {
        self.mallTitleLabel.text = @"提现记录";
        noRecordLabel.text = @"还没有提现记录哦~";
    }
    //    self.mallTitleLabel.textColor = WalletHomeNAVTitleColor;
    //    self.mallTitleLabel.font = WalletHomeNAVTitleFont;
    //    [self.leftBackButton setImage:[UIImage imageNamed:@"title_btn_back"] forState:UIControlStateNormal];
    self.view.backgroundColor = WalletHomeBackGRD;
    
}
/** 设置tableview的frame */
- (void)setTableFrame
{
    NSUInteger numCell = self.dataArray.count;
    if (cellH * numCell < ScreenHeight - 65) {
        CGRect frame = _tableView.frame;
        frame.size.height = cellH * numCell;
        _tableView.frame = frame;
    } else {
        _tableView.scrollEnabled = YES;
        CGRect frame = _tableView.frame;
        frame.size.height = ScreenHeight - 65;
        _tableView.frame = frame;
    }
}

/** cell的标识符 */
static NSString *cellID = @"recordCell";
/** 创建tableView */
- (void)makeTableVeiw
{
    /** cell的个数 */
    //    NSUInteger numCell = 100;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, ScreenWidth, ScreenHeight - 65)];
    if ([self.recordType isEqualToString:@"1"]) {
//        _tableView.allowsSelection = NO;
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:1.00f];
    [self.view addSubview:_tableView];
    //    _tableView.footer.automaticallyHidden = NO;
    
    [self.tableView addSubview:self.noRecordView];
    
    
    [self addFooter];
    [self addHeader];
    
    
    //添加下拉刷新
    //    _tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
    //        _tableView.footer.hidden = NO;
    //        self.page = 1;
    //        [_tableView.header beginRefreshing];
    //
    //        [self setRequestData];
    //    }];
    //    _tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    //
    //        self.page++;
    //        if ([self.totalCount intValue] >= self.page) {
    //            [_tableView.footer beginRefreshing];
    //            [self setRequestData];
    //        } else {
    //            [_tableView.footer endRefreshing];
    //            _tableView.footer.hidden = YES;
    //            [self showMsg:showMessageNOData];
    //        }
    //    }];
}

-(void)addFooter{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        //  后台执行：
        //        [self requestFresh];
        
        self.page++;
        if ([self.totalCount intValue] >= self.page) {
            [self setRequestData];
        } else {
            [self endRefresh];
            [self showMsg:showMessageNOData];
        }
        
    };
    _footer = footer;
}
-(void)addHeader{
    MJRefreshHeaderView  * header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^ (MJRefreshBaseView * refreshView){
        //  后台执行：
        self.page = 1;
        [self setRequestData];
        
        
    };
    _header = header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellH;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
    //    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView registerNib:[UINib nibWithNibName:@"CJTopUpRecordTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    CJTopUpRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.recordType = self.recordType;
    cell.topUpModel = (CJTopUpModel *)self.dataArray[indexPath.row];
    return cell;
}

-  (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.recordType isEqualToString:@"0"]) {
        CJTopUpDetailsViewController *DVC = [[CJTopUpDetailsViewController alloc] init];
        DVC.topUpDetailsModel = self.dataArray[indexPath.row];
        DVC.comeHereStr = @"充值记录";
        [self.navigationController pushViewController:DVC animated:YES];
    } else if ([self.recordType isEqualToString:@"1"]) {
        CJCashDetailsViewController *CDVC = [[CJCashDetailsViewController alloc] init];
        CDVC.cashTopUpModel = self.dataArray[indexPath.row];
        CDVC.txTemplate3 = self.txTemplate3;
        [self.navigationController pushViewController:CDVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void)dealloc {
    [self chrysanthemumClosed];
}

@end
