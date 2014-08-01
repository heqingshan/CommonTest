//
//  HQSIAPHandler.h
//  CommonTest
//
//  Created by HeQingshan on 14-7-30.
//  Copyright (c) 2014年 何青山. All rights reserved.
//


#define IAPDidReceivedProducts                      @"IAPDidReceivedProducts"
#define IAPDidFailedTransaction                     @"IAPDidFailedTransaction"
#define IAPDidRestoreTransaction                    @"IAPDidRestoreTransaction"
#define IAPDidCompleteTransaction                   @"IAPDidCompleteTransaction"
#define IAPDidCompleteTransactionAndVerifySucceed   @"IAPDidCompleteTransactionAndVerifySucceed"
#define IAPDidCompleteTransactionAndVerifyFailed    @"IAPDidCompleteTransactionAndVerifyFailed"

#import <Foundation/Foundation.h>
#import "ECPurchase.h"

@interface HQSIAPHandler : NSObject<ECPurchaseTransactionDelegate, ECPurchaseProductDelegate>

+ (void)initECPurchaseWithHandler;

@end
