//
//  HQSIAPViewController.m
//  CommonTest
//
//  Created by HeQingshan on 14-8-3.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import "HQSIAPViewController.h"

@interface HQSIAPViewController ()

@end

@implementation HQSIAPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"In-App-Purchase测试";
    
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

- (void)buy:(UIButton*)sender
{
    SKProduct *product = [products_ objectAtIndex:sender.tag];
    NSLog(@"购买商品：%@", product.productIdentifier);
    [[ECPurchase shared] addPaymentWithProduct:product];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -
#pragma ECPurchaseProductDelegate & ECPurchaseTransactionDelegate

-(void)didReceivedProducts:(NSArray *)products
{
    if (products_) {
        products_ = nil;
    }
    products_ = products;
    [self.tableView reloadData];
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

-(void)showAlertWithMsg:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"IAP反馈"
                                                   message:message
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
