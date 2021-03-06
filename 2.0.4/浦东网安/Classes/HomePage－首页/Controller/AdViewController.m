//
//  AdViewController.m
//  浦东网安
//
//  Created by jiji on 15/6/16.
//  Copyright (c) 2015年 PengYue. All rights reserved.
//

#import "AdViewController.h"
#import "UIView+Extension.h"
#import "MJRefresh.h"
#import "MJExtension.h"
#import "News.h"
#import "NewsDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "NewsTableViewCell.h"
//
#import "UserInfo.h"
#import "UserInfoTool.h"
@interface AdViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)NSMutableArray *news;
@end

@implementation AdViewController
-(NSMutableArray *)news
{
    if (!_news) {
        self.news = [NSMutableArray array];
    }
    return _news;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    UserInfo *user = [UserInfoTool info];
    if (!user) {
        UIImageView *titleText = [[UIImageView alloc] initWithFrame: CGRectMake(135, 7, 105, 31)];
        titleText.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hometitle22"]];
        self.navigationItem.titleView=titleText;
    }else{
        self.title = @"公益广告";
    }
    [self setupDownRefresh];
    [self setupUpRefresh];
    self.view.tag =1;
   
}

-(void)setupUpRefresh
{
 //  self.tableView.footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    
    // 设置文字
    [footer setTitle:@"点击或上拉加载更多..." forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载中 ..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
        // 设置footer
    self.tableView.footer = footer;
    
    
}

-(void)loadMore
{
    NSMutableDictionary *params= [NSMutableDictionary dictionary];
    News *lastNews = [self.news lastObject];
    if (lastNews) {
        params[@"newID"] = lastNews.ID;
    }
    params[@"newType"] = @"公益广告";
    [[HttpRequestManager sharedManager]POST:[NSString stringWithFormat:@"%@/%@",CZHURL,@"/GetTopNews"] params:params success:^(NSData *data) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray *moreNews = [News objectArrayWithKeyValuesArray:dic[@"result"]];
        [self.news addObjectsFromArray:moreNews];
        [self.tableView reloadData];
        
        [self.tableView.footer endRefreshing];
    } failed:^{
        [self.tableView.footer endRefreshing];
         [MBProgressHUD showError:@"网络错误!"];
    }];
}

-(void)setupDownRefresh
{
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewNews)];
    
    //    [self.tableView addHeaderWithTarget:self action:@selector(loadNewNews)];
    
    // 2.进入刷新状态
    [self.tableView.header beginRefreshing];
}

-(void)loadNewNews
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"newType"] = @"公益广告";
    params[@"newID"] = @"";
    [[HttpRequestManager sharedManager]POST:[NSString stringWithFormat:@"%@/%@",CZHURL,@"/GetTopNews" ] params:params success:^(NSData *data) {
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        self.news = (NSMutableArray *)[News objectArrayWithKeyValuesArray:dic[@"result"]];
        [self.tableView reloadData];
        [self.tableView.header endRefreshing];
    } failed:^{
        [self.tableView.header endRefreshing];
        [MBProgressHUD showError:@"网络错误!"];
    }];
    
}




#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    self.tableView.footer.hidden = (self.news.count < 10);
    return self.news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"NewsTableViewCell" owner:nil options:nil]lastObject];
    }
    News *news = self.news[indexPath.row];
    
    cell.newsTitle.text = news.Title;
    [cell.newsImageView sd_setImageWithURL:[NSURL URLWithString:news.News_Url] placeholderImage:[UIImage imageNamed:@"ic_launcher"]];
    cell.newsImageView.layer.masksToBounds = YES;
    cell.newsImageView.layer.cornerRadius = 5.0;
    
    NSString *str = [news.UpdateTme substringWithRange:NSMakeRange(0, 10)];
    double lastactivityInterval = [str doubleValue];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:lastactivityInterval];
    
    
    NSString* dateString = [formatter stringFromDate:date];
    
    cell.timeLable.text = dateString;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailViewController *detail = [[NewsDetailViewController alloc]init];
    News *xinWen = self.news[indexPath.row];
    detail.news = xinWen;
    detail.view.tag = self.view.tag;
    [self.navigationController pushViewController:detail animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
@end
