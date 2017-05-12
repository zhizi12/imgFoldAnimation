//
//  ViewController.m
//  ImgFoldAnimation
//
//  Created by jinglan on 2016/11/1.
//  Copyright © 2016年 zhang. All rights reserved.
//

#import "ViewController.h"
#import "BigImgView.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    BigImgView *imgView = [[BigImgView alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 300)];
   // imgView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:imgView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
