//
//  HQSIAPViewController.h
//  CommonTest
//
//  Created by HeQingshan on 14-8-3.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECPurchase.h"

@interface HQSIAPViewController : UITableViewController<ECPurchaseProductDelegate,ECPurchaseTransactionDelegate> {
    NSArray *products_;
    ECPurchase *purchase;
}

@end
