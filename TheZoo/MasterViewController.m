//
//  MasterViewController.m
//  TheZoo
//
//  Created by 李祐昇 on 2016/1/19.
//  Copyright © 2016年 NilsonLee. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#define OPENDATA_URL @"http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=a3e2b221-75e0-45c1-8f97-75acbd43d613"

@interface MasterViewController ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property NSMutableArray *objects;
@property NSMutableArray *dataArray; //儲存動物資料
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    
    //台北市立動物園公開資料網址
    NSURL * url = [NSURL URLWithString:OPENDATA_URL];
    
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

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
*/
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        //取得被選取到的這一隻動物的資料
        NSDate *object = self.dataArray[indexPath.row];
        //設定在第二個畫面控制器中的資料為這一隻動物的資料
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if (_dataArray) {
        NSDictionary *nameDic = self.dataArray[indexPath.row];
        
        //顯示動物的中文名稱於Table View中
        //NSString *nameString = nameDic[@"A_Name_Ch"];
        NSString *nameString = [nameDic objectForKey:@"A_Name_Ch"];
        cell.textLabel.text = nameString;
    }
    
    
    return cell;
}
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/
#pragma NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    //JSON資料處理
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location] options:NSJSONReadingMutableContainers error:nil];
    //NSLog(@"JSON:%@", dataDic);
    NSDictionary *resultDic = [dataDic objectForKey:@"result"];
    //NSLog(@"JSON-Result:%@", resultDic);
    NSDictionary *resultsDic = [resultDic objectForKey:@"results"];
    //NSLog(@"JSON-Results:%@", resultsDic);
    
    //依據先前觀察的結構，取得result對應中的results所對應的陣列
    if (_dataArray) {
        
        for (NSDictionary *animalDic in resultsDic) {
            //NSLog(@"There are %@  in results", animalDic);
            [self.dataArray addObject:animalDic];
        }
        //self.dataArray = dataDic[@"result"][@"results"];
        //self.dataArray = resultsDic;
    }
 
    //重新整理Table View
    [self.tableView reloadData];
    
}

@end
