//
//  DetailViewController.m
//  TheZoo
//
//  Created by 李祐昇 on 2016/1/19.
//  Copyright © 2016年 NilsonLee. All rights reserved.
//

#import "DetailViewController.h"
#define FONT_NAME @"Helvetica"
#define FONT_SIZE 10
@interface DetailViewController ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>


@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        NSDictionary *animalDic = (NSDictionary *)self.detailItem;
        NSString *animalTitleStr = [animalDic objectForKey:@"A_Name_Ch"];
        NSString *animalDesStr = [animalDic objectForKey:@"A_Distribution"];
        
        [self.animalTitleNaviItem setTitle:animalTitleStr];
        [self adjustLabelSize:self.detailDescriptionLabel str:animalDesStr fontName:FONT_NAME size:FONT_SIZE];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //動物圖片網址
    NSURL * url = [NSURL URLWithString:[self.detailItem objectForKey:@"A_Pic01_URL"]];
    //如果有圖片網址，向伺服器請求圖片資料
    if (url) {
        //建立一般的session設定
        NSURLSessionConfiguration * sessionWithConfigure = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        //設定session和delegate
        NSURLSession * session = [NSURLSession sessionWithConfiguration:sessionWithConfigure delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        //設定下載網址
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        NSURLSessionDownloadTask * task = [session downloadTaskWithRequest:request];
        
        //啟動或重新啟動下載動作
        [task resume];
    }

    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {

    NSData *imageDate = [NSData dataWithContentsOfURL:location];
    if (imageDate) {
        self.animalImagView.image = [UIImage imageWithData:imageDate];
    }
}

#pragma methods
//根據內容自動調整UILabel大小
- (void) adjustLabelSize:(UILabel *)label str:(NSString*)theStr fontName:(NSString *)fontStr size:(CGFloat)fontSize {
    // 位置與大小,因為這邊用的是拉好的label所以這段不用加
    //UILabel *myLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
    // 文字字型及大小
    [label setFont:[UIFont fontWithName:fontStr size:fontSize]];
    // 行數 只有設定為0才能自適應尺寸
    [label setNumberOfLines:0];
    
    // 字型及大小 必須跟UILabel的一樣
    UIFont *font = [UIFont fontWithName:fontStr size:fontSize];
    
    // 獲得文字內容的尺寸,這行在iOS6 開始不建議使用,建議改用新方法
    CGSize size = [theStr sizeWithFont:font constrainedToSize:CGSizeMake(150, 2000) lineBreakMode:NSLineBreakByWordWrapping];
    
    // 設定Label的內容跟尺寸
    CGRect rect = label.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    label.frame = rect;
    label.text = theStr;
}
@end
