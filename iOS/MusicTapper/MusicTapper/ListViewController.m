//
//  ListViewController.m
//  MusicTapper
//
//  Created by Shou Tianxue on 28/11/2016.
//  Copyright © 2016 Shou Tianxue. All rights reserved.
//

#import "ListViewController.h"
#import "PlayViewController.h"
#import "Const.h"

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation ListViewController

- (void)dealloc {
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TypePlayMode mode;
    switch (indexPath.row) {
        case 0:
            mode = TypePlayModeEasy;
            break;
        case 1:
            mode = TypePlayModeHard;
            break;
        case 2:
            mode = TypePlayModeTest;
            break;
        case 3:
            mode = TypePlayModeAuto;
            break;
            
        default:
            mode = TypePlayModeEasy;
            break;
    }
    
    PlayViewController * controller = [[PlayViewController alloc] initWithPlayMod:mode songID:@"001"];
    [self presentViewController:controller animated:YES completion:NULL];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSNumber * offset = [defaults objectForKey:KEY_OFFSET];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Easy mode";
            break;
        case 1:
            cell.textLabel.text = @"Hard mode";
            break;
        case 2:
            if (offset) {
                cell.textLabel.text = [NSString stringWithFormat:@"Test mode (offset = %3f)", [offset doubleValue]];
            }
            else {
                cell.textLabel.text = @"Test mode (offset = 0)";
            }
            break;
        case 3:
            cell.textLabel.text = @"Auto mode";
            break;
            
        default:
            cell.textLabel.text = @"Easy mode";
            break;
    }
    
    return cell;
}

@end
