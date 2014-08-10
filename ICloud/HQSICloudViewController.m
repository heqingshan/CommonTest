//
//  HQSICloudViewController.m
//  CommonTest
//
//  Created by HeQingshan on 14-8-3.
//  Copyright (c) 2014年 何青山. All rights reserved.
//

#import "HQSICloudViewController.h"

@interface HQSICloudViewController ()

@end

@implementation HQSICloudViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"iCloud测试";
    
    // 文件名
    NSString *fileName = @"data.txt";
    
    // 得到文件管理器
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 验证iCloud是否激活
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];//4T8S383NVQ.com.intime.CommonTest
    if (url == nil)
    {
        NSLog(@"iCloud未激活");
        return;
    }
    
    // 指定iCloud完整路径
    icloudURL = [NSURL URLWithString:fileName relativeToURL:url];
    
    // 得到本程序沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.contentField becomeFirstResponder];
}

- (void)initControl {
    self.contentField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.contentField.layer.borderWidth = 2.0;
    
    self.saveButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.saveButton.layer.borderWidth = 2.0;
    self.saveButton.layer.cornerRadius = 4.0;
    
    self.downloadButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.downloadButton.layer.borderWidth = 2.0;
    self.downloadButton.layer.cornerRadius = 4.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadICloud {
    // 调用主进程的方法更新界面,在主进程外更新界面常会引起错误
    [self performSelectorOnMainThread:@selector(setString:)
                           withObject:@"开始上传"
                        waitUntilDone:NO];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *data = [[NSArray alloc] initWithObjects:self.contentField.text, nil];
    
    // 判断本地文件是否存在
    if (![manager fileExistsAtPath:filePath]) {
        // 不存在则创建
        if (![data writeToFile:filePath atomically:YES])
        {
            [self performSelectorOnMainThread:@selector(setString:)
                                   withObject:@"写本地文件失败"
                                waitUntilDone:NO];
        }
    }
    
    // 判断iCloud里该文件是否存在
    if ([manager isUbiquitousItemAtURL:icloudURL]) {
        // 存在则修改
        if (![data writeToURL:icloudURL atomically:YES])
        {
            [self performSelectorOnMainThread:@selector(setString:)
                                   withObject:@"写iCloud文件失败"
                                waitUntilDone:NO];
        }
        [self performSelectorOnMainThread:@selector(setString:)
                               withObject:@"上传成功"
                            waitUntilDone:NO];
        return;
    }
    
    // 上传至iCloud
    // 指定本地文件完整路径
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    // 官方文档建议本方法不要在主进程里执行
    if (![manager setUbiquitous:YES itemAtURL:url destinationURL:icloudURL error:&error])
    {
        NSLog(@"setUbiquitous error %@,\n%@", error, [error userInfo]);
        self.resultLabel.text = @"上传失败";
        return;
    }
    self.resultLabel.text = @"上传成功";
}

- (IBAction)saveAndUploadContentToICloud:(id)sender {
    // 另起一个线程上传
    [NSThread detachNewThreadSelector:@selector(uploadICloud) toTarget:self withObject:nil];
}

- (IBAction)downloadContentFromICloud:(id)sender {
    self.resultLabel.text = @"开始下载";
    
    // 下载icloud文件
    if (![self downloadFileIfNotAvailable:icloudURL])
    {
        self.resultLabel.text = @"下载失败";
        return;
    }
    // 更新界面
    NSArray *array = [[NSArray alloc] initWithContentsOfURL:icloudURL];
    self.contentField.text = [array objectAtIndex:0];
    
    self.resultLabel.text = @"下载成功";
}

// 此方法是官方文档提供,用来检查文件状态并下载
- (BOOL)downloadFileIfNotAvailable:(NSURL*)file {
    NSNumber*  isIniCloud = nil;
    
    if ([file getResourceValue:&isIniCloud forKey:NSURLIsUbiquitousItemKey error:nil]) {
        // If the item is in iCloud, see if it is downloaded.
        if ([isIniCloud boolValue]) {
            NSNumber*  isDownloaded = nil;
            if ([file getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemDownloadingStatusKey error:nil]) {
                if ([isDownloaded boolValue])
                    return YES;
                
                // Download the file.
                NSFileManager*  fm = [NSFileManager defaultManager];
                if (![fm startDownloadingUbiquitousItemAtURL:file error:nil]) {
                    return NO;
                }
                return YES;
            }
        }
    }
    
    // Return YES as long as an explicit download was not started.
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.contentField resignFirstResponder];
}

- (void)setString:(NSString *)string
{
    self.resultLabel.text = string;
}

@end
