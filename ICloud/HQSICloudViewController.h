//
//  HQSICloudViewController.h
//  CommonTest
//
//  Created by HeQingshan on 14-8-3.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HQSICloudViewController : UIViewController {
    NSURL *icloudURL;
    NSString *filePath;
}

@property (weak, nonatomic) IBOutlet UITextView *contentField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)saveAndUploadContentToICloud:(id)sender;
- (IBAction)downloadContentFromICloud:(id)sender;


@end
