//
//  ShareViewController.h
//  iCloud App
//
//  Created by iRare Media on 11/24/13.
//  Copyright (c) 2014 iRare Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *link;
@property (strong, nonatomic) IBOutlet UILabel *date;

@property (strong, nonatomic) NSString *linkText;
@property (strong, nonatomic) NSString *dateText;

- (IBAction)shareLink;
- (IBAction)done;

@end
