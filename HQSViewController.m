//
//  HQSViewController.m
//  CommonTest
//
//  Created by HeQingshan on 14-7-30.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import "HQSViewController.h"
#import "HQSIAPViewController.h"
#import "HQSICloudViewController.h"
#import "WelcomeViewController.h"

@implementation HQSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Common Test Demo";
    
    [self initArray];
}

- (void)initArray {
    if (!products_) {
        products_ = [[NSMutableArray alloc] init];
    }
    [products_ addObject:@"In-App-Purchase 测试"];
    [products_ addObject:@"iCloud 测试"];
    [products_ addObject:@"iCloudTest 测试"];
}

#pragma -
#pragma UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return products_ ? [products_ count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = products_[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            HQSIAPViewController *vc = [[HQSIAPViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            HQSICloudViewController *vc = [[HQSICloudViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            WelcomeViewController *vc = [[WelcomeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"iPhoneStoryboard" bundle:nil];
            [self presentViewController:[storyboard instantiateInitialViewController] animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
