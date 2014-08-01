//
//  HQSViewController.m
//  CommonTest
//
//  Created by HeQingshan on 14-7-30.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import "HQSViewController.h"
#import "HQSIAPHandler.h"

@interface HQSViewController ()<ECPurchaseProductDelegate,ECPurchaseTransactionDelegate> {
    ECPurchase *purchase;
}

@end

@implementation HQSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableView];
    self.title = @"IAP Demo";
    
    purchase = [ECPurchase shared];
    purchase.productDelegate = self;
    purchase.transactionDelegate = self;
    
    //iap产品编号集合，这里你需要替换为你自己的iap列表
    NSArray *productIds = [NSArray arrayWithObjects:
                           @"com.intime.CommonTest.001",
                           @"com.intime.CommonTest.002",
                           @"com.intime.CommonTest.003",
                           @"com.intime.CommonTest.004",nil];
    //从AppStore上获取产品信息。首先判断是否支持程序内付费
    if ([SKPaymentQueue canMakePayments]) {
        [purchase requestProductData:productIds];
        NSLog(@"允许程序内付费购买");
    }
    else {
        NSLog(@"不允许程序内付费购买");
        UIAlertView *alerView =  [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"You can‘t purchase in app store（HQS 说你没允许应用程序内购买）"
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Close（关闭）",nil)
                                                  otherButtonTitles:nil];
        
        [alerView show];
    }
}

- (void)initTableView {
    myTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)buy:(UIButton*)sender
{
    SKProduct *product = [products_ objectAtIndex:sender.tag];
    NSLog(@"购买商品：%@", product.productIdentifier);
    [[ECPurchase shared] addPaymentWithProduct:product];
}

#pragma -
#pragma ECPurchaseProductDelegate & ECPurchaseTransactionDelegate

-(void)didReceivedProducts:(NSArray *)products
{
    if (products_) {
        products_ = nil;
    }
    products_ = products;
    [myTableView reloadData];
}

-(void)didFailedTransaction:(NSString *)proIdentifier
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易取消(%@)",proIdentifier]];
}

-(void)didRestoreTransaction:(NSString *)proIdentifier
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易恢复(%@)",proIdentifier]];
}

-(void)didCompleteTransaction:(NSString *)proIdentifier
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易完成(%@)",proIdentifier]];
}
-(void)didCompleteTransactionAndVerifySucceed:(NSString *)proIdentifier
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易验证成功(%@)",proIdentifier]];
}
-(void)didCompleteTransactionAndVerifyFailed:(NSString *)proIdentifier withError:(NSString *)error
{
    [self showAlertWithMsg:[NSString stringWithFormat:@"交易验证失败(%@)",proIdentifier]];
}

#pragma -
#pragma UITableViewDataSource & UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return products_ ? [products_ count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
    else {
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
    }
    SKProduct *product = [products_ objectAtIndex:indexPath.row];
    //产品名称
    UILabel *localizedTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 130, 20)];
    localizedTitle.text = product.localizedTitle;
    localizedTitle.font = [UIFont systemFontOfSize:10];
    //产品价格
    UILabel *localizedPrice = [[UILabel alloc]initWithFrame:CGRectMake(150, 10, 100, 20)];
    localizedPrice.text = product.localizedPrice;
    localizedPrice.font = [UIFont systemFontOfSize:10];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@", product.localizedTitle, product.localizedPrice];
    cell.detailTextLabel.text = product.localizedDescription;
    
    //购买按钮
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buyButton.tag = indexPath.row;
    buyButton.frame = CGRectMake(250, 10, 60, 25);
    [buyButton setBackgroundColor:[UIColor greenColor]];
    [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
    [buyButton addTarget:self action:@selector(buy:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:buyButton];
    
//    [cell.contentView addSubview:localizedTitle];
//    [cell.contentView addSubview:localizedPrice];
//    [cell.contentView addSubview:buyButton];
    return cell;
}

-(void)showAlertWithMsg:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"IAP反馈"
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

@end
