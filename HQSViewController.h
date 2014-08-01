//
//  HQSViewController.h
//  CommonTest
//
//  Created by HeQingshan on 14-7-30.
//  Copyright (c) 2014年 何青山. All rights reserved.
//
/*
 1. 内置产品类型
 
 1. 程序通过bundle存储的plist文件得到产品标识符的列表。
 2. 程序向App Store发送请求，得到产品的信息。
 3. App Store返回产品信息。
 4. 程序把返回的产品信息显示给用户（App的store界面）
 5. 用户选择某个产品
 6. 程序向App Store发送支付请求
 7. App Store处理支付请求并返回交易完成信息。
 8. App获取信息并提供内容给用户。
 
 2. 服务器类型
 
 1. 程序向服务器发送请求，获得一份产品列表。
 2. 服务器返回包含产品标识符的列表。
 3. 程序向App Store发送请求，得到产品的信息。
 4. App Store返回产品信息。
 5. 程序把返回的产品信息显示给用户（App的store界面）
 6. 用户选择某个产品
 7. 程序向App Store发送支付请求
 8. App Store处理支付请求并返回交易完成信息。
 9. 程序从信息中获得数据，并发送至服务器。
 10. 服务器纪录数据，并进行审(我们的)查。
 11. 服务器将数据发给App Store来验证该交易的有效性。
 12. App Store对收到的数据进行解析，返回该数据和说明其是否有效的标识。
 13. 服务器读取返回的数据，确定用户购买的内容。
 14. 服务器将购买的内容传递给程序。
 */

#import <UIKit/UIKit.h>

@interface HQSViewController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    NSArray *products_;
    UITableView *myTableView;
}

@end
