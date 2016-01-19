//
//  DetailViewController.h
//  TheZoo
//
//  Created by 李祐昇 on 2016/1/19.
//  Copyright © 2016年 NilsonLee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

