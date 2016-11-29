//
//  ViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "MainViewController.h"
#import "ListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * testBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [testBtn setTitle:@"push" forState:UIControlStateNormal];
    [testBtn addTarget:self action:@selector(push) forControlEvents:UIControlEventTouchUpInside];
    testBtn.frame = CGRectMake(200, 400, 100, 44);
    [self.view addSubview:testBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action methods

- (void)push {
    ListViewController * controller = [[ListViewController alloc] init];
    [self presentViewController:controller animated:YES completion:NULL];
}

@end
