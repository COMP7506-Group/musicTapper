//
//  ListViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "ListViewController.h"
#import "PlayViewController.h"
#import "TestViewController.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self prefersStatusBarHidden];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 10) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        
        TestViewController * controller = [[TestViewController alloc] init];
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else {
        PlayViewController * controller = [[PlayViewController alloc] init];
        [self presentViewController:controller animated:YES completion:NULL];
    }
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"This is the %ldth song", (long)indexPath.row + 1];
    
    return cell;
}

@end
